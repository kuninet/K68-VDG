#
# Makefile
#

.SUFFIXES: .asm .p .hex .sr

all:	asciilist.hex asciilist.sr

.p.hex:
	p2hex -F Intel $*.p $*.hex

.p.sr:
	p2hex -F Moto $*.p $*.sr

.asm.p:	config.inc
	asl -L $*.asm

clean:
	rm -f *.p *.hex *.sr *.lst
