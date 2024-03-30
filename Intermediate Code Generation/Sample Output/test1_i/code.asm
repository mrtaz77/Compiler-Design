;-------------------------------
;         asm code generator
;-------------------------------
.MODEL SMALL ; SCOPE OF CODE
.STACK 1000H ; ALLOCATE MEMORY IN HEXADECIMAL
.DATA ; VARIABLE DECLARATION
	number DB "00000$"
	i DW 1 DUP (0000H)
	j DW 1 DUP (0000H)
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
	SUB SP, 2
	SUB SP, 2
L2:
	MOV AX, 1		; Line 6
	MOV i, AX
	PUSH AX
	POP AX
L3:
	MOV AX, i		; Line 7
	CALL println
L4:
	MOV AX, 5		; Line 9
	PUSH AX
	MOV AX, 8		; Line 9
	POP BX
	XCHG AX, BX
	ADD AX, BX
	PUSH AX
	POP AX		; Line 9
	MOV j, AX
	PUSH AX
	POP AX
L5:
	MOV AX, j		; Line 10
	CALL println
L6:
	MOV AX, i		; Line 12
	PUSH AX
	MOV AX, 2		; Line 12
	PUSH AX
	MOV AX, j		; Line 12
	POP CX
	XCHG AX, CX
	CWD
	IMUL CX
	PUSH AX
	POP AX		; Line 12
	POP BX
	XCHG AX, BX
	ADD AX, BX
	PUSH AX
	POP AX		; Line 12
	MOV [BP-2], AX
	PUSH AX
	POP AX
L7:
	MOV AX, [BP-2]		; Line 13
	CALL println
L8:
	MOV AX, [BP-2]		; Line 15
	PUSH AX
	MOV AX, 9		; Line 15
	POP CX
	XCHG AX, CX
	CWD
	IDIV CX
	PUSH DX
	POP AX		; Line 15
	MOV [BP-6], AX
	PUSH AX
	POP AX
L9:
	MOV AX, [BP-6]		; Line 16
	CALL println
L10:
	MOV AX, [BP-6]		; Line 18
	PUSH AX
	MOV AX, [BP-4]		; Line 18
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JG L11
	MOV AX, 1		; Line 18
	JMP L12
L11:
	XOR AX, AX		; Line 18
L12:
	MOV [BP-8], AX
	PUSH AX
	POP AX
L13:
	MOV AX, [BP-8]		; Line 19
	CALL println
L14:
	MOV AX, i		; Line 21
	PUSH AX
	MOV AX, j		; Line 21
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JE L15
	MOV AX, 1		; Line 21
	JMP L16
L15:
	XOR AX, AX		; Line 21
L16:
	MOV [BP-10], AX
	PUSH AX
	POP AX
L17:
	MOV AX, [BP-10]		; Line 22
	CALL println
L18:
	MOV AX, [BP-8]		; Line 24
	CMP AX, 0
	JNE L19
	MOV AX, [BP-10]		; Line 24
	CMP AX, 0
	JE L20
L19:
	MOV AX, 1		; Line 24
	JMP L21
L20:
	XOR AX, AX
L21:
	MOV [BP-12], AX
	PUSH AX
	POP AX
L22:
	MOV AX, [BP-12]		; Line 25
	CALL println
L23:
	MOV AX, [BP-8]		; Line 27
	CMP AX, 0
	JE L25
	MOV AX, [BP-10]		; Line 27
	CMP AX, 0
	JE L25
L24:
	MOV AX, 1		; Line 27
	JMP L26
L25:
	XOR AX, AX
L26:
	MOV [BP-12], AX
	PUSH AX
	POP AX
L27:
	MOV AX, [BP-12]		; Line 28
	CALL println
L28:
	MOV AX, [BP-12]		; Line 30
	PUSH AX
	INC AX
	MOV [BP-12], AX
	POP AX		; Line 30
L29:
	MOV AX, [BP-12]		; Line 31
	CALL println
L30:
	MOV AX, [BP-12]		; Line 33
	NEG AX
	PUSH AX
	POP AX		; Line 33
	MOV [BP-2], AX
	PUSH AX
	POP AX
L31:
	MOV AX, [BP-2]		; Line 34
	CALL println
L32:
	MOV AX, 0		; Line 36
	ADD SP, 12
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