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

cmd_steam_usage() {
  cat <<-_EOF
Usage:

    $PROGRAM steam [code] [--clip,-c] pass-name
        Generate a Steam Guard code and optionally put it on the clipboard.
        If put on the clipboard, it will be cleared in $CLIP_TIME seconds.

More information may be found in the pass-steam(1) man page.
_EOF
  exit 0
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
  code|show)      shift; cmd_steam_code "$@" ;;
  *)                     cmd_steam_code "$@" ;;
esac
exit 0
