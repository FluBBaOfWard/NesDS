;@----------------------------------------------------------------------------
	#include "equates.h"
;@----------------------------------------------------------------------------
	.global mapper163init

	.struct mapperData
reg0:		.byte 0
reg1:		.byte 0
strobe:		.byte 0
security:	.byte 0
trigger:	.byte 0
romType:	.byte 0
;@----------------------------------------------------------------------------
.section .text,"ax"
;@----------------------------------------------------------------------------
;@ 南晶 (Nánjīng) FC-001 board
;@ Used in:
;@ 牧场物语 - Harvest Moon (NJ011)
;@ 水浒神兽 (Shuǐhǔ Shénshòu, NJ019)
;@ 暗黑破坏神 - Diablo (NJ037)
;@ 轩辕剑外传 之 天之痕 (Xuānyuánjiàn Wàizhuàn zhī Tiānzhīhén, NJ045)
;@ Final Fantasy IV - 最终幻想 4꞉ 光与暗 水晶纷争 (NJ098)
mapper163init:
;@----------------------------------------------------------------------------
	.word void, void, void, void

	mov r0, #0xFF
	strb_ r0, reg1
	mov r0, #1
	strb_ r0, strobe
	mov r0, #0
	strb_ r0, security
	strb_ r0, trigger
	strb_ r0, reg0
	strb_ r0, romType

	stmfd sp!, {lr}
	mov r0, #15
	bl map89ABCDEF_

	adr r0, readl
	str_ r0, rp2A03MemRead
	adr r0, writel
	str_ r0, rp2A03MemWrite
	adr r0,hook
	str_ r0,scanlineHook

	ldmfd sp!, {pc}

;@----------------------------------------------------------------------------
readl:
;@----------------------------------------------------------------------------
	cmp addy, #0x5000
	bcc empty_R
	and r0, addy, #0x7700
	cmp r0, #0x5100
	cmpne r0, #0x5500
	movne r0, #4
	bxne lr

	cmp r0, #0x5100
	ldreqb_ r0, security
	bxeq lr

	ldrb_ r0, trigger
	ands r0, r0, r0
	ldrneb_ r0, security
	bx lr

;@----------------------------------------------------------------------------
writel:
;@----------------------------------------------------------------------------
	cmp addy, #0x5000
	bcc empty_W

	mov r1, addy, lsr#8
	and r2, r1, #0x3
	cmp r2, #1
	movne r1, r2
	cmp r1, #4
	bxcs lr
	ldr r2, =wtbl
	ldr pc, [r2, r1, lsl#2]
;@---------------------
wtbl:
	.word w50, w51, w52, w53
;@---------------------
w50:
	strb_ r0, reg1
	and r0, r0, #0xF
	ldrb_ r1, reg0
	orr r0, r0, r1, lsl#4
	and r0, r0, #0xFF
	stmfd sp!, {lr}
	bl map89ABCDEF_
	ldrb_ r1, romType
	cmp r1, #1
	moveq r0, #0
	bleq chr01234567_
	ldmfd sp!, {lr}
	ldr_ r1, scanline
	cmp r1, #128
	bxcc lr
	ldrb_ r1, reg1
	tst r1, #0x80
	moveq r0, #0
	beq chr01234567_
	bx lr

w51:
	ands r1, addy, #0xFF
	bne w51_1
	cmp r0, #6
	moveq r0, #3
	beq map89ABCDEF_
	bx lr

w51_1:
	cmp r1, #1
	bxne lr				;@ This works?
	ldrb_ r1, strobe
	strb_ r0, strobe

	tst r0, #0xff
	bxne lr
	tst r1, #0xff
	bxeq lr
	strb_ r0, strobe
	ldrb_ r1, trigger
	eor r1, r1, #1
	strb_ r1, trigger
	bx lr

w52:
	strb_ r0, reg0
	and r0, r0, #0xF
	ldrb_ r1, reg1
	and r1, r1, #0xF
	orr r0, r1, r0, lsl#4
	b map89ABCDEF_

w53:
	strb_ r0, security
	bx lr

;@----------------------------------------------------------------------------
hook:
;@----------------------------------------------------------------------------
	ldrb_ r0, reg1
	tst r0, #0x80
	bxeq lr
	ldrb_ r0, ppuCtrl1
	tst r0, #0x18
	bxeq lr

	ldr_ r0, scanline
	cmp r0, #127
	bne 0f
	mov r0, #1
	stmfd sp!, {r0,lr}
	bl chr0123_
	ldmfd sp!, {r0,lr}
	b chr4567_

0:
	bhi 1f
	ldrb_ r0, romType
	eors r0, r0, #1
	bxne lr
	@ r0 = 0
	stmfd sp!, {r0,lr}
	bl chr0123_
	ldmfd sp!, {r0,lr}
	b chr4567_

1:
	subs r0, r0, #239
	bxne lr
	@ r0 = 0
	stmfd sp!, {r0,lr}
	bl chr0123_
	ldmfd sp!, {r0,lr}
	b chr4567_
;@----------------------------------------------------------------------------
