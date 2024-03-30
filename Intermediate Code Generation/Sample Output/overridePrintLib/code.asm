;-------------------------------
;         asm code generator
;-------------------------------
.MODEL SMALL ; SCOPE OF CODE
.STACK 1000H ; ALLOCATE MEMORY IN HEXADECIMAL
.DATA ; VARIABLE DECLARATION
	number DB "00000$"
	a DW 1 DUP (0000H)
.CODE
;-------------------------------
;         Function : print_newline
;-------------------------------
print_newline PROC
	PUSH BP
	MOV BP, SP
	SUB SP, 2
L2:
	MOV AX, [BP+4]		; Line 5
	PUSH AX
	MOV AX, 1		; Line 5
	POP BX
	XCHG AX, BX
	ADD AX, BX
	PUSH AX
	POP AX		; Line 5
	MOV [BP-2], AX
	PUSH AX
	POP AX
L3:
	MOV AX, [BP-2]		; Line 6
	CALL println
L4:
L1:
	ADD SP, 2
	POP BP
	RET 2
print_newline ENDP
;-------------------------------
;         Function : print_output
;-------------------------------
print_output PROC
	PUSH BP
	MOV BP, SP
	MOV AX, [BP+4]		; Line 10
	MOV a, AX
	PUSH AX
	POP AX
L6:
	MOV AX, a		; Line 11
	CALL println
L7:
L5:
	POP BP
	RET 2
print_output ENDP
;-------------------------------
;         Function : var
;-------------------------------
var PROC
	PUSH BP
	MOV BP, SP
	MOV AX, 1		; Line 15
	MOV a, AX
	PUSH AX
	POP AX
L9:
	MOV AX, a		; Line 16
	PUSH AX
	MOV AX, 1		; Line 16
	POP BX
	XCHG AX, BX
	ADD AX, BX
	PUSH AX
	POP AX		; Line 16
	MOV a, AX
	PUSH AX
	POP AX
L10:
	MOV AX, a		; Line 17
	JMP L8
L11:
L8:
	POP BP
	RET 
var ENDP
;-------------------------------
;         Function : main
;-------------------------------
main PROC
	MOV AX, @DATA
	MOV DS, AX
	PUSH BP
	MOV BP, SP
	SUB SP, 2
L13:
	MOV AX, 10		; Line 22
	MOV [BP-2], AX
	PUSH AX
	POP AX
L14:
	PUSH BX
	PUSH CX
	MOV AX, [BP-2]		; Line 23
	PUSH AX
	CALL print_newline
	POP CX
	POP BX
	PUSH AX
	POP AX		; Line 23
L15:
	MOV AX, 31		; Line 24
	NEG AX
	PUSH AX
	POP AX		; Line 24
	MOV [BP-2], AX
	PUSH AX
	POP AX
L16:
	PUSH BX
	PUSH CX
	MOV AX, [BP-2]		; Line 25
	PUSH AX
	CALL print_output
	POP CX
	POP BX
	PUSH AX
	POP AX		; Line 25
L17:
	MOV AX, a		; Line 26
	CALL println
L18:
	MOV AX, 0		; Line 27
	ADD SP, 2
	JMP L12
L19:
L12:
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