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

# Lays out one hmod folder per core in out/mods/<core>/ from the output of
# build.sh: the core, its info file and the /bin shortcut that hakchi games call.
set -eu

root=$(pwd)
mods="$root/out/mods"
rm -rf "$mods"
mkdir -p "$mods"
: > "$root/out/mods.list"

grep -v '^#' cores.txt | while IFS='|' read -r name _ _ _ _ shortcut title; do
  name=$(echo "$name" | tr -d ' ')
  shortcut=$(echo "$shortcut" | tr -d ' ')
  title=$(echo "$title" | sed 's/^ *//;s/ *$//')
  [ -n "$name" ] || continue

  dir="$mods/$name"
  mkdir -p "$dir/bin" "$dir/etc/libretro/core" "$dir/etc/libretro/info"
  cp "$root/out/cores/${name}_libretro.so" "$dir/etc/libretro/core/"
  cp "$root/out/info/${name}_libretro.info" "$dir/etc/libretro/info/"
  printf '#!/bin/sh\nexec retroarch-clover %s "$@"\n' "$name" > "$dir/bin/$shortcut"
  cat > "$dir/readme.md" <<EOT
# $title

The $title libretro core for the RetroArch (S)NESCE hmod, which has to be installed too.

Use it from a game's command line as \`/bin/$shortcut\`, or add \`--retroarch --core $name\`.
EOT
  echo "$title" > "$mods/$name.title"
  echo "$name" >> "$root/out/mods.list"
done
