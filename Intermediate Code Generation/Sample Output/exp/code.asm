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
	SUB SP, 6
L2:
	MOV AX, 1		; Line 3
	PUSH AX
	MOV AX, 2		; Line 3
	PUSH AX
	MOV AX, 3		; Line 3
	POP BX
	XCHG AX, BX
	ADD AX, BX
	PUSH AX
	POP AX		; Line 3
	POP CX
	XCHG AX, CX
	CWD
	IMUL CX
	PUSH AX
	POP AX		; Line 3
	PUSH AX
	MOV AX, 3		; Line 3
	POP CX
	XCHG AX, CX
	CWD
	IDIV CX
	PUSH DX
	POP AX		; Line 3
	MOV [BP-2], AX
	PUSH AX
	POP AX
L3:
	MOV AX, 1		; Line 4
	PUSH AX
	MOV AX, 5		; Line 4
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JGE L4
	MOV AX, 1		; Line 4
	JMP L5
L4:
	XOR AX, AX		; Line 4
L5:
	MOV [BP-4], AX
	PUSH AX
	POP AX
L6:
	MOV AX, 0		; Line 5
	PUSH BX
	PUSH CX
	PUSH AX
	MOV AX, 2		; Line 5
	POP BX
	PUSH AX
	MOV AX, 2
	IMUL BX
	MOV BX, AX
	MOV AX, 10
	SUB AX, BX
	MOV SI, AX
	POP AX
	NEG SI
	MOV [BP+SI], AX
	POP CX
	POP BX
	PUSH AX
	POP AX
L7:
	MOV AX, [BP-2]		; Line 6
	CMP AX, 0
	JE L9
	MOV AX, [BP-4]		; Line 6
	CMP AX, 0
	JE L9
L8:
	MOV AX, 1		; Line 6
	JMP L10
L9:
	XOR AX, AX
L10:
	CMP AX, 0
	JE L11
	MOV AX, 0		; Line 7
	PUSH BX
	PUSH CX
	PUSH AX
	POP CX
	PUSH CX
	POP BX
	MOV AX, 2		; Line 7
	IMUL BX
	MOV BX, AX
	MOV AX, 10
	SUB AX, BX
	MOV SI, AX
	NEG SI
	MOV AX, [BP+SI]
	PUSH AX
	INC AX
	MOV BX, CX
	PUSH AX
	MOV AX, 2
	IMUL BX
	MOV BX, AX
	MOV AX, 10
	SUB AX, BX
	MOV SI, AX
	POP AX
	NEG SI
	MOV [BP+SI], AX
	POP AX
	POP CX
	POP BX
	PUSH AX
	POP AX		; Line 7
L13:
	JMP L12
L11:
	MOV AX, 1		; Line 9
	PUSH BX
	PUSH CX
	PUSH AX
	MOV AX, 0		; Line 9
	PUSH BX
	PUSH CX
	PUSH AX
	POP BX
	MOV AX, 2		; Line 9
	IMUL BX
	MOV BX, AX
	MOV AX, 10
	SUB AX, BX
	MOV SI, AX
	NEG SI
	MOV AX, [BP+SI]
	POP CX
	POP BX
	POP BX
	PUSH AX
	MOV AX, 2
	IMUL BX
	MOV BX, AX
	MOV AX, 10
	SUB AX, BX
	MOV SI, AX
	POP AX
	NEG SI
	MOV [BP+SI], AX
	POP CX
	POP BX
	PUSH AX
	POP AX
L14:
L12:
	MOV AX, [BP-2]		; Line 10
	CALL println
L15:
	MOV AX, [BP-4]		; Line 11
	CALL println
L16:
	MOV AX, 0		; Line 12
	ADD SP, 10
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