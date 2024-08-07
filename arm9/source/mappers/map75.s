;@----------------------------------------------------------------------------
	#include "equates.h"
;@----------------------------------------------------------------------------
	.global mapper75init
	.global mapper151init

	.struct mapperData
map75ar0:	.byte 0
map75ar1:	.byte 0
map75sel:	.byte 0
;@----------------------------------------------------------------------------
.section .text,"ax"
;@----------------------------------------------------------------------------
;@ Konami VRC1
;@ Used in:
;@ Exciting Boxing
;@ Ganbare Goemon! Karakuri Douchuu
;@ Jajamaru Ninpouchou
;@ King Kong 2: Ikari no Megaton Punch
;@ Moero!! Junior Basket: Two on Two
;@ Tetsuwan Atom
mapper75init:
;@----------------------------------------------------------------------------
	.word write8000,writeA000,writeC000,writeE000

	bx lr
;@----------------------------------------------------------------------------
;@ Mapper 75 but for VS system, missing mirror capability, allways 4 screen.
mapper151init:
;@----------------------------------------------------------------------------
	.word write8000,writeA000,writeC000,writeE000

	ldrb_ r0,cartFlags
	orr r0,r0,#VS
	strb_ r0,cartFlags

	bx lr
;@----------------------------------------------------------------------------
write8000:
;@----------------------------------------------------------------------------
	tst addy,#0x1000
	beq map89_

write9000:
	strb_ r0,map75sel
	mov addy,r0
	stmfd sp!,{lr}
	tst r0,#1
	bl mirror2V_
	ldrb_ r1,map75ar0
	and r0,addy,#2
	orr r0,r1,r0,lsl#3
	bl chr0123_

	ldmfd sp!,{lr}
	ldrb_ r1,map75ar1
	and r0,addy,#4
	orr r0,r1,r0,lsl#2
	b chr4567_
;@----------------------------------------------------------------------------
writeA000:
;@----------------------------------------------------------------------------
	tst addy,#0x1000
	beq mapAB_

writeB000:
	bx lr
;@----------------------------------------------------------------------------
writeC000:
;@----------------------------------------------------------------------------
	tst addy,#0x1000
	beq mapCD_

writeD000:
	bx lr
;@----------------------------------------------------------------------------
writeE000:
;@----------------------------------------------------------------------------
	and r0,r0,#0xF
	ldrb_ r1,map75sel
	tst addy,#0x1000
	bne writeF000
	strb_ r0,map75ar0
	and r1,r1,#2
	orr r0,r0,r1,lsl#3
	b chr0123_

writeF000:
	strb_ r0,map75ar1
	and r1,r1,#4
	orr r0,r0,r1,lsl#2
	b chr4567_

	bx lr
;@----------------------------------------------------------------------------
