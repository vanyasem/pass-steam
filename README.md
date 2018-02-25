# pass-steam

A [pass](https://www.passwordstore.org/) extension for managing Steam Guard codes

## Usage

```
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
```

## Installation

### From git

```
git clone https://github.com/tadfisher/pass-otp
cd pass-otp
sudo make install
```

### Arch Linux

`pass-steam` is available in AUR:

```
pacaur -S pass-steam-git
```

## Requirements

- `pass` 1.7.0 or later for extension support
- [python-steam](https://github.com/ValvePython/steam) for generating Steam Guard codes

## License

```
Copyright (c) 2018 Ivan Semkin

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
```
