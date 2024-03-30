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
	SUB SP, 2
L2:
	MOV AX, 5		; Line 3
	MOV [BP-2], AX
	PUSH AX
	POP AX
L3:
L4:
	MOV AX, [BP-2]		; Line 4
	PUSH AX
	MOV AX, 0		; Line 4
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JLE L6
	MOV AX, 1		; Line 4
	JMP L7
L6:
	XOR AX, AX		; Line 4
L7:
	CMP AX, 0
	JE L5
	MOV AX, [BP+4]		; Line 5
	PUSH AX
	INC AX
	MOV [BP+4], AX
	POP AX		; Line 5
L8:
	MOV AX, [BP-2]		; Line 6
	PUSH AX
	DEC AX
	MOV [BP-2], AX
	POP AX		; Line 6
L9:
	JMP L4
L5:
	MOV AX, 3		; Line 8
	PUSH AX
	MOV AX, [BP+4]		; Line 8
	POP CX
	XCHG AX, CX
	CWD
	IMUL CX
	PUSH AX
	POP AX		; Line 8
	PUSH AX
	MOV AX, 7		; Line 8
	POP BX
	XCHG AX, BX
	SUB AX, BX
	PUSH AX
	POP AX		; Line 8
	ADD SP, 2
	JMP L1
L10:
	MOV AX, 9		; Line 9
	MOV [BP+4], AX
	PUSH AX
	POP AX
L11:
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
	SUB SP, 2
L13:
	PUSH BX
	PUSH CX
	MOV AX, [BP+6]		; Line 15
	PUSH AX
	CALL f
	POP CX
	POP BX
	PUSH AX
	POP AX		; Line 15
	PUSH AX
	MOV AX, [BP+6]		; Line 15
	POP BX
	XCHG AX, BX
	ADD AX, BX
	PUSH AX
	POP AX		; Line 15
	PUSH AX
	MOV AX, [BP+4]		; Line 15
	POP BX
	XCHG AX, BX
	ADD AX, BX
	PUSH AX
	POP AX		; Line 15
	MOV [BP-2], AX
	PUSH AX
	POP AX
L14:
	MOV AX, 0		; Line 17
	MOV [BP-4], AX
	PUSH AX
	POP AX
L15:
	MOV AX, [BP-4]		; Line 17
	PUSH AX
	MOV AX, 7		; Line 17
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JGE L17
	MOV AX, 1		; Line 17
	JMP L18
L17:
	XOR AX, AX		; Line 17
L18:
L19:
	CMP AX, 0
	JE L16
	MOV AX, [BP-4]		; Line 18
	PUSH AX
	MOV AX, 3		; Line 18
	POP CX
	XCHG AX, CX
	CWD
	IDIV CX
	PUSH DX
	POP AX		; Line 18
	PUSH AX
	MOV AX, 0		; Line 18
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JNE L20
	MOV AX, 1		; Line 18
	JMP L21
L20:
	XOR AX, AX		; Line 18
L21:
	CMP AX, 0
	JE L22
	MOV AX, [BP-2]		; Line 19
	PUSH AX
	MOV AX, 5		; Line 19
	POP BX
	XCHG AX, BX
	ADD AX, BX
	PUSH AX
	POP AX		; Line 19
	MOV [BP-2], AX
	PUSH AX
	POP AX
L24:
	JMP L23
L22:
	MOV AX, [BP-2]		; Line 22
	PUSH AX
	MOV AX, 1		; Line 22
	POP BX
	XCHG AX, BX
	SUB AX, BX
	PUSH AX
	POP AX		; Line 22
	MOV [BP-2], AX
	PUSH AX
	POP AX
L25:
L23:
	MOV AX, [BP-4]		; Line 17
	PUSH AX
	INC AX
	MOV [BP-4], AX
	POP AX		; Line 17
	JMP L15
L16:
	MOV AX, [BP-2]		; Line 25
	ADD SP, 4
	JMP L12
L26:
L12:
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
	SUB SP, 2
L28:
	MOV AX, 1		; Line 30
	MOV [BP-2], AX
	PUSH AX
	POP AX
L29:
	MOV AX, 2		; Line 31
	MOV [BP-4], AX
	PUSH AX
	POP AX
L30:
	PUSH BX
	PUSH CX
	MOV AX, [BP-2]		; Line 32
	PUSH AX
	MOV AX, [BP-4]		; Line 32
	PUSH AX
	CALL g
	POP CX
	POP BX
	PUSH AX
	POP AX		; Line 32
	MOV [BP-2], AX
	PUSH AX
	POP AX
L31:
	MOV AX, [BP-2]		; Line 33
	CALL println
L32:
	MOV AX, 0		; Line 34
	MOV [BP-6], AX
	PUSH AX
	POP AX
L33:
	MOV AX, [BP-6]		; Line 34
	PUSH AX
	MOV AX, 4		; Line 34
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JGE L35
	MOV AX, 1		; Line 34
	JMP L36
L35:
	XOR AX, AX		; Line 34
L36:
L37:
	CMP AX, 0
	JE L34
	MOV AX, 3		; Line 35
	MOV [BP-2], AX
	PUSH AX
	POP AX
L38:
L39:
	MOV AX, [BP-2]		; Line 36
	PUSH AX
	MOV AX, 0		; Line 36
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JLE L41
	MOV AX, 1		; Line 36
	JMP L42
L41:
	XOR AX, AX		; Line 36
L42:
	CMP AX, 0
	JE L40
	MOV AX, [BP-4]		; Line 37
	PUSH AX
	INC AX
	MOV [BP-4], AX
	POP AX		; Line 37
L43:
	MOV AX, [BP-2]		; Line 38
	PUSH AX
	DEC AX
	MOV [BP-2], AX
	POP AX		; Line 38
L44:
	JMP L39
L40:
	MOV AX, [BP-6]		; Line 34
	PUSH AX
	INC AX
	MOV [BP-6], AX
	POP AX		; Line 34
	JMP L33
L34:
	MOV AX, [BP-2]		; Line 41
	CALL println
L45:
	MOV AX, [BP-4]		; Line 42
	CALL println
L46:
	MOV AX, [BP-6]		; Line 43
	CALL println
L47:
	MOV AX, 0		; Line 44
	ADD SP, 6
	JMP L27
L48:
L27:
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