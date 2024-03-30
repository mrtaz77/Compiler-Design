;-------------------------------
;         asm code generator
;-------------------------------
.MODEL SMALL ; SCOPE OF CODE
.STACK 1000H ; ALLOCATE MEMORY IN HEXADECIMAL
.DATA ; VARIABLE DECLARATION
	number DB "00000$"
.CODE
;-------------------------------
;         Function : func
;-------------------------------
func PROC
	PUSH BP
	MOV BP, SP
	SUB SP, 2
L2:
	MOV AX, [BP+4]		; Line 3
	PUSH AX
	MOV AX, 0		; Line 3
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JNE L3
	MOV AX, 1		; Line 3
	JMP L4
L3:
	XOR AX, AX		; Line 3
L4:
	CMP AX, 0
	JE L5
	MOV AX, 0		; Line 3
	ADD SP, 2
	JMP L1
L6:
L5:
	MOV AX, [BP+4]		; Line 4
	MOV [BP-2], AX
	PUSH AX
	POP AX
L7:
	PUSH BX
	PUSH CX
	MOV AX, [BP+4]		; Line 5
	PUSH AX
	MOV AX, 1		; Line 5
	POP BX
	XCHG AX, BX
	SUB AX, BX
	PUSH AX
	POP AX		; Line 5
	PUSH AX
	CALL func
	POP CX
	POP BX
	PUSH AX
	POP AX		; Line 5
	PUSH AX
	MOV AX, [BP-2]		; Line 5
	POP BX
	XCHG AX, BX
	ADD AX, BX
	PUSH AX
	POP AX		; Line 5
	JMP L1
L8:
L1:
	POP BP
	RET 2
func ENDP
;-------------------------------
;         Function : func2
;-------------------------------
func2 PROC
	PUSH BP
	MOV BP, SP
	SUB SP, 2
L10:
	MOV AX, [BP+4]		; Line 10
	PUSH AX
	MOV AX, 0		; Line 10
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JNE L11
	MOV AX, 1		; Line 10
	JMP L12
L11:
	XOR AX, AX		; Line 10
L12:
	CMP AX, 0
	JE L13
	MOV AX, 0		; Line 10
	ADD SP, 2
	JMP L9
L14:
L13:
	MOV AX, [BP+4]		; Line 11
	MOV [BP-2], AX
	PUSH AX
	POP AX
L15:
	PUSH BX
	PUSH CX
	MOV AX, [BP+4]		; Line 12
	PUSH AX
	MOV AX, 1		; Line 12
	POP BX
	XCHG AX, BX
	SUB AX, BX
	PUSH AX
	POP AX		; Line 12
	PUSH AX
	CALL func
	POP CX
	POP BX
	PUSH AX
	POP AX		; Line 12
	PUSH AX
	MOV AX, [BP-2]		; Line 12
	POP BX
	XCHG AX, BX
	ADD AX, BX
	PUSH AX
	POP AX		; Line 12
	JMP L9
L16:
L9:
	POP BP
	RET 2
func2 ENDP
;-------------------------------
;         Function : main
;-------------------------------
main PROC
	MOV AX, @DATA
	MOV DS, AX
	PUSH BP
	MOV BP, SP
	SUB SP, 2
L18:
	PUSH BX
	PUSH CX
	MOV AX, 7		; Line 17
	PUSH AX
	CALL func
	POP CX
	POP BX
	PUSH AX
	POP AX		; Line 17
	MOV [BP-2], AX
	PUSH AX
	POP AX
L19:
	MOV AX, [BP-2]		; Line 18
	CALL println
L20:
	MOV AX, 0		; Line 19
	ADD SP, 2
	JMP L17
L21:
L17:
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