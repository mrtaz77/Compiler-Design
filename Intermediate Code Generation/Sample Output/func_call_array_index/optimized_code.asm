;-------------------------------
;         asm code generator
;-------------------------------
.MODEL SMALL ; SCOPE OF CODE
.STACK 1000H ; ALLOCATE MEMORY IN HEXADECIMAL
.DATA ; VARIABLE DECLARATION
	number DB "00000$"
	global_array DW 10 DUP (0000H)
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
	SUB SP, 20
	SUB SP, 2
	SUB SP, 2
	SUB SP, 2
L2:
	MOV AX, 2		; Line 6
	PUSH AX
	MOV AX, 3		; Line 6
	POP BX
	XCHG AX, BX
	ADD AX, BX
	PUSH AX
	MOV AX, 4		; Line 6
	POP BX
	XCHG AX, BX
	ADD AX, BX
	MOV [BP-2], AX
L3:
	MOV AX, 2		; Line 7
	PUSH AX
	MOV AX, 3		; Line 7
	PUSH AX
	MOV AX, 5		; Line 7
	NEG AX
	POP CX
	XCHG AX, CX
	CWD
	IMUL CX
	POP BX
	XCHG AX, BX
	ADD AX, BX
	PUSH AX
	MOV AX, 9		; Line 7
	NEG AX
	POP BX
	XCHG AX, BX
	ADD AX, BX
	MOV [BP-24], AX
L4:
	PUSH BX
	PUSH CX
	MOV AX, 3		; Line 8
	PUSH AX
	MOV AX, 2		; Line 8
	PUSH AX
	CALL f1
	POP CX
	POP BX
	PUSH BX
	PUSH CX
	PUSH AX
	PUSH BX
	PUSH CX
	MOV AX, [BP-2]		; Line 8
	PUSH AX
	MOV AX, [BP-24]		; Line 8
	PUSH AX
	CALL f1
	POP CX
	POP BX
	POP BX
	PUSH AX
	MOV AX, 2
	IMUL BX
	MOV BX, AX
	POP AX
	MOV global_array[BX], AX
	POP CX
	POP BX
L5:
	PUSH BX
	PUSH CX
	MOV AX, 1		; Line 9
	PUSH AX
	MOV AX, 4		; Line 9
	PUSH AX
	CALL f1
	POP CX
	POP BX
	PUSH BX
	PUSH CX
	PUSH AX
	PUSH BX
	PUSH CX
	MOV AX, 16		; Line 9
	PUSH AX
	MOV AX, 5		; Line 9
	PUSH BX
	PUSH CX
	PUSH AX
	POP BX
	MOV AX, 2		; Line 9
	IMUL BX
	MOV BX, AX
	MOV AX, global_array[BX]
	POP CX
	POP BX
	PUSH AX
	CALL f1
	POP CX
	POP BX
	POP BX
	PUSH AX
	MOV AX, 2
	IMUL BX
	MOV BX, AX
	MOV AX, 22
	SUB AX, BX
	MOV SI, AX
	POP AX
	NEG SI
	MOV [BP+SI], AX
	POP CX
	POP BX
L6:
	PUSH BX
	PUSH CX
	MOV AX, 5		; Line 10
	PUSH BX
	PUSH CX
	PUSH AX
	POP BX
	MOV AX, 2		; Line 10
	IMUL BX
	MOV BX, AX
	MOV AX, global_array[BX]
	POP CX
	POP BX
	PUSH AX
	MOV AX, 18		; Line 10
	PUSH AX
	CALL f1
	POP CX
	POP BX
	PUSH BX
	PUSH CX
	PUSH AX
	POP BX
	MOV AX, 2		; Line 10
	IMUL BX
	MOV BX, AX
	MOV AX, global_array[BX]
	POP CX
	POP BX
	MOV [BP-26], AX
L7:
	PUSH BX
	PUSH CX
	MOV AX, 5		; Line 11
	PUSH BX
	PUSH CX
	PUSH AX
	POP BX
	MOV AX, 2		; Line 11
	IMUL BX
	MOV BX, AX
	MOV AX, 22
	SUB AX, BX
	MOV SI, AX
	NEG SI
	MOV AX, [BP+SI]
	POP CX
	POP BX
	PUSH AX
	MOV AX, 2		; Line 11
	PUSH AX
	CALL f1
	POP CX
	POP BX
	PUSH BX
	PUSH CX
	PUSH AX
	POP BX
	MOV AX, 2		; Line 11
	IMUL BX
	MOV BX, AX
	MOV AX, 22
	SUB AX, BX
	MOV SI, AX
	NEG SI
	MOV AX, [BP+SI]
	POP CX
	POP BX
	MOV [BP-28], AX
L8:
	MOV AX, [BP-26]		; Line 12
	CALL println
L9:
	MOV AX, [BP-28]		; Line 13
	CALL println
L10:
	MOV AX, 0		; Line 14
	ADD SP, 28
	JMP L1
L11:
L1:
	POP BP
	MOV AX, 4CH
	INT 21H
main ENDP
;-------------------------------
;         Function : f1
;-------------------------------
f1 PROC
	PUSH BP
	MOV BP, SP
	MOV AX, [BP+6]		; Line 18
	PUSH AX
	MOV AX, [BP+4]		; Line 18
	POP BX
	XCHG AX, BX
	ADD AX, BX
	JMP L12
L13:
L12:
	POP BP
	RET 4
f1 ENDP
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