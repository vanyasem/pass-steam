#!/usr/bin/env bash
# pass steam - Password Store Extension (https://www.passwordstore.org/)
# Copyright (c) 2018 Ivan Semkin
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
PYSTEAM=$(pip list | grep -F steam)

steam_get_secret() {
  local user pass prompt="$1" echo="$2"

  read -r -p "Enter Steam username for $prompt: " -s user || exit 1
  echo
  
  if [[ -t 0 ]]; then
    if [[ $echo -eq 0 ]]; then
      read -r -p "Enter Steam password for $prompt: " -s pass || exit 1
      echo
      read -r -p "Retype Steam password for $prompt: " -s pass_again || exit 1
      echo
      [[ "$pass" == "$pass_again" ]] || die "Error: the entered passwords do not match."
    else
      read -r -p "Enter Steam password for $prompt: " -e pass
    fi
  else
    read -r pass
  fi
  
  echo
  echo "Enter Email code and press Enter. Wait for an SMS, enter the code, and press Enter again"
  
  steam_secret=$(python -c '\
    import sys; \
    import steam.guard as guard; \
    import steam.webauth as wa; \
    user = wa.MobileWebAuth(sys.argv[1], sys.argv[2])
try: user.login();
except wa.EmailCodeRequired:
        code = input(); \
        user.login(email_code=code); \
        user.login(); \
        sa = guard.SteamAuthenticator(medium=user); \
        sa.add(); \
        sms = input(); \
        sa.finalize(sms); \
        print(sa.secrets) \
  ' "$user" "$pass")
  
  echo $steam_secret
}

steam_insert() {
  local path="$1" passfile="$2" contents="$3" message="$4"

  check_sneaky_paths "$path"
  set_git "$passfile"

  mkdir -p -v "$PREFIX/$(dirname "$path")"
  set_gpg_recipients "$(dirname "$path")"

  $GPG -e "${GPG_RECIPIENT_ARGS[@]}" -o "$passfile" "${GPG_OPTS[@]}" <<<"$contents" || die "Steam Guard secret encryption aborted."

  git_add_file "$passfile" "$message"
}

cmd_steam_usage() {
  cat <<-_EOF
Usage:

    $PROGRAM steam [code] [--clip,-c] pass-name
        Generate a Steam Guard code and optionally put it on the clipboard.
        If put on the clipboard, it will be cleared in $CLIP_TIME seconds.
        
    $PROGRAM steam insert [--force,-f] [--echo,-e] [pass-name]
        Prompt for a new Steam Guard secret. If pass-name is not supplied, use the
        account nickname. Optionally, echo the input. Prompt before overwriting
        existing password unless forced. This command accepts input from stdin.
        Change your current Steam Guard mode to Email and attach a phone number.
        
More information may be found in the pass-steam(1) man page.
_EOF
  exit 0
}

cmd_steam_insert() {
  local opts force=0 echo=0
  opts="$($GETOPT -o fe -l force,echo -n "$PROGRAM" -- "$@")"
  local err=$?
  eval set -- "$opts"
  while true; do case $1 in
    -f|--force) force=1; shift ;;
    -e|--echo) echo=1; shift ;;
    --) shift; break ;;
  esac done

  [[ $err -ne 0 ]] && die "Usage: $PROGRAM $COMMAND insert [--force,-f] [--echo,-e] [pass-name]"

  local prompt path uri
  if [[ $# -eq 1 ]]; then
    path="${1%/}"
    prompt="$path"
  else
    prompt="this account"
  fi

  steam_get_secret "$prompt" $echo

   if [[ -z "$path" ]]; then
    path+="Steam/"
    path+="boilerplate"
    yesno "Insert into $path?"
  fi
  
  local passfile="$PREFIX/$path.gpg"
  [[ $force -eq 0 && -e $passfile ]] && yesno "An entry already exists for $path. Overwrite it?"

  steam_insert "$path" "$passfile" "$steam_secret" "Add Steam Guard secret for $path to store."
}

cmd_steam_code() {
  [[ -z "$PYSTEAM" ]] && die "Failed to generate Steam Guard code: python-steam is not installed."

  local opts clip=0
  opts="$($GETOPT -o c -l clip -n "$PROGRAM" -- "$@")"
  local err=$?
  eval set -- "$opts"
  while true; do case $1 in
    -c|--clip) clip=1; shift ;;
    --) shift; break ;;
  esac done

  [[ $err -ne 0 || $# -ne 1 ]] && die "Usage: $PROGRAM $COMMAND [--clip,-c] pass-name"

  local path="${1%/}"
  local passfile="$PREFIX/$path.gpg"
  check_sneaky_paths "$path"
  [[ ! -f $passfile ]] && die "Passfile not found"

  contents=$($GPG -d "${GPG_OPTS[@]}" "$passfile")
  while read -r line; do
    if [[ "$line" == {\'shared_secret\':* ]]; then
      local secret="$line"
      break
    fi
  done <<< "$contents"

  local out=$(python -c '\
    import sys; \
    import steam.guard as guard; \
    import ast; \
    sa = guard.SteamAuthenticator(ast.literal_eval(sys.argv[1])); \
    print(sa.get_code())\
  ' "$secret")
  [[ -z $out ]] && die "Failed to generate Steam Guard code for $path"

  if [[ $clip -ne 0 ]]; then
    clip "$out" "Steam Guard code for $path"
  else
    echo "$out"
  fi
}

case "$1" in
  help|--help|-h) shift; cmd_steam_usage "$@" ;;
  insert|add)     shift; cmd_steam_insert "$@" ;;
  code|show)      shift; cmd_steam_code "$@" ;;
  *)                     cmd_steam_code "$@" ;;
esac
exit 0
