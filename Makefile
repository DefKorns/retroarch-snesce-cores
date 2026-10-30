MOD_CATEGORY := RetroArch
CORE_ID      := retroarch_snesce_core_

all: hmods

out/.built: cores.txt build.sh
	sh build.sh
	touch $@

hmods: out/.built
	sh package.sh
	for name in $$(cat out/mods.list); do \
	  $(MAKE) hmod MOD_ID=$(CORE_ID)$$name MOD_VER=$$(cat out/mods/$$name.version) MOD_NAME="RetroArch Core - $$(cat out/mods/$$name.title)" \
	    MOD_DIR=out/mods/$$name || exit 1; \
	done

clean:
	rm -rf out/ out-src/

include vendor/hmod-build/hmod.mk

.PHONY: all hmods clean
