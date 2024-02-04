#pragma once

#define ASM_FILE "code.asm"

#include<stdio.h>
#include<stdlib.h>
#include<string>
#include "SymbolTable/SymbolTable.h"


extern SymbolTable *table;
ParseTreeNode *root;

FILE *asm_out;



void writeToAsm(string code){
	fprintf(asm_out,"%s",code.c_str());
}

void printHeaderComment(string comment) {
	string code = "\
;-------------------------------\n\
;         " + comment + "\n\
;-------------------------------\n";
	writeToAsm(code);
}

void headerCode() {
	printHeaderComment("asm code generator");
	string code = "\
.MODEL SMALL ; SCOPE OF CODE\n\
.STACK 1000H ; ALLOCATE MEMORY IN HEXADECIMAL\n\
.DATA ; VARIABLE DECLARATION\n\
	number DB \"00000$\"\n\
.CODE\n";
	writeToAsm(code);
}

void footerCode() {
	string code = "\
END main\n";
	writeToAsm(code);
}

void printNewlineCode() {
	printHeaderComment("print newline");
	string code = "\
	PUSH AX\n\
    PUSH DX\n\
    MOV AH,2\n\
    MOV DL,0DH\n\
    INT 21H\n\
    MOV AH,2\n\
    MOV DL,0AH\n\
    INT 21H\n\
    POP DX\n\
    POP AX\n";
	writeToAsm(code);
}

void printNewLine() {
	printHeaderComment("print library");
	string code = "\
;-------------------------------\n\
println proc\n\
    PUSH AX\n\
    PUSH BX\n\
    PUSH CX\n\
    PUSH DX\n\
    PUSH SI\n\
    LEA SI,number\n\
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
    INT 21H\n";

	printNewlineCode();
	
	code += "\
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
	println ENDP\n\n";
	writeToAsm(code);
}

void postOrderTraversal(ParseTreeNode *node) {
	for(ParseTreeNode* itr = node->getChild(); itr != nullptr; itr = itr->getSibling()){
		postOrderTraversal(itr);
	}
	// processRuleOfNode(node);
}


void generateASM(ParseTreeNode *node){
	root = node;
	asm_out = fopen(ASM_FILE,"w");
	headerCode();
	postOrderTraversal(node);
	footerCode();
	fclose(asm_out);
}