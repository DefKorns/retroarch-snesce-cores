# RetroArch (S)NESCE cores

[![Build](https://github.com/DefKorns/retroarch-snesce-cores/actions/workflows/build.yml/badge.svg)](https://github.com/DefKorns/retroarch-snesce-cores/actions/workflows/build.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)

Libretro cores built for the NES and SNES Classic (ARMv7 Cortex-A7) for the [RetroArch (S)NESCE](https://github.com/DefKorns/RetroArch-S-NESCE) hmod. Every core is built from the upstream source, pinned to a commit, and released as an hmod you can install without internet on the console.

## Cores

| Core | System | Source | Shortcut |
| --- | --- | --- | --- |
| Snes9x 2005 | SNES | [libretro/snes9x2005](https://github.com/libretro/snes9x2005) | `/bin/snes05` |
| Snes9x 2010 | SNES | [libretro/snes9x2010](https://github.com/libretro/snes9x2010) | `/bin/snes10` |
| FCEUmm | NES, FDS | [libretro/libretro-fceumm](https://github.com/libretro/libretro-fceumm) | `/bin/fceumm` |
| Nestopia | NES, FDS | [libretro/nestopia](https://github.com/libretro/nestopia) | `/bin/nestopia` |
| QuickNES | NES | [libretro/QuickNES_Core](https://github.com/libretro/QuickNES_Core) | `/bin/quicknes` |

The exact commit of each core is in `cores.txt`. In the tests I ran on a SNES Classic, Snes9x 2005 and 2010 used as much CPU as the `km_*` builds of the same cores.

## Install

You need the [RetroArch (S)NESCE](https://github.com/DefKorns/RetroArch-S-NESCE) hmod first.

Download `retroarch_snesce_core_<core>.hmod` from the [releases](https://github.com/DefKorns/retroarch-snesce-cores/releases) and install it with Hakchi. Each hmod holds the core, its info file and the shortcut a Hakchi game can use as its executable. Instead of the shortcut, a game can also use `--retroarch --core <core>` in its command line.

## Online updater

Every push to `master` publishes an updater tree to <https://defkorns.github.io/retroarch-snesce-cores/>, in the layout RetroArch's core updater reads:

- `.index-extended`: one line per core, `date crc <core>_libretro.so.zip`
- `<core>_libretro.so.zip`
- `info/<core>_libretro.info`

It is not usable from the console yet: GitHub Pages only serves HTTPS, and the RetroArch (S)NESCE build has no TLS. For now, install the hmods.

## Build

You need Docker and git.

```sh
git submodule update --init
./docker-build.sh                                     # cores and the updater tree, in out/
sh vendor/hmod-build/docker-make.sh hmods             # one hmod per core, in out/
```

Both run in the [classicmini-cross-toolchain](https://github.com/DefKorns/classicmini-cross-toolchain) image. `TOOLCHAIN_IMAGE` overrides the image.

## Add a core

Add a line to `cores.txt`:

```text
name | repository | commit | build dir | extra make args | shortcut | hmod version | title
```

- `hmod version` is the version of the core itself (its libretro `display_version`) with `-beta` while the builds are for testing; a core without a version number uses the date.
- `build dir` is the folder holding the core's Makefile (`.` for the root).
- `extra make args` is passed to `make`, for example `LIBS='-lpthread -lm'`.
- The core's Makefile needs a `classic_armv7_a7` platform.
- `name` must match the `<name>_libretro.so` the Makefile produces and an info file in [libretro-core-info](https://github.com/libretro/libretro-core-info).

## Releases

A tag `v*` builds the hmods and publishes them as a release, through the shared workflow of [hmod-build](https://github.com/DefKorns/hmod-build). The tag is the version of every hmod in that release.

## Contributing

[pre-commit](https://pre-commit.com/) checks the files you stage before each commit. Set it up once per clone with `pip install pre-commit` and `pre-commit install`; `pre-commit run --all-files` checks everything.

## License

GPL-3.0-or-later for the scripts in this repository. Each core keeps its own license; see its source repository.
