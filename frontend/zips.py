#!/usr/bin/env python3
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

import gzip
import hashlib
import io
import os
import re
import sys
import tarfile
import urllib.request
import zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
RDB_URL = "buildbot.libretro.com/assets/frontend/database-rdb.zip"
ICON_DIRS = ("ozone/png/icons", "xmb/monochrome/png")


def read_list(name):
    with open(os.path.join(HERE, name), encoding="utf-8") as f:
        return [line.rstrip("\n") for line in f if line.strip()]


def read_pairs(name):
    return [tuple(line.split("|", 1)) for line in read_list(name)]


def walk(base, prefix=""):
    for dirpath, _, names in os.walk(base):
        for name in names:
            path = os.path.join(dirpath, name)
            yield prefix + os.path.relpath(path, base).replace(os.sep, "/"), path


def write_zip(path, entries):
    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as z:
        for name in sorted(entries):
            info = zipfile.ZipInfo(name, (1980, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o644 << 16
            data = entries[name]
            if isinstance(data, str):
                with open(data, "rb") as f:
                    data = f.read()
            z.writestr(info, data)
    print("%-20s %6d files %8.2f MB" % (os.path.basename(path), len(entries), os.path.getsize(path) / 1e6))


def write_tar_gz(path, entries):
    with open(path, "wb") as f:
        with gzip.GzipFile("", "wb", 9, f, 0) as z:
            with tarfile.open(fileobj=z, mode="w", format=tarfile.GNU_FORMAT) as t:
                for name in sorted(entries):
                    data = entries[name]
                    if isinstance(data, str):
                        with open(data, "rb") as source:
                            data = source.read()
                    info = tarfile.TarInfo(name)
                    info.size = len(data)
                    info.mode = 0o644
                    t.addfile(info, io.BytesIO(data))
    with gzip.open(path, "rb") as z:
        digest = hashlib.sha256(z.read()).hexdigest()
    with open(path[: -len(".gz")] + ".sha256", "w", encoding="utf-8", newline="\n") as f:
        f.write(digest + "\n")
    print("%-20s %6d files %8.2f MB  tar sha256 %s" % (os.path.basename(path), len(entries), os.path.getsize(path) / 1e6, digest[:12]))


def add_aliases(entries, directory, aliases):
    for alias, target in aliases:
        for suffix in ("", "-content"):
            source = "%s/%s%s.png" % (directory, target, suffix)
            if source in entries:
                entries["%s/%s%s.png" % (directory, alias, suffix)] = entries[source]


def keep_icon(name, systems):
    if not name.endswith(".png"):
        return True
    if name[0].islower():
        return not name.startswith("iQue - ")
    stem = name[:-4]
    if stem.endswith("-content"):
        stem = stem[: -len("-content")]
    return stem in systems


def assets(src, systems, aliases):
    entries = {}
    for top in ("ozone", "xmb/monochrome", "sounds"):
        for arc, path in walk(os.path.join(src, top), top + "/"):
            directory, name = arc.rsplit("/", 1)
            if directory not in ICON_DIRS or keep_icon(name, systems):
                entries[arc] = path
    entries["COPYING"] = os.path.join(src, "COPYING")
    for directory in ICON_DIRS:
        add_aliases(entries, directory, aliases)
    return entries


def shaders(src):
    need = set()
    seen = set()

    def resolve(base, ref):
        return os.path.relpath(os.path.normpath(os.path.join(src, os.path.dirname(base), ref)), src).replace(os.sep, "/")

    def preset(path):
        if path in seen:
            return
        seen.add(path)
        need.add(path)
        with open(os.path.join(src, path), encoding="utf-8", errors="replace") as f:
            text = f.read()
        for m in re.finditer(r'^\s*#reference\s+"?([^"\r\n]+)"?', text, re.M):
            preset(resolve(path, m.group(1).strip()))
        keys = {m.group(1): m.group(2).strip().strip('"') for m in re.finditer(r"^\s*([A-Za-z0-9_]+)\s*=\s*(.+?)\s*$", text, re.M)}
        for key, value in keys.items():
            if re.fullmatch(r"shader\d+", key):
                need.add(resolve(path, value))
        for texture in re.split(r"[;,]", keys.get("textures", "")):
            if texture.strip() in keys:
                need.add(resolve(path, keys[texture.strip()]))

    for path in read_list("shaders.txt") + ["bilinear.glslp", "nearest.glslp"]:
        preset(path)
    need.add("stock.glsl")
    return {path: os.path.join(src, path) for path in need}


def cheats(src, systems, aliases):
    exclude = set(read_list("cheats-exclude.txt"))
    base = os.path.join(src, "cht")
    entries = {}
    for system in sorted(os.listdir(base)):
        if system in systems and system not in exclude:
            entries.update(walk(os.path.join(base, system), system + "/"))
    for alias, target in aliases:
        prefix = target + "/"
        for arc in [a for a in entries if a.startswith(prefix)]:
            entries[alias + "/" + arc[len(prefix):]] = entries[arc]
    return entries


def info(src):
    entries = {}
    with open(os.path.join(ROOT, "cores.txt"), encoding="utf-8") as f:
        names = [line.split("|")[0].strip() for line in f if line.strip() and not line.startswith("#")]
    for name in names:
        file = "%s_libretro.info" % name
        own = os.path.join(ROOT, "info", file)
        entries[file] = own if os.path.exists(own) else os.path.join(src, "core-info", file)
    return entries


def databases(systems):
    for scheme in ("https", "http"):
        try:
            with urllib.request.urlopen("%s://%s" % (scheme, RDB_URL), timeout=120) as r:
                data = r.read()
            break
        except OSError:
            data = None
    if data is None:
        sys.exit("cannot download " + RDB_URL)
    with zipfile.ZipFile(io.BytesIO(data)) as z:
        return {n: z.read(n) for n in z.namelist() if n.endswith(".rdb") and n[:-4] in systems}


def main():
    src, out = sys.argv[1], sys.argv[2]
    systems = set(read_list("systems.txt"))
    aliases = read_pairs("aliases.txt")
    kept = assets(os.path.join(src, "assets"), systems, aliases)
    write_zip(os.path.join(out, "assets.zip"), kept)
    write_tar_gz(os.path.join(out, "assets.tar.gz"), kept)
    write_zip(os.path.join(out, "shaders_glsl.zip"), shaders(os.path.join(src, "shaders")))
    write_zip(os.path.join(out, "cheats.zip"), cheats(os.path.join(src, "database"), systems, aliases))
    write_zip(os.path.join(out, "info.zip"), info(src))
    write_zip(os.path.join(out, "database-rdb.zip"), databases(systems))


main()
