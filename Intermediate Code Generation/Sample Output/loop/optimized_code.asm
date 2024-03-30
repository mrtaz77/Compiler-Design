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
	MOV AX, 0		; Line 3
	MOV [BP-4], AX
L3:
	MOV AX, 1		; Line 4
	MOV [BP-6], AX
L4:
	MOV AX, 0		; Line 5
	MOV [BP-8], AX
L5:
	MOV AX, [BP-8]		; Line 5
	PUSH AX
	MOV AX, 4		; Line 5
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JGE L7
	MOV AX, 1		; Line 5
	JMP L8
L7:
	XOR AX, AX		; Line 5
L8:
L9:
	CMP AX, 0
	JE L6
	MOV AX, 3		; Line 6
	MOV [BP-2], AX
L10:
L11:
	MOV AX, [BP-2]		; Line 7
	PUSH AX
	DEC AX
	MOV [BP-2], AX
	POP AX		; Line 7
	CMP AX, 0
	JE L12
	MOV AX, [BP-4]		; Line 8
	PUSH AX
	INC AX
	MOV [BP-4], AX
	POP AX		; Line 8
L13:
	JMP L11
L12:
	MOV AX, [BP-8]		; Line 5
	PUSH AX
	INC AX
	MOV [BP-8], AX
	POP AX		; Line 5
	JMP L5
L6:
	MOV AX, [BP-2]		; Line 11
	CALL println
L14:
	MOV AX, [BP-4]		; Line 12
	CALL println
L15:
	MOV AX, [BP-6]		; Line 13
	CALL println
L16:
	MOV AX, 0		; Line 14
	ADD SP, 8
	JMP L1
L17:
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