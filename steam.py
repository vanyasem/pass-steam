# -*- coding: utf-8 -*-
##
## pass steam - Password Store Extension (https://www.passwordstore.org/)
## Copyright (c) 2018 Ivan Semkin.
## 
##    This program is free software: you can redistribute it and/or modify
##    it under the terms of the GNU General Public License as published by
##    the Free Software Foundation, either version 3 of the License, or
##    (at your option) any later version.
## 
##    This program is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU General Public License for more details.
## 
##    You should have received a copy of the GNU General Public License
##    along with this program. If not, see <http://www.gnu.org/licenses/>.
##

import sys

import steam.guard as guard
import steam.webauth as wa


def code():
    print('boilerplate')

if sys.argv[1] == 'code':
    code()
elif sys.argv[1] == '':
    pass
  
