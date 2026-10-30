# RetroArch (S)NESCE cores

[![Build](https://github.com/DefKorns/retroarch-snesce-cores/actions/workflows/build.yml/badge.svg)](https://github.com/DefKorns/retroarch-snesce-cores/actions/workflows/build.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)

Libretro cores built for the NES and SNES Classic (ARMv7 Cortex-A7) for the [RetroArch (S)NESCE](https://github.com/DefKorns/RetroArch-S-NESCE) hmod. Every core is built from the upstream source, pinned to a commit, and released as an hmod you can install without internet on the console.

## Cores

| Core | System | Source | Version | Shortcut |
| --- | --- | --- | --- | --- |
| Snes9x 2005 | SNES | [libretro/snes9x2005](https://github.com/libretro/snes9x2005) | 1.36-beta | `/bin/snes05` |
| Snes9x 2010 | SNES | [libretro/snes9x2010](https://github.com/libretro/snes9x2010) | 1.52.4-beta | `/bin/snes10` |
| FCEUmm | NES, FDS | [libretro/libretro-fceumm](https://github.com/libretro/libretro-fceumm) | 2026.10.30-beta | `/bin/fceumm` |
| Nestopia | NES, FDS | [libretro/nestopia](https://github.com/libretro/nestopia) | 2.0.0-beta | `/bin/nestopia` |
| QuickNES | NES | [libretro/QuickNES_Core](https://github.com/libretro/QuickNES_Core) | 1.0-WIP-beta | `/bin/quicknes` |
| SMS Plus GX | Master System, Game Gear | [libretro/smsplus-gx](https://github.com/libretro/smsplus-gx) | 1.8-beta | `/bin/smsplus` |
| Genesis Plus GX | Mega Drive, Sega CD, Master System, Game Gear | [libretro/Genesis-Plus-GX](https://github.com/libretro/Genesis-Plus-GX) | v1.7.4-beta | `/bin/genesis` |
| Genesis Plus GX EX | the same, plus Paprium | [DefKorns/Genesis-Plus-GX-EX](https://github.com/DefKorns/Genesis-Plus-GX-EX) (branch `snesce`) | v1.7.4-beta | `/bin/genesis_ex` |
| Genesis Plus GX Wide | the same, widescreen | [libretro/Genesis-Plus-GX-Wide](https://github.com/libretro/Genesis-Plus-GX-Wide) | v1.7.4-beta | `/bin/genesis_wide` |
| PicoDrive | Mega Drive, Sega CD, 32X, Master System | [libretro/picodrive](https://github.com/libretro/picodrive) | 2.05-beta | `/bin/picodrive` |
| PCSX ReARMed | PlayStation | [libretro/pcsx_rearmed](https://github.com/libretro/pcsx_rearmed) | r26-beta | `/bin/pcsx` |

Each hmod has the version of its libretro core, with `-beta` while the builds are for testing. FCEUmm has no version number (it reports "SVN"), so it uses the date of the build. The exact commit of each core is in `cores.txt`. In the tests I ran on a SNES Classic, Snes9x 2005 and 2010 used as much CPU as the `km_*` builds of the same cores.

## BIOS

Only the Famicom Disk System (`.fds`) games, Sega CD and PlayStation need a BIOS. Put it in `/etc/libretro/system`.

| Core | BIOS | Required | Notes |
| --- | --- | --- | --- |
| Snes9x 2005 | none | | |
| Snes9x 2010 | none | | |
| FCEUmm | `disksys.rom` | for `.fds` | md5 `ca30b50f880eb660a320674ed365ef7a`. `nes.pal` (custom palette) and `gamegenie.nes` are optional |
| Nestopia | `disksys.rom` | for `.fds` | same file as FCEUmm; L switches the disk side |
| QuickNES | none | | plays `.nes` only, no FDS |
| SMS Plus GX | `bios.sms` | optional | Master System BIOS |
| Genesis Plus GX, EX and Wide | `bios_CD_E.bin`, `bios_CD_U.bin`, `bios_CD_J.bin` | for Sega CD | `bios_MD.bin`, `bios_E.sms`, `bios_U.sms`, `bios_J.sms` and `bios.gg` are optional |
| PicoDrive | `bios_CD_E.bin`, `bios_CD_U.bin`, `bios_CD_J.bin` | for Sega CD | same names as Genesis Plus GX |
| PCSX ReARMed | `scph5500.bin`, `scph5501.bin`, `scph5502.bin` | recommended | JP, US and EU; without one the core falls back to a software BIOS with lower compatibility |

The RetroArch (S)NESCE hmod copies the console's own `fds_bios.bin` to `disksys.rom` when it installs, on consoles that have it. Elsewhere, add the file yourself; this repository does not ship any BIOS.

## Install

You need the [RetroArch (S)NESCE](https://github.com/DefKorns/RetroArch-S-NESCE) hmod first.

Download `retroarch_snesce_core_<core>.hmod` (one for each core in the table) from the [releases](https://github.com/DefKorns/retroarch-snesce-cores/releases) and install it with Hakchi. Each hmod holds the core, its info file and the shortcut a Hakchi game can use as its executable. Instead of the shortcut, a game can also use `--retroarch --core <core>` in its command line.

## Paprium

Only the EX core plays Paprium. This repository does not ship the game or its music.

- Keep the `.bin` next to a folder called `paprium` that holds the MP3 files.
- The first time, pick the language, play the Vaporware mini-game once and quit through RetroArch. That creates the save; until it exists the game only shows the mini-game.
- Launch it with `--save-data-backing-file`, with the save folder outside the game folder, or the console discards the save when the game closes.
- The console has 253 MB of RAM. The EX build in this repository keeps one track in memory at a time and plays it in stereo (see the `snesce` branch of the EX repository); the upstream code never frees the tracks and runs out of memory on the console at the title screen. The longest tracks take about 70 MB.
- A `.wav` with the same name as an `.mp3` (PCM, 16 bit, stereo, 48 kHz) is read instead of the MP3, so that track does not need to be decoded, which can shorten its loading. It takes about 11 MB per minute of music; the `.mp3` stays as the fallback.
- Loading between some screens still takes several seconds. The cause is not known.

## Widescreen

The Wide core is experimental. It draws extra columns beyond the normal screen, and a game only prepares the visible area, so unless the game has a widescreen patch the edges show glitches while the screen scrolls. According to its author, Gunstar Heroes and Ristar work as they are, and other games need a custom patch (there is an auto-patcher for Sonic 1; Sonic 2 was announced). Set `Extra columns to draw in H40 for widescreen` to 0 to get the picture of the normal core, or lower `Extra columns alpha %` to fade the extra columns. The upstream default is 10 columns.

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
name | repository | commit | build dir | extra make args | shortcut | hmod version | title | systems
```

- `title` is the name of the core in the hakchi module list, which cuts a name after about 40 characters, counting the prefix "RetroArch Core - " that the Makefile adds; `systems` goes into the readme header as `Emulated System:`, which the client uses to group the list.
- `hmod version` is the version of the core itself (its libretro `display_version`) with `-beta` while the builds are for testing; a core without a version number uses the date.
- `build dir` is the folder holding the core's Makefile (`.` for the root).
- `extra make args` is passed to `make`, for example `LIBS='-lpthread -lm'`.
- The core's Makefile needs a `classic_armv7_a7` platform.
- `name` must match the `<name>_libretro.so` the Makefile produces and an info file in [libretro-core-info](https://github.com/libretro/libretro-core-info), or one in `info/`.
- A script `hooks/<name>.sh` runs in the core's source folder after the checkout and before `make`, for steps that must run on the build machine.

## Releases

A tag `v*` builds the hmods and publishes them as a release, through the shared workflow of [hmod-build](https://github.com/DefKorns/hmod-build). The tag only names the release: each hmod keeps the version of its core, from `cores.txt`. The tag matches the version of the [RetroArch (S)NESCE](https://github.com/DefKorns/RetroArch-S-NESCE) hmod the cores were tested with (`v1.22.2-beta`).

## Contributing

[pre-commit](https://pre-commit.com/) checks the files you stage before each commit. Set it up once per clone with `pip install pre-commit` and `pre-commit install`; `pre-commit run --all-files` checks everything.

## License

GPL-3.0-or-later for the scripts in this repository. Each core keeps its own license; see its source repository.

Genesis Plus GX is by Charles MacDonald and Eke-Eke and is licensed for non-commercial use. The EX core is built from a fork of the Expanded ROM Size fork of RapidEdwin08 and BillyTimeGames, which carries the Paprium support; the memory changes are in the `snesce` branch of that fork.
