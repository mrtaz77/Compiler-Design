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
	SUB SP, 2
L3:
	MOV AX, 2		; Line 4
	MOV [BP-2], AX
	PUSH AX
	POP AX
L4:
	MOV AX, 3		; Line 5
	MOV [BP-4], AX
	PUSH AX
	POP AX
L5:
L6:
	MOV AX, [BP-2]		; Line 6
	PUSH AX
	MOV AX, 0		; Line 6
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JLE L8
	MOV AX, 1		; Line 6
	JMP L9
L8:
	XOR AX, AX		; Line 6
L9:
	CMP AX, 0
	JE L7
	SUB SP, 2
L10:
	MOV AX, [BP-2]		; Line 8
	MOV [BP-6], AX
	PUSH AX
	POP AX
L11:
L12:
	MOV AX, [BP-6]		; Line 9
	PUSH AX
	MOV AX, 0		; Line 9
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JLE L14
	MOV AX, 1		; Line 9
	JMP L15
L14:
	XOR AX, AX		; Line 9
L15:
	CMP AX, 0
	JE L13
	SUB SP, 2
L16:
	MOV AX, [BP-6]		; Line 11
	MOV [BP-8], AX
	PUSH AX
	POP AX
L17:
	MOV AX, [BP-6]		; Line 12
	PUSH AX
	DEC AX
	MOV [BP-6], AX
	POP AX		; Line 12
L18:
	MOV AX, [BP-8]		; Line 13
	CALL println
L19:
	ADD SP, 2
	JMP L12
L13:
	MOV AX, [BP-2]		; Line 15
	PUSH AX
	DEC AX
	MOV [BP-2], AX
	POP AX		; Line 15
L20:
	MOV AX, [BP-6]		; Line 16
	CALL println
L21:
	ADD SP, 2
	JMP L6
L7:
	MOV AX, [BP-2]		; Line 18
	CALL println
L22:
	MOV AX, [BP-4]		; Line 19
	CALL println
L23:
	MOV AX, 0		; Line 20
	ADD SP, 4
	JMP L1
L24:
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