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

die() { echo "$*" 1>&2 ; exit 1; }

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
  exit 0
}

case "$1" in
  help|--help|-h) shift; cmd_steam_usage "$@" ;;
  code|show)      shift; cmd_steam_code "$@" ;;
  *)                     cmd_steam_code "$@" ;;
esac
exit 0
