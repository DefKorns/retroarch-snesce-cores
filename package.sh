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

grep -v '^#' cores.txt | while IFS='|' read -r name _ _ _ _ shortcut version title; do
  name=$(echo "$name" | tr -d ' ')
  shortcut=$(echo "$shortcut" | tr -d ' ')
  version=$(echo "$version" | tr -d ' ')
  title=$(echo "$title" | sed 's/^ *//;s/ *$//')
  [ -n "$name" ] || continue

  dir="$mods/$name"
  mkdir -p "$dir/bin" "$dir/etc/libretro/core" "$dir/etc/libretro/info"
  cp "$root/out/cores/${name}_libretro.so" "$dir/etc/libretro/core/"
  cp "$root/out/info/${name}_libretro.info" "$dir/etc/libretro/info/"
  printf '#!/bin/sh\nexec retroarch-clover %s "$@"\n' "$name" > "$dir/bin/$shortcut"
  info="$dir/etc/libretro/info/${name}_libretro.info"
  authors=$(sed -n 's/^authors = "\(.*\)"/\1/p' "$info")
  system=$(sed -n 's/^systemname = "\(.*\)"/\1/p' "$info")
  bios=$(sed -n 's/^firmware[0-9]*_desc = "\(.*\)"/\1/p' "$info" | paste -sd, - | sed 's/,/, /g')
  {
    echo "Core by: $authors|Libretro"
    echo "Emulated System: $system"
    echo "Command Line: /bin/$shortcut"
    [ -z "$bios" ] || echo "Prerequisite BIOS: $bios"
    echo
    echo "The $title libretro core for the RetroArch (S)NESCE hmod, which has to be installed too."
    echo
    echo "Use it from a game's command line as \`/bin/$shortcut\`, or add \`--retroarch --core $name\`."
    if [ -f "$root/readme/$name.md" ]; then
      echo
      cat "$root/readme/$name.md"
    fi
  } > "$dir/readme.md"
  echo "$title" > "$mods/$name.title"
  echo "$version" > "$mods/$name.version"
  echo "$name" >> "$root/out/mods.list"
done
