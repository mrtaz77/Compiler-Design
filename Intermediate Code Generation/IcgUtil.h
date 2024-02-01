#include<stdio.h>
#include<stdlib.h>
#include<cstring>

File *asm_out;

void writeToAsm(string code){
	fprintf(asm_out,"%s",code.c_str());
}

void printHeaderComment(string comment) {
	string code = "\
;--------------------------------\n\
;\t" + comment + "\n\
;--------------------------------\n";
	writeToAsm(code);
}

void headerCode() {
	printHeaderComment("asm code generator");
	string code = "\
.MODEL SMALL ; SCOPE OF CODE\n\
\n\
.STACK 1000H ; ALLOCATE MEMORY IN HEXADECIMAL\n\
\n\
.DATA ; VARIABLE DECLARATION\n\
NUMBER DB \"00000$\"\n\
CR EQU 0DH\n\
LF EQU 0AH\n\
NL DB CR,LF,'$'\n";
	writeToAsm(code);
}

void printNewLine() {
	printHeaderComment("prints newline to console");
	string code = "\
NEWLINE PROC\n\
	PUSH AX\n\
	PUSH DX\n\
	LEA DX,NL\n\
	MOV AH,9\n\
	INT 21H\n\
	POP AX\n\
	POP DX\n\
	RET\n\
	NEWLINE ENDP\n\n";
	writeToAsm(code);
}

void printOutput() {
	printHeaderComment("prints content of ax");
	string code = "\
PRINT_OUTPUT proc\n\
    PUSH AX\n\
    PUSH BX\n\
    PUSH CX\n\
    PUSH DX\n\
    PUSH SI\n\
    LEA SI,NUMBER_PRINTLN\n\
    MOV BX,10\n\
    ADD SI,4\n\
    CMP AX,0\n\
    JNGE NEGATE\n\
    PRINT:\n\
    XOR DX,DX\n\
    DIV BX\n\
    MOV [SI],DL\n\
    ADD [SI],'0'\n\
    DEC SI\n\
    CMP AX,0\n\
    JNE PRINT\n\
    INC SI\n\
    LEA DX,SI\n\
    MOV AH,9\n\
    INT 21H\n\
    POP SI\n\
    POP DX\n\
    POP CX\n\
    POP BX\n\
    POP AX\n\
    RET\n\
    NEGATE:\n\
    PUSH AX\n\
    MOV AH,2\n\
    MOV DL,'-'\n\
    INT 21H\n\
    POP AX\n\
    NEG AX\n\
    JMP PRINT\n\
	PRINT_OUTPUT ENDP\n\n";
	writeToAsm(code);
}