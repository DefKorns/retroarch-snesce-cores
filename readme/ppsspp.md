## Settings

The first time the shortcut runs it adds three lines to the RetroArch files in `/etc/libretro/config/PPSSPP/`, only if the key is not there yet: `aspect_ratio_index = "22"` in `PPSSPP.cfg` (the core's own aspect ratio, whatever the ClassicStation video mode says), and `ppsspp_lower_resolution_for_effects = "Balanced"` and `ppsspp_skip_gpu_readbacks = "enabled"` in `PPSSPP.opt`. After that the files are yours: change an option in the RetroArch menu and it is kept. Uninstalling removes those three lines if they still have these values.

## Credits

PPSSPP is by Henrik Rydgard and the PPSSPP team. Thanks to KMFDManic, who is looking at how to make it run well on the console.
