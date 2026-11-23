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

# Runs build.sh in the toolchain image and again in the GCC 13 image for the
# cores that name it in cores.txt. "default" or "gcc13" runs only that half, so
# the two can build in parallel. TOOLCHAIN_IMAGE and GCC13_IMAGE override the images.
set -eu
export MSYS_NO_PATHCONV=1
which=${1:-all}
image=${TOOLCHAIN_IMAGE:-ghcr.io/defkorns/classicmini-cross-toolchain:v1.3.0}
gcc13_image=${GCC13_IMAGE:-ghcr.io/defkorns/classicmini-gcc13:gcc13}
case "$which" in all | default | gcc13) ;; *) echo "usage: $0 [default|gcc13]" >&2; exit 2 ;; esac
if [ "$which" != gcc13 ]; then
  docker run --rm -v "$PWD:/w" -w /w "$image" sh build.sh
fi
if [ "$which" != default ] && grep -v '^#' cores.txt | grep -Eq '\| *gcc13 *(\||$)'; then
  docker run --rm -e TOOLCHAIN=gcc13 -v "$PWD:/w" -w /w "$gcc13_image" sh build.sh
fi
