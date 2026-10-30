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

# Builds every core in cores.txt for the NES/SNES Classic and writes the
# updater tree to out/: <core>_libretro.so.zip, .index-extended and info/,
# plus the bare cores in out/cores/ for the hmods.
# Runs inside the classicmini-cross-toolchain image (see docker-build.sh).
set -eu

cross="${CROSS_PREFIX:-arm-linux-gnueabihf-}"
# PicoDrive generates its Cyclone core by running a binary built for the console under qemu
export QEMU_LD_PREFIX="${QEMU_LD_PREFIX:-/opt/toolchain/arm-cortex_a7-linux-gnueabihf/sysroot}"
info_ref=445421549abc0638a2f5ecf05db8437e580dcc69
root=$(pwd)
out="$root/out"
src="$root/out-src"
date_stamp=$(date -u +%Y-%m-%d)

rm -rf "$out" "$src"
mkdir -p "$out/info" "$out/cores" "$src"
: > "$out/.index-extended"

grep -v '^#' cores.txt | while IFS='|' read -r name repo commit dir extra _; do
  name=$(echo "$name" | tr -d ' ')
  repo=$(echo "$repo" | tr -d ' ')
  commit=$(echo "$commit" | tr -d ' ')
  dir=$(echo "$dir" | tr -d ' ')
  extra=$(echo "$extra" | sed 's/^ *//;s/ *$//')
  [ -n "$name" ] || continue

  git init -q "$src/$name"
  git -C "$src/$name" fetch -q --depth 1 "$repo" "$commit"
  git -C "$src/$name" checkout -q FETCH_HEAD
  git -C "$src/$name" submodule update -q --init

  (cd "$src/$name/$dir" && eval "make -j$(nproc) platform=classic_armv7_a7 \
    CC=${cross}gcc CXX=${cross}g++ AR=${cross}ar $extra")
  so="$src/$name/$dir/${name}_libretro.so"
  "${cross}strip" "$so"
  cp "$so" "$out/cores/"

  perl -MIO::Compress::Zip=zip,'$ZipError' -e 'zip($ARGV[0] => $ARGV[1], Name => $ARGV[2]) or die $ZipError' \
    "$so" "$out/${name}_libretro.so.zip" "${name}_libretro.so"
  crc=$(gzip -c "$so" | tail -c 8 | od -An -tx4 -N4 | tr -d ' ')
  echo "$date_stamp $crc ${name}_libretro.so.zip" >> "$out/.index-extended"

  if [ -f "$root/info/${name}_libretro.info" ]; then
    cp "$root/info/${name}_libretro.info" "$out/info/"
  else
    curl -fsSL "https://raw.githubusercontent.com/libretro/libretro-core-info/$info_ref/${name}_libretro.info" \
      -o "$out/info/${name}_libretro.info"
  fi
done
cat "$out/.index-extended"
