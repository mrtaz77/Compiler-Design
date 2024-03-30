;-------------------------------
;         asm code generator
;-------------------------------
.MODEL SMALL ; SCOPE OF CODE
.STACK 1000H ; ALLOCATE MEMORY IN HEXADECIMAL
.DATA ; VARIABLE DECLARATION
	number DB "00000$"
	a DW 1 DUP (0000H)
	b DW 1 DUP (0000H)
	c DW 1 DUP (0000H)
.CODE
;-------------------------------
;         Function : func_a
;-------------------------------
func_a PROC
	PUSH BP
	MOV BP, SP
	MOV AX, 7		; Line 4
	MOV a, AX
L2:
L1:
	POP BP
	RET 
func_a ENDP
;-------------------------------
;         Function : foo
;-------------------------------
foo PROC
	PUSH BP
	MOV BP, SP
	MOV AX, [BP+4]		; Line 8
	PUSH AX
	MOV AX, 3		; Line 8
	POP BX
	XCHG AX, BX
	ADD AX, BX
	MOV [BP+4], AX
L4:
	MOV AX, [BP+4]		; Line 9
	JMP L3
L5:
L3:
	POP BP
	RET 2
foo ENDP
;-------------------------------
;         Function : bar
;-------------------------------
bar PROC
	PUSH BP
	MOV BP, SP
	MOV AX, 4		; Line 14
	PUSH AX
	MOV AX, [BP+6]		; Line 14
	POP CX
	XCHG AX, CX
	CWD
	IMUL CX
	PUSH AX
	MOV AX, 2		; Line 14
	PUSH AX
	MOV AX, [BP+4]		; Line 14
	POP CX
	XCHG AX, CX
	CWD
	IMUL CX
	POP BX
	XCHG AX, BX
	ADD AX, BX
	MOV c, AX
L7:
	MOV AX, c		; Line 15
	JMP L6
L8:
L6:
	POP BP
	RET 4
bar ENDP
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
L10:
	MOV AX, 5		; Line 22
	MOV [BP-2], AX
L11:
	MOV AX, 6		; Line 23
	MOV [BP-4], AX
L12:
	PUSH BX
	PUSH CX
	CALL func_a
	POP CX
	POP BX
L13:
	MOV AX, a		; Line 26
	CALL println
L14:
	PUSH BX
	PUSH CX
	MOV AX, [BP-2]		; Line 28
	PUSH AX
	CALL foo
	POP CX
	POP BX
	MOV [BP-6], AX
L15:
	MOV AX, [BP-6]		; Line 29
	CALL println
L16:
	PUSH BX
	PUSH CX
	MOV AX, [BP-2]		; Line 31
	PUSH AX
	MOV AX, [BP-4]		; Line 31
	PUSH AX
	CALL bar
	POP CX
	POP BX
	MOV [BP-8], AX
L17:
	MOV AX, [BP-8]		; Line 32
	CALL println
L18:
	MOV AX, 6		; Line 34
	PUSH AX
	PUSH BX
	PUSH CX
	MOV AX, [BP-2]		; Line 34
	PUSH AX
	MOV AX, [BP-4]		; Line 34
	PUSH AX
	CALL bar
	POP CX
	POP BX
	POP CX
	XCHG AX, CX
	CWD
	IMUL CX
	PUSH AX
	MOV AX, 2		; Line 34
	POP BX
	XCHG AX, BX
	ADD AX, BX
	PUSH AX
	MOV AX, 3		; Line 34
	PUSH AX
	PUSH BX
	PUSH CX
	MOV AX, [BP-2]		; Line 34
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
	SUB AX, BX
	MOV [BP-4], AX
L19:
	MOV AX, [BP-4]		; Line 35
	CALL println
L20:
	MOV AX, 0		; Line 38
	ADD SP, 8
	JMP L9
L21:
L9:
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