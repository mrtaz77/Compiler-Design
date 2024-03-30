;-------------------------------
;         asm code generator
;-------------------------------
.MODEL SMALL ; SCOPE OF CODE
.STACK 1000H ; ALLOCATE MEMORY IN HEXADECIMAL
.DATA ; VARIABLE DECLARATION
	number DB "00000$"
.CODE
;-------------------------------
;         Function : f
;-------------------------------
f PROC
	PUSH BP
	MOV BP, SP
	MOV AX, 2		; Line 2
	PUSH AX
	MOV AX, [BP+4]		; Line 2
	POP CX
	XCHG AX, CX
	CWD
	IMUL CX
	PUSH AX
	POP AX		; Line 2
	JMP L1
L2:
	MOV AX, 9		; Line 3
	MOV [BP+4], AX
	PUSH AX
	POP AX
L3:
L1:
	POP BP
	RET 2
f ENDP
;-------------------------------
;         Function : g
;-------------------------------
g PROC
	PUSH BP
	MOV BP, SP
	SUB SP, 2
L5:
	PUSH BX
	PUSH CX
	MOV AX, [BP+6]		; Line 8
	PUSH AX
	CALL f
	POP CX
	POP BX
	PUSH AX
	POP AX		; Line 8
	PUSH AX
	MOV AX, [BP+6]		; Line 8
	POP BX
	XCHG AX, BX
	ADD AX, BX
	PUSH AX
	POP AX		; Line 8
	PUSH AX
	MOV AX, [BP+4]		; Line 8
	POP BX
	XCHG AX, BX
	ADD AX, BX
	PUSH AX
	POP AX		; Line 8
	MOV [BP-2], AX
	PUSH AX
	POP AX
L6:
	MOV AX, [BP-2]		; Line 9
	ADD SP, 2
	JMP L4
L7:
L4:
	POP BP
	RET 4
g ENDP
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
L9:
	MOV AX, 1		; Line 14
	MOV [BP-2], AX
	PUSH AX
	POP AX
L10:
	MOV AX, 2		; Line 15
	MOV [BP-4], AX
	PUSH AX
	POP AX
L11:
	PUSH BX
	PUSH CX
	MOV AX, [BP-2]		; Line 16
	PUSH AX
	MOV AX, [BP-4]		; Line 16
	PUSH AX
	CALL g
	POP CX
	POP BX
	PUSH AX
	POP AX		; Line 16
	MOV [BP-2], AX
	PUSH AX
	POP AX
L12:
	MOV AX, [BP-2]		; Line 17
	CALL println
L13:
	MOV AX, 0		; Line 18
	ADD SP, 4
	JMP L8
L14:
L8:
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