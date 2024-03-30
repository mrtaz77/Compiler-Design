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
	SUB SP, 2
L2:
	MOV AX, 0		; Line 5
	MOV [BP-2], AX
	PUSH AX
	POP AX
L3:
	MOV AX, [BP-2]		; Line 5
	PUSH AX
	MOV AX, 6		; Line 5
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JGE L5
	MOV AX, 1		; Line 5
	JMP L6
L5:
	XOR AX, AX		; Line 5
L6:
L7:
	CMP AX, 0
	JE L4
	MOV AX, [BP-2]		; Line 6
	CALL println
L8:
	MOV AX, [BP-2]		; Line 5
	PUSH AX
	INC AX
	MOV [BP-2], AX
	POP AX		; Line 5
	JMP L3
L4:
	MOV AX, 4		; Line 9
	MOV [BP-6], AX
	PUSH AX
	POP AX
L9:
	MOV AX, 6		; Line 10
	MOV [BP-8], AX
	PUSH AX
	POP AX
L10:
L11:
	MOV AX, [BP-6]		; Line 11
	PUSH AX
	MOV AX, 0		; Line 11
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JLE L13
	MOV AX, 1		; Line 11
	JMP L14
L13:
	XOR AX, AX		; Line 11
L14:
	CMP AX, 0
	JE L12
	MOV AX, [BP-8]		; Line 12
	PUSH AX
	MOV AX, 3		; Line 12
	POP BX
	XCHG AX, BX
	ADD AX, BX
	PUSH AX
	POP AX		; Line 12
	MOV [BP-8], AX
	PUSH AX
	POP AX
L15:
	MOV AX, [BP-6]		; Line 13
	PUSH AX
	DEC AX
	MOV [BP-6], AX
	POP AX		; Line 13
L16:
	JMP L11
L12:
	MOV AX, [BP-8]		; Line 16
	CALL println
L17:
	MOV AX, [BP-6]		; Line 17
	CALL println
L18:
	MOV AX, 4		; Line 19
	MOV [BP-6], AX
	PUSH AX
	POP AX
L19:
	MOV AX, 6		; Line 20
	MOV [BP-8], AX
	PUSH AX
	POP AX
L20:
L21:
	MOV AX, [BP-6]		; Line 22
	PUSH AX
	DEC AX
	MOV [BP-6], AX
	POP AX		; Line 22
	CMP AX, 0
	JE L22
	MOV AX, [BP-8]		; Line 23
	PUSH AX
	MOV AX, 3		; Line 23
	POP BX
	XCHG AX, BX
	ADD AX, BX
	PUSH AX
	POP AX		; Line 23
	MOV [BP-8], AX
	PUSH AX
	POP AX
L23:
	JMP L21
L22:
	MOV AX, [BP-8]		; Line 26
	CALL println
L24:
	MOV AX, [BP-6]		; Line 27
	CALL println
L25:
	MOV AX, 0		; Line 30
	ADD SP, 8
	JMP L1
L26:
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