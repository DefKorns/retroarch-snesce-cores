# RetroArch (S)NESCE cores

Libretro cores built for the NES and SNES Classic (ARMv7 Cortex-A7), published as a RetroArch online updater source for the [RetroArch (S)NESCE](https://github.com/DefKorns/RetroArch-S-NESCE) hmod.

The cores are listed in `cores.txt`, each pinned to a commit and built with the `classic_armv7_a7` platform of its Makefile in the classicmini-cross-toolchain image. GitHub Pages serves the result:

- `.index-extended` - one line per core: `date crc <core>_libretro.so.zip`
- `<core>_libretro.so.zip`
- `info/<core>_libretro.info`

## Use it

In `retroarch.cfg`:

```text
core_updater_buildbot_cores_url = "https://defkorns.github.io/retroarch-snesce-cores/"
```

then **Online Updater > Core Downloader** lists the cores.

## Build locally

```sh
./docker-build.sh
```

The updater tree is written to `out/`.

## Add a core

Add a line to `cores.txt` with the repository, a commit and the folder holding its Makefile. The core's Makefile needs a `classic_armv7_a7` platform.
