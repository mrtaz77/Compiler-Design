;-------------------------------
;         asm code generator
;-------------------------------
.MODEL SMALL ; SCOPE OF CODE
.STACK 1000H ; ALLOCATE MEMORY IN HEXADECIMAL
.DATA ; VARIABLE DECLARATION
	number DB "00000$"
.CODE
;-------------------------------
;         Function : f1
;-------------------------------
f1 PROC
	PUSH BP
	MOV BP, SP
	MOV AX, [BP+4]		; Line 2
	NEG AX
	PUSH AX
	POP AX		; Line 2
	JMP L1
L2:
L1:
	POP BP
	RET 2
f1 ENDP
;-------------------------------
;         Function : f2
;-------------------------------
f2 PROC
	PUSH BP
	MOV BP, SP
	MOV AX, 1		; Line 6
	MOV BX, AX
	MOV AX, [BP+4]		; Line 6
	MOV BX, AX
	MOV AX, 1		; Line 6
	XCHG AX, BX
	SUB AX, BX
	PUSH AX
	POP AX		; Line 6
	PUSH AX
	CALL f1
	PUSH AX
	POP AX		; Line 6
	XCHG AX, BX
	ADD AX, BX
	PUSH AX
	POP AX		; Line 6
	JMP L3
L4:
L3:
	POP BP
	RET 2
f2 ENDP
;-------------------------------
;         Function : f3
;-------------------------------
f3 PROC
	PUSH BP
	MOV BP, SP
	MOV AX, 1		; Line 10
	MOV BX, AX
	MOV AX, [BP+4]		; Line 10
	MOV BX, AX
	MOV AX, 1		; Line 10
	XCHG AX, BX
	SUB AX, BX
	PUSH AX
	POP AX		; Line 10
	PUSH AX
	CALL f2
	PUSH AX
	POP AX		; Line 10
	XCHG AX, BX
	ADD AX, BX
	PUSH AX
	POP AX		; Line 10
	JMP L5
L6:
L5:
	POP BP
	RET 2
f3 ENDP
;-------------------------------
;         Function : f4
;-------------------------------
f4 PROC
	PUSH BP
	MOV BP, SP
	MOV AX, 1		; Line 14
	MOV BX, AX
	MOV AX, [BP+4]		; Line 14
	MOV BX, AX
	MOV AX, 1		; Line 14
	XCHG AX, BX
	SUB AX, BX
	PUSH AX
	POP AX		; Line 14
	PUSH AX
	CALL f3
	PUSH AX
	POP AX		; Line 14
	XCHG AX, BX
	ADD AX, BX
	PUSH AX
	POP AX		; Line 14
	JMP L7
L8:
L7:
	POP BP
	RET 2
f4 ENDP
;-------------------------------
;         Function : main
;-------------------------------
main PROC
	MOV AX, @DATA
	MOV DS, AX
	PUSH BP
	MOV BP, SP
	SUB SP, 2
L10:
	MOV AX, 4		; Line 19
	PUSH AX
	CALL f4
	PUSH AX
	POP AX		; Line 19
	MOV [BP-2], AX
	PUSH AX
	POP AX
L11:
	MOV AX, [BP-2]		; Line 20
	CALL println
L12:
L9:
	ADD SP, 2
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