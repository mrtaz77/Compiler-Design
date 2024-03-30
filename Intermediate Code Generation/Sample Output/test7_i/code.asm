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
L2:
	MOV AX, [BP-2]		; Line 3
	PUSH AX
	MOV AX, 0		; Line 3
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JLE L6
	MOV AX, 1		; Line 3
	JMP L7
L6:
	XOR AX, AX		; Line 3
L7:
	CMP AX, 0
	JNE L3
	MOV AX, [BP-2]		; Line 3
	PUSH AX
	MOV AX, 10		; Line 3
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JGE L8
	MOV AX, 1		; Line 3
	JMP L9
L8:
	XOR AX, AX		; Line 3
L9:
	CMP AX, 0
	JE L4
L3:
	MOV AX, 1		; Line 3
	JMP L5
L4:
	XOR AX, AX
L5:
	CMP AX, 0
	JE L10
	MOV AX, 100		; Line 4
	MOV [BP-2], AX
	PUSH AX
	POP AX
L12:
	JMP L11
L10:
	MOV AX, 200		; Line 6
	MOV [BP-2], AX
	PUSH AX
	POP AX
L13:
L11:
	MOV AX, [BP-2]		; Line 8
	PUSH AX
	MOV AX, 20		; Line 8
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JLE L17
	MOV AX, 1		; Line 8
	JMP L18
L17:
	XOR AX, AX		; Line 8
L18:
	CMP AX, 0
	JE L15
	MOV AX, [BP-2]		; Line 8
	PUSH AX
	MOV AX, 30		; Line 8
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JGE L19
	MOV AX, 1		; Line 8
	JMP L20
L19:
	XOR AX, AX		; Line 8
L20:
	CMP AX, 0
	JE L15
L14:
	MOV AX, 1		; Line 8
	JMP L16
L15:
	XOR AX, AX
L16:
	CMP AX, 0
	JE L21
	MOV AX, 300		; Line 9
	MOV [BP-2], AX
	PUSH AX
	POP AX
L23:
	JMP L22
L21:
	MOV AX, 400		; Line 11
	MOV [BP-2], AX
	PUSH AX
	POP AX
L24:
L22:
	MOV AX, [BP-2]		; Line 13
	PUSH AX
	MOV AX, 40		; Line 13
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JLE L31
	MOV AX, 1		; Line 13
	JMP L32
L31:
	XOR AX, AX		; Line 13
L32:
	CMP AX, 0
	JE L29
	MOV AX, [BP-2]		; Line 13
	PUSH AX
	MOV AX, 50		; Line 13
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JGE L33
	MOV AX, 1		; Line 13
	JMP L34
L33:
	XOR AX, AX		; Line 13
L34:
	CMP AX, 0
	JE L29
L28:
	MOV AX, 1		; Line 13
	JMP L30
L29:
	XOR AX, AX
L30:
	CMP AX, 0
	JNE L25
	MOV AX, [BP-2]		; Line 13
	PUSH AX
	MOV AX, 60		; Line 13
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JGE L38
	MOV AX, 1		; Line 13
	JMP L39
L38:
	XOR AX, AX		; Line 13
L39:
	CMP AX, 0
	JE L36
	MOV AX, [BP-2]		; Line 13
	PUSH AX
	MOV AX, 70		; Line 13
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JLE L40
	MOV AX, 1		; Line 13
	JMP L41
L40:
	XOR AX, AX		; Line 13
L41:
	CMP AX, 0
	JE L36
L35:
	MOV AX, 1		; Line 13
	JMP L37
L36:
	XOR AX, AX
L37:
	CMP AX, 0
	JE L26
L25:
	MOV AX, 1		; Line 13
	JMP L27
L26:
	XOR AX, AX
L27:
	CMP AX, 0
	JE L42
	MOV AX, 500		; Line 14
	MOV [BP-2], AX
	PUSH AX
	POP AX
L44:
	JMP L43
L42:
	MOV AX, 600		; Line 16
	MOV [BP-2], AX
	PUSH AX
	POP AX
L45:
L43:
	MOV AX, [BP-2]		; Line 17
	CALL println
L46:
	MOV AX, 0		; Line 19
	ADD SP, 2
	JMP L1
L47:
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