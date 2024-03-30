;-------------------------------
;         asm code generator
;-------------------------------
.MODEL SMALL ; SCOPE OF CODE
.STACK 1000H ; ALLOCATE MEMORY IN HEXADECIMAL
.DATA ; VARIABLE DECLARATION
	number DB "00000$"
	a DW 1 DUP (0000H)
	arr DW 5 DUP (0000H)
.CODE
;-------------------------------
;         Function : f
;-------------------------------
f PROC
	PUSH BP
	MOV BP, SP
	MOV AX, [BP+8]		; Line 4
	CALL println
L2:
	MOV AX, [BP+6]		; Line 5
	CALL println
L3:
	MOV AX, [BP+4]		; Line 6
	CALL println
L4:
	MOV AX, 1		; Line 7
	PUSH BX
	PUSH CX
	PUSH AX
	MOV AX, 441		; Line 7
	POP BX
	PUSH AX
	MOV AX, 2
	IMUL BX
	MOV BX, AX
	POP AX
	MOV arr[BX], AX
	POP CX
	POP BX
L5:
	MOV AX, 0		; Line 8
	PUSH BX
	PUSH CX
	PUSH AX
	MOV AX, 555		; Line 8
	POP BX
	PUSH AX
	MOV AX, 2
	IMUL BX
	MOV BX, AX
	POP AX
	MOV arr[BX], AX
	POP CX
	POP BX
L6:
	MOV AX, 1		; Line 9
	PUSH BX
	PUSH CX
	PUSH AX
	POP BX
	MOV AX, 2		; Line 9
	IMUL BX
	MOV BX, AX
	MOV AX, arr[BX]
	POP CX
	POP BX
	MOV [BP+6], AX
L7:
	MOV AX, [BP+6]		; Line 10
	CALL println
L8:
	MOV AX, 0		; Line 11
	PUSH BX
	PUSH CX
	PUSH AX
	POP BX
	MOV AX, 2		; Line 11
	IMUL BX
	MOV BX, AX
	MOV AX, arr[BX]
	POP CX
	POP BX
	JMP L1
L9:
L1:
	POP BP
	RET 6
f ENDP
;-------------------------------
;         Function : recursive
;-------------------------------
recursive PROC
	PUSH BP
	MOV BP, SP
	MOV AX, [BP+4]		; Line 15
	PUSH AX
	MOV AX, 1		; Line 15
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JNE L11
	MOV AX, 1		; Line 15
	JMP L12
L11:
	XOR AX, AX		; Line 15
L12:
	CMP AX, 0
	JE L13
	MOV AX, 1		; Line 16
	JMP L10
L14:
L13:
	MOV AX, [BP+4]		; Line 17
	PUSH AX
	MOV AX, 0		; Line 17
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JNE L15
	MOV AX, 1		; Line 17
	JMP L16
L15:
	XOR AX, AX		; Line 17
L16:
	CMP AX, 0
	JE L17
	MOV AX, 0		; Line 18
	JMP L10
L18:
L17:
	PUSH BX
	PUSH CX
	MOV AX, [BP+4]		; Line 19
	PUSH AX
	MOV AX, 1		; Line 19
	POP BX
	XCHG AX, BX
	SUB AX, BX
	PUSH AX
	CALL recursive
	POP CX
	POP BX
	PUSH AX
	PUSH BX
	PUSH CX
	MOV AX, [BP+4]		; Line 19
	PUSH AX
	MOV AX, 2		; Line 19
	POP BX
	XCHG AX, BX
	SUB AX, BX
	PUSH AX
	CALL recursive
	POP CX
	POP BX
	POP BX
	XCHG AX, BX
	ADD AX, BX
	JMP L10
L19:
L10:
	POP BP
	RET 2
recursive ENDP
;-------------------------------
;         Function : v
;-------------------------------
v PROC
	PUSH BP
	MOV BP, SP
	MOV AX, 3		; Line 23
	MOV a, AX
L21:
	MOV AX, a		; Line 24
	CMP AX, 0
	JE L22
	SUB SP, 2
L23:
	MOV AX, 1		; Line 27
	MOV [BP-2], AX
L24:
	MOV AX, [BP-2]		; Line 28
	CALL println
L25:
	ADD SP, 2
L22:
	MOV AX, a		; Line 30
	CALL println
L26:
L20:
	POP BP
	RET 
v ENDP
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
	SUB SP, 10
L28:
	MOV AX, 5		; Line 35
	MOV [BP-8], AX
L29:
	PUSH BX
	PUSH CX
	CALL v
	POP CX
	POP BX
L30:
	MOV AX, [BP-8]		; Line 37
	CALL println
L31:
	MOV AX, 0		; Line 38
	MOV [BP-2], AX
L32:
	MOV AX, [BP-2]		; Line 38
	PUSH AX
	MOV AX, 5		; Line 38
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JGE L34
	MOV AX, 1		; Line 38
	JMP L35
L34:
	XOR AX, AX		; Line 38
L35:
L36:
	CMP AX, 0
	JE L33
	MOV AX, [BP-2]		; Line 40
	PUSH BX
	PUSH CX
	PUSH AX
	MOV AX, [BP-2]		; Line 40
	PUSH AX
	MOV AX, 1		; Line 40
	POP BX
	XCHG AX, BX
	ADD AX, BX
	POP BX
	PUSH AX
	MOV AX, 2
	IMUL BX
	MOV BX, AX
	MOV AX, 18
	SUB AX, BX
	MOV SI, AX
	POP AX
	NEG SI
	MOV [BP+SI], AX
	POP CX
	POP BX
L37:
	MOV AX, [BP-2]		; Line 38
	PUSH AX
	INC AX
	MOV [BP-2], AX
	POP AX		; Line 38
	JMP L32
L33:
	MOV AX, 4		; Line 42
	MOV [BP-2], AX
L38:
L39:
	MOV AX, [BP-2]		; Line 43
	PUSH AX
	DEC AX
	MOV [BP-2], AX
	POP AX		; Line 43
	CMP AX, 0
	JE L40
	MOV AX, [BP-2]		; Line 45
	PUSH BX
	PUSH CX
	PUSH AX
	POP BX
	MOV AX, 2		; Line 45
	IMUL BX
	MOV BX, AX
	MOV AX, 18
	SUB AX, BX
	MOV SI, AX
	NEG SI
	MOV AX, [BP+SI]
	POP CX
	POP BX
	MOV [BP-4], AX
L41:
	MOV AX, [BP-4]		; Line 46
	CALL println
L42:
	JMP L39
L40:
	MOV AX, 2		; Line 48
	MOV [BP-6], AX
L43:
	MOV AX, [BP-6]		; Line 49
	PUSH AX
	MOV AX, 0		; Line 49
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JLE L44
	MOV AX, 1		; Line 49
	JMP L45
L44:
	XOR AX, AX		; Line 49
L45:
	CMP AX, 0
	JE L46
	MOV AX, [BP-6]		; Line 50
	PUSH AX
	INC AX
	MOV [BP-6], AX
	POP AX		; Line 50
L48:
	JMP L47
L46:
	MOV AX, [BP-6]		; Line 52
	PUSH AX
	DEC AX
	MOV [BP-6], AX
	POP AX		; Line 52
L49:
L47:
	MOV AX, [BP-6]		; Line 53
	CALL println
L50:
	MOV AX, 2		; Line 54
	NEG AX
	MOV [BP-6], AX
L51:
	MOV AX, [BP-6]		; Line 55
	PUSH AX
	MOV AX, 0		; Line 55
	POP BX
	XCHG AX, BX
	CMP AX, BX
	JGE L52
	MOV AX, 1		; Line 55
	JMP L53
L52:
	XOR AX, AX		; Line 55
L53:
	CMP AX, 0
	JE L54
	MOV AX, [BP-6]		; Line 56
	PUSH AX
	INC AX
	MOV [BP-6], AX
	POP AX		; Line 56
L56:
	JMP L55
L54:
	MOV AX, [BP-6]		; Line 58
	PUSH AX
	DEC AX
	MOV [BP-6], AX
	POP AX		; Line 58
L57:
L55:
	MOV AX, [BP-6]		; Line 59
	CALL println
L58:
	MOV AX, 121		; Line 60
	MOV [BP-6], AX
L59:
	MOV AX, [BP-6]		; Line 61
	NEG AX
	MOV [BP-6], AX
L60:
	MOV AX, 5		; Line 62
	MOV [BP-2], AX
L61:
	MOV AX, [BP-2]		; Line 63
	PUSH AX
	MOV AX, [BP-6]		; Line 63
	POP BX
	XCHG AX, BX
	ADD AX, BX
	MOV [BP-6], AX
L62:
	MOV AX, [BP-6]		; Line 64
	CALL println
L63:
	MOV AX, 4		; Line 65
	NEG AX
	MOV [BP-6], AX
L64:
	MOV AX, [BP-6]		; Line 66
	PUSH AX
	MOV AX, 4		; Line 66
	POP CX
	XCHG AX, CX
	CWD
	IMUL CX
	MOV [BP-6], AX
L65:
	MOV AX, [BP-6]		; Line 67
	CALL println
L66:
	MOV AX, 19		; Line 68
	MOV [BP-4], AX
L67:
	MOV AX, 4		; Line 69
	MOV [BP-2], AX
L68:
	MOV AX, [BP-4]		; Line 70
	PUSH AX
	MOV AX, [BP-2]		; Line 70
	POP CX
	XCHG AX, CX
	CWD
	IDIV CX
	MOV [BP-6], AX
L69:
	MOV AX, [BP-6]		; Line 71
	CALL println
L70:
	MOV AX, [BP-4]		; Line 72
	PUSH AX
	MOV AX, [BP-2]		; Line 72
	POP CX
	XCHG AX, CX
	CWD
	IDIV CX
	PUSH DX
	POP AX		; Line 72
	MOV [BP-6], AX
L71:
	MOV AX, [BP-6]		; Line 73
	CALL println
L72:
	PUSH BX
	PUSH CX
	MOV AX, 111		; Line 74
	PUSH AX
	MOV AX, 222		; Line 74
	PUSH AX
	MOV AX, 333		; Line 74
	PUSH AX
	CALL f
	POP CX
	POP BX
	PUSH AX
	MOV AX, 444		; Line 74
	POP BX
	XCHG AX, BX
	SUB AX, BX
	MOV [BP-6], AX
L73:
	MOV AX, [BP-6]		; Line 75
	CALL println
L74:
	PUSH BX
	PUSH CX
	MOV AX, 5		; Line 76
	PUSH AX
	CALL recursive
	POP CX
	POP BX
	MOV [BP-6], AX
L75:
	MOV AX, [BP-6]		; Line 77
	CALL println
L76:
	MOV AX, 2		; Line 78
	MOV [BP-6], AX
L77:
	MOV AX, 1		; Line 79
	MOV [BP-2], AX
L78:
	MOV AX, [BP-2]		; Line 80
	CMP AX, 0
	JNE L79
	MOV AX, [BP-6]		; Line 80
	CMP AX, 0
	JE L80
L79:
	MOV AX, 1		; Line 80
	JMP L81
L80:
	XOR AX, AX
L81:
	MOV [BP-4], AX
L82:
	MOV AX, [BP-4]		; Line 81
	CALL println
L83:
	MOV AX, [BP-2]		; Line 82
	CMP AX, 0
	JE L85
	MOV AX, [BP-6]		; Line 82
	CMP AX, 0
	JE L85
L84:
	MOV AX, 1		; Line 82
	JMP L86
L85:
	XOR AX, AX
L86:
	MOV [BP-4], AX
L87:
	MOV AX, [BP-4]		; Line 83
	CALL println
L88:
	MOV AX, 2		; Line 84
	MOV [BP-6], AX
L89:
	MOV AX, 0		; Line 85
	MOV [BP-2], AX
L90:
	MOV AX, [BP-2]		; Line 86
	CMP AX, 0
	JNE L91
	MOV AX, [BP-6]		; Line 86
	CMP AX, 0
	JE L92
L91:
	MOV AX, 1		; Line 86
	JMP L93
L92:
	XOR AX, AX
L93:
	MOV [BP-4], AX
L94:
	MOV AX, [BP-4]		; Line 87
	CALL println
L95:
	MOV AX, [BP-2]		; Line 88
	CMP AX, 0
	JE L97
	MOV AX, [BP-6]		; Line 88
	CMP AX, 0
	JE L97
L96:
	MOV AX, 1		; Line 88
	JMP L98
L97:
	XOR AX, AX
L98:
	MOV [BP-4], AX
L99:
	MOV AX, [BP-4]		; Line 89
	CALL println
L100:
	MOV AX, [BP-6]		; Line 90
	NOT AX
	MOV [BP-4], AX
L101:
	MOV AX, [BP-4]		; Line 91
	CALL println
L102:
	MOV AX, [BP-4]		; Line 92
	NOT AX
	MOV [BP-4], AX
L103:
	MOV AX, [BP-4]		; Line 93
	CALL println
L104:
	MOV AX, 12		; Line 94
	PUSH AX
	MOV AX, 2		; Line 94
	PUSH AX
	MOV AX, 89		; Line 94
	POP CX
	XCHG AX, CX
	CWD
	IDIV CX
	PUSH AX
	MOV AX, 3		; Line 94
	PUSH AX
	MOV AX, 33		; Line 94
	POP BX
	XCHG AX, BX
	SUB AX, BX
	PUSH AX
	MOV AX, 64		; Line 94
	PUSH AX
	MOV AX, 2		; Line 94
	POP CX
	XCHG AX, CX
	CWD
	IMUL CX
	POP BX
	XCHG AX, BX
	ADD AX, BX
	POP CX
	XCHG AX, CX
	CWD
	IDIV CX
	PUSH DX
	POP AX		; Line 94
	POP BX
	XCHG AX, BX
	ADD AX, BX
	PUSH AX
	MOV AX, 3		; Line 94
	POP BX
	XCHG AX, BX
	SUB AX, BX
	PUSH AX
	MOV AX, 3		; Line 94
	PUSH AX
	MOV AX, 59		; Line 94
	PUSH AX
	MOV AX, 9		; Line 94
	POP CX
	XCHG AX, CX
	CWD
	IDIV CX
	PUSH AX
	MOV AX, 2		; Line 94
	POP CX
	XCHG AX, CX
	CWD
	IMUL CX
	POP BX
	XCHG AX, BX
	ADD AX, BX
	PUSH AX
	MOV AX, 4		; Line 94
	POP BX
	XCHG AX, BX
	SUB AX, BX
	POP BX
	XCHG AX, BX
	ADD AX, BX
	MOV [BP-4], AX
L105:
	MOV AX, [BP-4]		; Line 95
	CALL println
L106:
	MOV AX, 12		; Line 96
	PUSH AX
	MOV AX, [BP-4]		; Line 96
	NEG AX
	POP CX
	XCHG AX, CX
	CWD
	IMUL CX
	MOV [BP-4], AX
L107:
	MOV AX, [BP-4]		; Line 97
	CALL println
L108:
	MOV AX, 0		; Line 99
	ADD SP, 18
	JMP L27
L109:
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