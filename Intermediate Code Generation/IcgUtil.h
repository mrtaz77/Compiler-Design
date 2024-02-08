#pragma once

#define ASM_FILE "code.asm"

#include<stdio.h>
#include<stdlib.h>
#include<string>
#include "SymbolTable/SymbolTable.h"

extern SymbolTable *table;
ParseTreeNode *root;

FILE *asm_out;

unsigned long labelCount = 0;
long stackPointer = 0;

string idNameFromRule(string rule){
	if(rule.substr(0, 2) != "ID") return "";
	else {
		string name = "";
		for(int i = 5; i < rule.length() ; i++) {
			name += rule[i];
		}
		return name;
	}
}

void writeToAsm(string code){
	fprintf(asm_out, "%s", code.c_str());
}

void printHeaderComment(string comment) {
	string code = "\
;-------------------------------\n\
;         " + comment + "\n\
;-------------------------------\n";
	writeToAsm(code);
}

string annotationOfLine(unsigned long lineNo){
	string code = "\t\
	; Line " + to_string(lineNo) + "\n";
	return code;
}

void adjustStackPointer() {
	string code = "\tADD SP, " + to_string(-stackPointer) + "\n";
	writeToAsm(code);
}

void headerCode() {
	printHeaderComment("asm code generator");
	string code = "\
.MODEL SMALL ; SCOPE OF CODE\n\
.STACK 1000H ; ALLOCATE MEMORY IN HEXADECIMAL\n\
.DATA ; VARIABLE DECLARATION\n\
	number DB \"00000$\"\n";
	writeToAsm(code);
}

void footerCode() {
	string code = "\
END main";
	writeToAsm(code);
}

void printNewlineCode() {
	printHeaderComment("print newline");
	string code = "\
	PUSH AX\n\
    PUSH DX\n\
    MOV AH, 2\n\
    MOV DL, 0DH\n\
    INT 21H\n\
    MOV AH, 2\n\
    MOV DL, 0AH\n\
    INT 21H\n\
    POP DX\n\
    POP AX\n";
	writeToAsm(code);
}

void printOutput() {
	printHeaderComment("print library");
	string code = "\
;-------------------------------\n\
println proc\n\
    PUSH AX\n\
    PUSH BX\n\
    PUSH CX\n\
    PUSH DX\n\
    PUSH SI\n\
    LEA SI, number\n\
    MOV BX, 10\n\
    ADD SI, 4\n\
    CMP AX, 0\n\
    JNGE NEGATE\n\
PRINT:\n\
    XOR DX, DX\n\
    DIV BX\n\
    MOV [SI], DL\n\
    ADD [SI], '0'\n\
    DEC SI\n\
    CMP AX, 0\n\
    JNE PRINT\n\
    INC SI\n\
    LEA DX, SI\n\
    MOV AH, 9\n\
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
    MOV AH, 2\n\
    MOV DL, '-'\n\
    INT 21H\n\
    POP AX\n\
    NEG AX\n\
    JMP PRINT\n\
	println ENDP\n\n";
	writeToAsm(code);
}

void declareGlobalVariablesInASM(){
	auto symbols = table->getSortedSymbolInfosOfCurrentScope();
	string code = "";
	for(auto symbol : symbols){
		// skipping functions
		if(symbol->getNode()->isFunctionDeclared())continue;
		code += TAB + symbol->getName() + " DW ";
		if(symbol->getType() == "ARRAY") code+= to_string(symbol->getNode()->getArraySize()); 
		else code += "1";
		code += " DUP (0000H)\n";
	}
	code += ".CODE\n";
	writeToAsm(code);
}

void printLabel(){
	string code = "L" + to_string(++labelCount) + ":\n";
	writeToAsm(code);
}


void insertFunctionHeaderCode(SymbolInfo* func) {
	printHeaderComment("Function : " +func->getName());
	string code = func->getName() + " PROC\n";
	if(func->getName() == "main") {
		code += "\
	MOV AX, @DATA\n\
	MOV DS, AX\n";
	}
	code +="\
	PUSH BP\n\
	MOV BP, SP\n";
	writeToAsm(code);
}

void insertFunctionFooterCode(SymbolInfo* func) {
	printLabel();
	if(stackPointer != 0) {
		adjustStackPointer();
	}
	string code = "\tPOP BP\n";
	if(func->getName() == "main") {
		code += "\
	MOV AX, 4CH\n\
	INT 21H\n";
	}else {
		code += "\tRET\n";
	}
	code += func->getName() + " ENDP\n";
	writeToAsm(code);
}


void processIdNode(ParseTreeNode* node){
	auto idName = idNameFromRule(node->getRule());
	auto id = table->lookUp(idName);

	if(id != nullptr){
		if(node->isFunctionDefined()) {
			insertFunctionHeaderCode(id);
		}
	}else {
		// local variable
		if(stackPointer > -(node->getOffset())) {
			// local variable declaration
			string code = "\tSUB SP, " + to_string(node->getOffset()+stackPointer) + "\n";
			stackPointer = -node->getOffset();
			writeToAsm(code);
		}
	}
}

void processAssignOpNode(ParseTreeNode* node){
	string code;
	auto varNode = node->getNthChild(1);
	auto logicExprNode = node->getNthChild(3);
	// cout << varNode->print() << varNode->getNumOfChildren() << " " << varNode->getOffset();
	if(varNode->getNumOfChildren() == 1) {
		// assignment to id
		code = "\tMOV AX, ";
		if(logicExprNode->getVal().length()) {
			code += logicExprNode->getVal() + 
			annotationOfLine(logicExprNode->getStartOfNode())
			+ TAB + "MOV [BP-" + to_string(varNode->getOffset()) + "], AX\n"
			+ TAB + "PUSH AX\n\tPOP AX\n";
		}
	}
	writeToAsm(code);
}

void processAddopNode(ParseTreeNode *node){
	// TODO Addop operation
}

bool isFunctionDefinitionRule(string rule) {return rule.find("func_definition : ") != string::npos; }
bool isSemiColon(string rule) { return rule == "SEMICOLON : ;"; }
bool isAssignOpOperation(string rule) { return rule == "expression : variable ASSIGNOP logic_expression "; }
bool isGlobalVariableDeclaration(string rule) { return rule == "unit : var_declaration "; }
bool isFunctionDeclaration(string rule) { return rule == "unit : func_declaration "; }
bool isAddOpOperation(string rule) { return rule == "simple_expression : simple_expression ADDOP term ";}

void processRuleOfNode(ParseTreeNode *node) {
	string rule = node->getRule();
	if(idNameFromRule(rule) != "")processIdNode(node);
	else if(isFunctionDefinitionRule(rule)) {
		auto idNode = node->getNthChild(2);
		auto idName = idNameFromRule(idNode->getRule());
		auto id = table->lookUp(idName);
		insertFunctionFooterCode(id);
	}
	else if(isSemiColon(rule))printLabel();
	else if(isAssignOpOperation(rule))processAssignOpNode(node);
	else if(isAddOpOperation(rule))processAddOpNode(node);
}

void postOrderTraversal(ParseTreeNode *node) {
	// skipping some nodes
	if(isGlobalVariableDeclaration(node->getRule()) 
	|| isFunctionDeclaration(node->getRule()))return;

	for(ParseTreeNode* itr = node->getChild(); itr != nullptr; itr = itr->getSibling()){
		postOrderTraversal(itr);
	}
	processRuleOfNode(node);
}


void generateASM(ParseTreeNode *node){
	root = node;
	asm_out = fopen(ASM_FILE, "w");
	headerCode();
	declareGlobalVariablesInASM();
	postOrderTraversal(node);
	footerCode();
	fclose(asm_out);
}