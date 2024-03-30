;-------------------------------
;         asm code generator
;-------------------------------
.MODEL SMALL ; SCOPE OF CODE
.STACK 1000H ; ALLOCATE MEMORY IN HEXADECIMAL
.DATA ; VARIABLE DECLARATION
	number DB "00000$"
.CODE
;-------------------------------
;         Function : main
;-------------------------------
main PROC
	MOV AX, @DATA
	MOV DS, AX
	PUSH BP
	MOV BP, SP
	SUB SP, 2
	SUB SP, 2
	SUB SP, 2
L2:
	MOV AX, 3		; Line 5
	MOV [BP-2], AX
L3:
	MOV AX, 8		; Line 6
	MOV [BP-4], AX
L4:
	MOV AX, 6		; Line 7
	MOV [BP-6], AX
L5:
	MOV AX, [BP-2]		; Line 10
	PUSH AX
	MOV AX, 3		; Line 10
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JNE L6
	MOV AX, 1		; Line 10
	JMP L7
L6:
	XOR AX, AX		; Line 10
L7:
	CMP AX, 0
	JE L8
	MOV AX, [BP-4]		; Line 11
	CALL println
L9:
L8:
	MOV AX, [BP-4]		; Line 14
	PUSH AX
	MOV AX, 8		; Line 14
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JGE L10
	MOV AX, 1		; Line 14
	JMP L11
L10:
	XOR AX, AX		; Line 14
L11:
	CMP AX, 0
	JE L12
	MOV AX, [BP-2]		; Line 15
	CALL println
L14:
	JMP L13
L12:
	MOV AX, [BP-6]		; Line 18
	CALL println
L15:
L13:
	MOV AX, [BP-6]		; Line 21
	PUSH AX
	MOV AX, 6		; Line 21
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JE L16
	MOV AX, 1		; Line 21
	JMP L17
L16:
	XOR AX, AX		; Line 21
L17:
	CMP AX, 0
	JE L18
	MOV AX, [BP-6]		; Line 22
	CALL println
L20:
	JMP L19
L18:
	MOV AX, [BP-4]		; Line 24
	PUSH AX
	MOV AX, 8		; Line 24
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JLE L21
	MOV AX, 1		; Line 24
	JMP L22
L21:
	XOR AX, AX		; Line 24
L22:
	CMP AX, 0
	JE L23
	MOV AX, [BP-4]		; Line 25
	CALL println
L25:
	JMP L24
L23:
	MOV AX, [BP-2]		; Line 27
	PUSH AX
	MOV AX, 5		; Line 27
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JGE L26
	MOV AX, 1		; Line 27
	JMP L27
L26:
	XOR AX, AX		; Line 27
L27:
	CMP AX, 0
	JE L28
	MOV AX, [BP-2]		; Line 28
	CALL println
L30:
	JMP L29
L28:
	MOV AX, 0		; Line 31
	MOV [BP-6], AX
L31:
	MOV AX, [BP-6]		; Line 32
	CALL println
L32:
L29:
L24:
L19:
	MOV AX, 0		; Line 36
	ADD SP, 6
	JMP L1
L33:
L1:
	POP BP
	MOV AX, 4CH
	INT 21H
main ENDP
;-------------------------------
;         print library
;-------------------------------
;-------------------------------
println proc
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH SI
	LEA SI, number
	MOV BX, 10
	ADD SI, 4
	CMP AX, 0
	JNGE NEGATE
PRINT:
	XOR DX, DX
	DIV BX
	MOV [SI], DL
	ADD [SI], '0'
	DEC SI
	CMP AX, 0
	JNE PRINT
	INC SI
	LEA DX, SI
	MOV AH, 9
	INT 21H
	PUSH AX
	PUSH DX
	MOV AH, 2
	MOV DL, 0DH
	INT 21H
	MOV AH, 2
	MOV DL, 0AH
	INT 21H
	POP DX
	POP AX
	POP SI
	POP DX
	POP CX
	POP BX
	POP AX
	RET
NEGATE:
	PUSH AX
	MOV AH, 2
	MOV DL, '-'
	INT 21H
	POP AX
	NEG AX
	JMP PRINT
	println ENDP
END main