;-------------------------------
;         asm code generator
;-------------------------------
.MODEL SMALL ; SCOPE OF CODE
.STACK 1000H ; ALLOCATE MEMORY IN HEXADECIMAL
.DATA ; VARIABLE DECLARATION
	number DB "00000$"
.CODE
;-------------------------------
;         Function : foo
;-------------------------------
foo PROC
	PUSH BP
	MOV BP, SP
	MOV AX, [BP+6]		; Line 2
	PUSH AX
	MOV AX, [BP+4]		; Line 2
	POP BX
	XCHG AX, BX
	ADD AX, BX
	PUSH AX
	MOV AX, 5		; Line 2
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JG L2
	MOV AX, 1		; Line 2
	JMP L3
L2:
	XOR AX, AX		; Line 2
L3:
	CMP AX, 0
	JE L4
	MOV AX, 7		; Line 3
	JMP L1
L5:
L4:
	PUSH BX
	PUSH CX
	MOV AX, [BP+6]		; Line 5
	PUSH AX
	MOV AX, 2		; Line 5
	POP BX
	XCHG AX, BX
	SUB AX, BX
	PUSH AX
	MOV AX, [BP+4]		; Line 5
	PUSH AX
	MOV AX, 1		; Line 5
	POP BX
	XCHG AX, BX
	SUB AX, BX
	PUSH AX
	CALL foo
	POP CX
	POP BX
	PUSH AX
	MOV AX, 2		; Line 5
	PUSH AX
	PUSH BX
	PUSH CX
	MOV AX, [BP+6]		; Line 5
	PUSH AX
	MOV AX, 1		; Line 5
	POP BX
	XCHG AX, BX
	SUB AX, BX
	PUSH AX
	MOV AX, [BP+4]		; Line 5
	PUSH AX
	MOV AX, 2		; Line 5
	POP BX
	XCHG AX, BX
	SUB AX, BX
	PUSH AX
	CALL foo
	POP CX
	POP BX
	POP CX
	XCHG AX, CX
	CWD
	IMUL CX
	POP BX
	XCHG AX, BX
	ADD AX, BX
	JMP L1
L6:
L1:
	POP BP
	RET 4
foo ENDP
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
L8:
	MOV AX, 7		; Line 11
	MOV [BP-2], AX
L9:
	MOV AX, 3		; Line 12
	MOV [BP-4], AX
L10:
	PUSH BX
	PUSH CX
	MOV AX, [BP-2]		; Line 14
	PUSH AX
	MOV AX, [BP-4]		; Line 14
	PUSH AX
	CALL foo
	POP CX
	POP BX
	MOV [BP-6], AX
L11:
	MOV AX, [BP-6]		; Line 15
	CALL println
L12:
	MOV AX, 0		; Line 17
	ADD SP, 6
	JMP L7
L13:
L7:
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