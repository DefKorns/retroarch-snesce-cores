## Options

The core options are the core's own defaults. `Use BIOS` is on, but the core falls back to its built-in BIOS when there is no `gba_bios.bin`.

The mGBA of the KMFD hmod has the same core name and the same `/bin/mgba` and `/bin/gba`: with both installed they share `/etc/libretro/config/mGBA/mGBA.opt`, and the shortcuts belong to the last one installed.

## Saves

A game's save is kept as one file, with every slot in it. A game launched from the Hakchi menu or ClassicStation keeps it in the game's save folder.

## BIOS

None is required. `gba_bios.bin`, `gb_bios.bin`, `gbc_bios.bin` and `sgb_bios.bin` go in `/etc/libretro/system` if you want them.

## Credits

mGBA is by endrift and the mGBA team.
