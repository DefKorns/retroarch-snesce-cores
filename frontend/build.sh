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

# Writes the zips the RetroArch online updater downloads (assets, GLSL shaders, cheats,
# core info files and databases) to out/frontend/, from the upstream sources in sources.txt.
# Usage: frontend/build.sh [output dir]
set -eu

root=$(pwd)
src="$root/out-src/frontend"
out="${1:-$root/out/frontend}"

rm -rf "$src" "$out"
mkdir -p "$src" "$out"

grep -v '^#' frontend/sources.txt | while IFS='|' read -r name repo commit paths; do
  name=$(echo "$name" | tr -d ' ')
  repo=$(echo "$repo" | tr -d ' ')
  commit=$(echo "$commit" | tr -d ' ')
  paths=$(echo "$paths" | sed 's/^ *//;s/ *$//')
  [ -n "$name" ] || continue

  git init -q "$src/$name"
  git -C "$src/$name" remote add origin "$repo"
  if [ -n "$paths" ]; then
    # shellcheck disable=SC2086
    git -C "$src/$name" sparse-checkout set $paths
    git -C "$src/$name" fetch -q --depth 1 --filter=blob:none origin "$commit"
  else
    git -C "$src/$name" fetch -q --depth 1 origin "$commit"
  fi
  git -C "$src/$name" checkout -q FETCH_HEAD
done

python3 frontend/zips.py "$src" "$out"
