#pragma once

#define ASM_FILE "output_code.asm"

#include<stdio.h>
#include<stdlib.h>
#include<string>
#include "SymbolTable/SymbolTable.h"
#include "RuleCheckUtil.h"
#include "IcgUtil.h"

extern SymbolTable *table;
ParseTreeNode *root;

FILE *asm_out;

unsigned long labelCount = 0;
unsigned long returnLabel = 0;
long stackPointer = 0;
bool printlnUsed = false;



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

string varAddress(ParseTreeNode *node) {
	auto idName = idNameFromRule(node->getRule());
	auto id = table->lookUp(idName);
	if(id != nullptr)return id->getName(); // global variable
	string offsetSign = node->isParam() ? "+" : "-";
	return "[BP" + offsetSign  + to_string(node->getOffset()) + "]";
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

void printPopAx(ParseTreeNode *node) {
	string code;
	code += "\tPOP AX" + annotationOfLine(node->getStartOfNode());
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

string printNewlineCode() {
	return "\
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
    INT 21H\n"
	+ printNewlineCode()
	+ "\
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

void printLabel(unsigned long labelCount){
	string code = "L" + to_string(labelCount) + ":\n";
	writeToAsm(code);
}

unsigned long getIncreasedLabel() {
	return ++labelCount;
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
	printLabel(returnLabel);
	if(stackPointer != 0) {
		adjustStackPointer();
	}
	string code = "\tPOP BP\n";
	if(func->getName() == "main") {
		code += "\
	MOV AX, 4CH\n\
	INT 21H\n";
	}else {
		code += "\tRET " + to_string(func->getNode()->getParameterWidth()) + "\n";
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
		if(stackPointer > -(node->getOffset()) && !node->isParam()) {
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
	if(varNode->getNumOfChildren() == 1) {
		// assignment to id
		code += "\tMOV " + varAddress(varNode->getNthChild(1))  + ", AX\n"
		+ TAB + "PUSH AX\n\tPOP AX\n";
	}	
	writeToAsm(code);
}

void processFactorConstIntRule(ParseTreeNode *node) {
	string code;
	code += "\tMOV AX, " 
	+ node->getVal()
	+ annotationOfLine(node->getStartOfNode());
	writeToAsm(code);
}

void processAddOpNode(ParseTreeNode *node){
	string code;
	// check for ADDOP unary_expression rule
	string siblingRule = node->getSibling()->getRule();
	if(isTermUnaryExpressionRule(siblingRule) || isTermMulOpUnaryExpressionRule(siblingRule)) {
		code += "\tMOV DX, AX\n";
	}
	writeToAsm(code);
}

void processMulOpNode(){ writeToAsm("\tMOV CX, AX\n"); }

void processRelOpNode(){ writeToAsm("\tMOV DX, AX\n"); };

void processSimpleExpressionAddOpTermRule(ParseTreeNode *node){
	string addOpRule = node->getNthChild(2)->getRule();
	string code;
	code += "\tXCHG AX, DX\n";
	if(isPlusOp(addOpRule))code += "\tADD AX, DX\n";
	else code += "\tSUB AX, DX\n";
	code += "\tPUSH AX\n";
	writeToAsm(code);
	if(node->getSibling() != nullptr)printPopAx(node);
}

void processTermMulOpUnaryExpressionRule(ParseTreeNode *node){
	string mulOpRule = node->getNthChild(2)->getRule();
	string code;
	code += "\tXCHG AX, CX\n";
	code += "\tCWD\n";
	if(isStarOp(mulOpRule))code += "\tMUL CX\n";
	else code += "\tDIV CX\n";
	if(isModOp(mulOpRule))code += "\tPUSH DX\n";
	else code += "\tPUSH AX\n";
	writeToAsm(code);
	if(node->getSibling() != nullptr)printPopAx(node);
}

void processRelExpressionSimpleExpressionRule(ParseTreeNode *node){
	if(node->getChild()->getNumOfChildren() > 1)printPopAx(node);
}

void processSimpleExpressionTermRule(ParseTreeNode *node){
	if(node->getChild()->getNumOfChildren() > 1)printPopAx(node);
}

void processUnaryExpressionFactorRule(ParseTreeNode *node){
	if(node->getChild()->getNumOfChildren() > 1)printPopAx(node);
}

void processTermUnaryExpressionRule(ParseTreeNode *node){
	if(node->getChild()->getNumOfChildren() > 1)printPopAx(node);
}

void postProcessFunctionDefintionRule(ParseTreeNode *node){
	auto idNode = node->getNthChild(2);
	auto idName = idNameFromRule(idNode->getRule());
	auto id = table->lookUp(idName);
	insertFunctionFooterCode(id);
}

void preProcessFuncDefinitionRule(ParseTreeNode *node) {
	returnLabel = getIncreasedLabel();
}

void processFactorVariableRule(ParseTreeNode *node){
	string code;
	code += "\tMOV AX, " 
	+ varAddress(node->getNthChild(1)->getNthChild(1))
	+ annotationOfLine(node->getStartOfNode());
	writeToAsm(code);
}

void processUnaryExpressionAddOpRule(ParseTreeNode *node){
	if(isMinusOp(node->getNthChild(1)->getRule())){
		writeToAsm("\tNEG AX\n");
	} 
}

void processFactorIncDecOpRule(ParseTreeNode *node){
	string code;
	code += "\tMOV AX, "
	+ varAddress(node->getNthChild(1)->getNthChild(1))
	+ annotationOfLine(node->getStartOfNode())
	+ "\tPUSH AX\n";
	if(node->getRule().find("INCOP") != string::npos)code +="\tINC AX\n";
	else code += "\tDEC AX\n";
	code += "\tMOV " 
	+ varAddress(node->getNthChild(1)->getNthChild(1))
	+ ", AX\n";
	writeToAsm(code);
}

void processUnaryExpressionNotRule() {
	string code = "\
	NOT AX\n\
	PUSH AX\n";
	writeToAsm(code);
}



void processRuleOfNode(ParseTreeNode *node) {
	string rule = node->getRule();
	if(idNameFromRule(rule) != "")processIdNode(node);
	else if(isFuncDefinitionRule(rule))postProcessFunctionDefintionRule(node);
	else if(isSemiColon(rule))printLabel(getIncreasedLabel());
	else if(isAddOp(rule))processAddOpNode(node);
	else if(isMulOp(rule))processMulOpNode();
	else if(isRelop(rule))processRelOpNode();
	else if(isAssignOpOperation(rule))processAssignOpNode(node);
	else if(isFactorConstIntRule(rule))processFactorConstIntRule(node);
	else if(isSimpleExpressionAddOpTermRule(rule))processSimpleExpressionAddOpTermRule(node);
	else if(isRelExpressionSimpleExpressionRule(rule))processRelExpressionSimpleExpressionRule(node);
	else if(isTermMulOpUnaryExpressionRule(rule))processTermMulOpUnaryExpressionRule(node);
	else if(isSimpleExpressionTermRule(rule))processSimpleExpressionTermRule(node);
	else if(isFactorVariableRule(rule))processFactorVariableRule(node);
	else if(isFactorIncOpRule(rule) || isFactorDecOpRule(rule))processFactorIncDecOpRule(node);
	else if(isUnaryExpressionFactorRule(rule))processUnaryExpressionFactorRule(node);
	else if(isUnaryExpressionNotRule(rule))processUnaryExpressionNotRule();
	else if(isTermUnaryExpressionRule(rule))processTermUnaryExpressionRule(node);
	else if(isUnaryExpressionAddOpRule(rule))processUnaryExpressionAddOpRule(node);
}

void processStatementReturnRule(ParseTreeNode* node) {
	postOrderTraversal(node->getNthChild(2));
	writeToAsm("\tJMP L" + to_string(returnLabel) + "\n");
	printLabel(getIncreasedLabel());
}

void processStatementPrintlnRule(ParseTreeNode *node){
	printlnUsed = true;
	string code = "\
	MOV AX, " + 
	varAddress(node->getNthChild(3)) +
	annotationOfLine(node->getStartOfNode()) + "\
	CALL println\n";
	writeToAsm(code);
	processRuleOfNode(node->getNthChild(5));
}

void postOrderTraversal(ParseTreeNode *node) {
	// skipping some nodes
	if(isGlobalVariableDeclaration(node->getRule()) 
	|| isFunctionDeclaration(node->getRule()))return;

	if(isStatementPrintlnRule(node->getRule())) {
		processStatementPrintlnRule(node);
		return;
	}

	if(isStatementReturnRule(node->getRule())) {
		processStatementReturnRule(node);
		return;
	}

	if(isFuncDefinitionRule(node->getRule())) {
		preProcessFuncDefinitionRule(node);
	}

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
	if(printlnUsed)printOutput();
	footerCode();
	fclose(asm_out);
}