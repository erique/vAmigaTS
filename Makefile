# Top-level Makefile for the vAmiga regression test suite, testing the FPGAArcade AMIGA cores

# Based on the vAmiga regression test suite
# (C)opyright Dirk W. Hoffmann, 2022
#
# To run all regression tests:
#
# 0. Install vasm under /opt/amiga/bin and NDK includes under /opt/amiga/m68k-amigaos/ndk-include
#
# 1. Build tests
#
#    `make [-j<number of parallel threads>]`
#
# 2. Rsync tests to the sdcard (replace /tmp/sdcard with the actual mountpoint)
#
#    `rsync -aP --filter="dir-merge rsync-filter.txt" . /tmp/sdcard`
#

# use bebbo-gcc's vasm
export PATH := ${PATH}:/opt/amiga/bin

# Collect all directories containing a Makefile
MKFILES = $(wildcard */Makefile)
SUBDIRS = $(dir $(MKFILES))
MYMAKE = $(MAKE) --no-print-directory

.PHONY: all prebuild subdirs missingini clean

all: prebuild subdirs tiff missingini
	@echo > /dev/null
	
prebuild:
	@echo "vAmiga regression tester" 
	@echo "${VAMIGA}"
		
subdirs:
	@for dir in $(SUBDIRS); do \
		echo "Entering ${CURDIR}/$$dir"; \
		$(MAKE) -C $$dir || exit 1; \
	done

tiff:
	@for dir in $(SUBDIRS); do \
		echo "Entering ${CURDIR}/$$dir"; \
		$(MAKE) tiff -C $$dir || exit 1; \
	done

missingini:
	@echo "The following tests have no test scripts. They must me run manually..."
	@./Scripts/missingini.sh */*/*/*
	
clean:
	@for dir in $(SUBDIRS); do \
		echo "Cleaning up ${CURDIR}/$$dir"; \
		$(MAKE) -C $$dir clean; \
	done
