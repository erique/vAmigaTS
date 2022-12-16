# Bootstrap ROM

ASM=$(wildcard *.s)
EXE=$(ASM:.s=.run)
ROM=$(ASM:.s=.rom)
S68=$(ASM:.s=.s68)

VASM_FLAGS=-quiet -cnop=0x0000 -no-opt -I .. -I ../../../include -I /opt/amiga/m68k-amigaos/ndk-include

.PHONY: all prepare clean

all: $(ROM) $(S68)
	@echo > /dev/null
		
clean:
	@rm -f $(ROM) $(ROM:.rom=.rom.lst) $(S68) $(S68:.s68=.s68.lst)

%.rom: %.s Makefile
	vasmm68k_mot -Fbin $(VASM_FLAGS) $< -o $@ -L $(@D)/$(<F:.s=.rom.lst)

%.s68: %.s Makefile
	vasmm68k_mot -Fsrec $(VASM_FLAGS) $< -o $@ -L $(@D)/$(<F:.s=.s68.lst)
