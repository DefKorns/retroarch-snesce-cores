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

cross="${CROSS_PREFIX:-arm-linux-gnueabihf-}"
egl_ref=e964211ff5f7c2bcada786954a16d5b813379395
gl_ref=6af574a14089ccfee87efe230ebcdd8742859813
stubs="$PWD/.stubs"

fetchHeader() {
  mkdir -p "$stubs/inc/$(dirname "$2")"
  curl -fsSL "https://raw.githubusercontent.com/KhronosGroup/$1/$3/api/$2" -o "$stubs/inc/$2"
}

rm -rf "$stubs"
mkdir -p "$stubs/lib"
for header in EGL/egl.h EGL/eglext.h EGL/eglplatform.h KHR/khrplatform.h; do
  fetchHeader EGL-Registry "$header" "$egl_ref"
done
for header in GLES2/gl2.h GLES2/gl2ext.h GLES2/gl2platform.h; do
  fetchHeader OpenGL-Registry "$header" "$gl_ref"
done

grep -h -o -E 'GL_APIENTRY +gl[A-Za-z0-9_]+' "$stubs/inc/GLES2/gl2.h" "$stubs/inc/GLES2/gl2ext.h" |
  awk '{ print "void " $2 "(void) {}" }' | sort -u > "$stubs/gles.c"
grep -h -o -E 'EGLAPIENTRY +egl[A-Za-z0-9_]+' "$stubs/inc/EGL/egl.h" "$stubs/inc/EGL/eglext.h" |
  awk '{ print "void " $2 "(void) {}" }' | sort -u > "$stubs/egl.c"
"${cross}gcc" -shared -Wl,-soname,libGLESv2.so -o "$stubs/lib/libGLESv2.so" "$stubs/gles.c"
"${cross}gcc" -shared -Wl,-soname,libEGL.so -o "$stubs/lib/libEGL.so" "$stubs/egl.c"

git apply "$(dirname "$0")/mupen64plus.patch"
