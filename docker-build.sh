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

# Runs build.sh in the toolchain image. TOOLCHAIN_IMAGE overrides the image.
set -eu
export MSYS_NO_PATHCONV=1
image=${TOOLCHAIN_IMAGE:-ghcr.io/defkorns/classicmini-cross-toolchain:v1.3.0}
docker run --rm -v "$PWD:/w" -w /w "$image" sh build.sh
