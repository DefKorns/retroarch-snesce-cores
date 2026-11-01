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

# The /bin names of the cores from cores.txt, one per line as "<name> <core> [<core>...]"; the first core installed answers.
# shortcuts.txt gives the order of a name that several cores share.
# Usage: shortcuts.sh <output file>
set -eu

out="$1"
pairs=$(mktemp)
grep -v '^#' cores.txt | while IFS='|' read -r name _ _ _ _ shortcut _ _ _ aliases; do
  name=$(echo "$name" | tr -d ' ')
  shortcut=$(echo "$shortcut" | tr -d ' ')
  [ -n "$name" ] || continue
  for link in $shortcut $aliases; do
    echo "$link $name"
  done
done | sort -u > "$pairs"
awk 'NR == FNR { if ($0 !~ /^#/ && NF) order[$1] = $0; next }
     !($1 in order) { print }
     END { for (link in order) print order[link] }' shortcuts.txt "$pairs" | sort > "$out"
rm -f "$pairs"
