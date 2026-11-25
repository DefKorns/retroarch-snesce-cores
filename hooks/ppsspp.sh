#!/bin/sh
#  Copyright (C) 2026 DefKorns (https://defkorns.github.io/LICENSE)
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.

set -eu

[ -e ffmpeg/linux/arm ] || ln -s armv7 ffmpeg/linux/arm

# the prebuilt ffmpeg calls fcntl64, which glibc 2.21 does not have
"${CROSS_PREFIX:-arm-linux-gnueabihf-}gcc" -O2 -fPIC -c "$(dirname "$0")/ppsspp_fcntl64.c" -o fcntl64_shim.o
