#pragma once

#define ASM_FILE "code.asm"

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

unsigned widthFromType(Type_Spec type) {
	switch(type) {
		case TYPE_INT: return 2;
		case TYPE_FLOAT: return 4;
		default: return -1;
	}
}

string varAddress(ParseTreeNode *node) {
	if(node->getScope() == "1")return idNameFromRule(node->getRule()); // global variable
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

void resetStackPointer() {
	string code = "\tADD SP, " + to_string(-stackPointer) + "\n";
	stackPointer = 0;
	writeToAsm(code);
}

void rollbackStackPointer(unsigned long currentStackPointer, unsigned long newStackPointer) {
	if(newStackPointer < currentStackPointer){ 
		string code = "\tADD SP, "
		+ to_string(currentStackPointer - newStackPointer) + "\n";
		writeToAsm(code);
		stackPointer = currentStackPointer;
	}
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
	println ENDP\n";
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
		resetStackPointer();
	}
	string code = "\tPOP BP\n";
	if(func->getName() == "main") {
		code += "\
	MOV AX, 4CH\n\
	INT 21H\n";
	}else {
		code += "\tRET " ;
		if(func->getNode()->getParameterWidth() > 0)
			code += to_string(func->getNode()->getParameterWidth());
		code += "\n";
	}
	code += func->getName() + " ENDP\n";
	writeToAsm(code);
}

void processAssignOpNode(ParseTreeNode* node){
	string code;
	auto varNode = node->getNthChild(1);
	auto logicExprNode = node->getNthChild(3);
	if(varNode->getNumOfChildren() == 1) {
		// assignment to id
		code += "\tMOV " + varAddress(varNode->getNthChild(1))  + ", AX\n";
	}else {
		code += "\
	POP BX\n\
	PUSH AX\n\
	MOV AX, " + to_string(widthFromType(varNode->getNthChild(1)->getType()));
	code += "\n\
	IMUL BX\n\
	MOV BX, AX\n";
		auto id = table->lookUp(idNameFromRule(varNode->getNthChild(1)->getRule()));
		if(id != nullptr){
			code += "\tPOP AX\n\tMOV " + id->getName() + "[BX], AX\n";
		}
		else {
			code += "\tMOV AX, " + to_string(varNode->getOffset()) + "\n\
	SUB AX, BX\n\
	MOV SI, AX\n\
	POP AX\n\
	NEG SI\n\
	MOV [BP+SI], AX\n";
		}
		code+= "\
	POP CX\n\
	POP BX\n";
	}
	code += "\
	PUSH AX\n\
	POP AX\n";
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
		code += "\tPUSH AX\n";
	}
	writeToAsm(code);
}

void processMulOpNode(){ writeToAsm("\tPUSH AX\n"); }

void processRelOpNode(){ writeToAsm("\tPUSH AX\n"); };

void processSimpleExpressionAddOpTermRule(ParseTreeNode *node){
	string addOpRule = node->getNthChild(2)->getRule();
	string code;
	if(node->getNthChild(3)->getNumOfChildren() > 1)printPopAx(node);
	code += "\
	POP BX\n\
	XCHG AX, BX\n";
	if(isPlusOp(addOpRule))code += "\tADD AX, BX\n";
	else code += "\tSUB AX, BX\n";
	code += "\tPUSH AX\n";
	writeToAsm(code);
	if(node->getSibling() != nullptr)printPopAx(node);
}

void processTermMulOpUnaryExpressionRule(ParseTreeNode *node){
	string mulOpRule = node->getNthChild(2)->getRule();
	string code;
	code += "\
	POP CX\n\
	XCHG AX, CX\n\
	CWD\n";
	if(isStarOp(mulOpRule))code += "\tIMUL CX\n";
	else code += "\tIDIV CX\n";
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
	if(node->getChild()->getNumOfChildren() > 1 &&
	!isFactorExpressionRule(node->getChild()->getRule())){
		printPopAx(node);
	}
}

void processTermUnaryExpressionRule(ParseTreeNode *node){
	if(node->getChild()->getNumOfChildren() > 1)printPopAx(node);
}

SymbolInfo* getIdFromFunctionDefinitionNode(ParseTreeNode *node) {
	auto idNode = node->getNthChild(2);
	auto idName = idNameFromRule(idNode->getRule());
	return table->lookUp(idName);
}

void postProcessFunctionDefintionRule(ParseTreeNode *node){
	insertFunctionFooterCode(getIdFromFunctionDefinitionNode(node));
}

void preProcessFuncDefinitionRule(ParseTreeNode *node) {
	returnLabel = getIncreasedLabel();
	insertFunctionHeaderCode(getIdFromFunctionDefinitionNode(node));
}

void printCodeForArrayVariable(ParseTreeNode *node) {
	string code;
	auto varNode = node->getNthChild(1);
	code += "\
	POP BX\n\
	MOV AX, " + to_string(widthFromType(varNode->getNthChild(1)->getType())) + annotationOfLine(node->getStartOfNode());
	code += "\
	IMUL BX\n\
	MOV BX, AX\n\
	MOV AX, ";
	auto id = table->lookUp(idNameFromRule(varNode->getNthChild(1)->getRule()));
	if(id != nullptr){
		code += id->getName() + "[BX]\n";
	}
	else {
		code += to_string(varNode->getOffset()) + "\n\
	SUB AX, BX\n\
	MOV SI, AX\n\
	NEG SI\n\
	MOV AX, [BP+SI]\n";
	}
	writeToAsm(code);
}

void processFactorVariableRule(ParseTreeNode *node){
	string code;
	auto varNode = node->getNthChild(1);

	if(node->getNthChild(1)->getNumOfChildren() == 1) {
		// non array variable
		code += "\tMOV AX, " + varAddress(varNode->getNthChild(1))
		+ annotationOfLine(node->getStartOfNode());
	}else {
		printCodeForArrayVariable(node);
		code += "\
	POP CX\n\
	POP BX\n";
	}
	writeToAsm(code);
}

void processUnaryExpressionAddOpRule(ParseTreeNode *node){
	if(isMinusOp(node->getNthChild(1)->getRule())){
		string code = "\
	NEG AX\n\
	PUSH AX\n";
		writeToAsm(code);
	} 
}

void processFactorIncDecOpRule(ParseTreeNode *node){
	string code;
	if(node->getNthChild(1)->getNumOfChildren() > 1) {
		code = "\
	POP CX\n\
	PUSH CX\n";
		writeToAsm(code);
		printCodeForArrayVariable(node);
	}
	else processFactorVariableRule(node);
	code = "\tPUSH AX\n";
	if(node->getRule().find("INCOP") != string::npos)code +="\tINC AX\n";
	else code += "\tDEC AX\n";
	auto varNode = node->getNthChild(1);
	if(varNode->getNumOfChildren() == 1) {
		// assignment to id
		code += "\tMOV " + varAddress(varNode->getNthChild(1))  + ", AX\n";
	}else {
		code += "\
	MOV BX, CX\n\
	PUSH AX\n\
	MOV AX, " + to_string(widthFromType(varNode->getNthChild(1)->getType()));
	code += "\n\
	IMUL BX\n\
	MOV BX, AX\n";
		auto id = table->lookUp(idNameFromRule(varNode->getNthChild(1)->getRule()));
		if(id != nullptr){
			code += "\tPOP AX\n\tMOV " + id->getName() + "[BX], AX\n";
		}
		else {
			code += "\tMOV AX, " + to_string(varNode->getOffset()) + "\n\
	SUB AX, BX\n\
	MOV SI, AX\n\
	POP AX\n\
	NEG SI\n\
	MOV [BP+SI], AX\n";
		}
		code += "\
	POP AX\n\
	POP CX\n\
	POP BX\n\
	PUSH AX\n";
	}
	writeToAsm(code);
}

void processUnaryExpressionNotRule() {
	string code = "\
	NOT AX\n\
	PUSH AX\n";
	writeToAsm(code);
}

void postProcessFactorFunctionCallRule(ParseTreeNode *node) {
	auto idName = idNameFromRule(node->getNthChild(1)->getRule());
	string code = "\
	CALL " + idName + "\n\
	POP CX\n\
	POP BX\n\
	PUSH AX\n";

	writeToAsm(code);
}

void processArgumentsRule() {
	writeToAsm("\tPUSH AX\n");
}

void processVariableDeclaration(ParseTreeNode *node) {
	string code = "\tSUB SP, " + to_string(node->getOffset()+stackPointer) + "\n";
	stackPointer = -node->getOffset();
	writeToAsm(code);
}

void processDeclarationListRule(ParseTreeNode *node) {
	if(node->getScope() == "1")return;
	if(node->getNumOfChildren() == 1 || node->getNumOfChildren() == 4)processVariableDeclaration(node->getNthChild(1));
	else processVariableDeclaration(node->getNthChild(3));
}

string getJumpOnFalseOfRelop(string rule) {
	if(isGreaterOp(rule)) return "JLE" ;
	if(isGreaterEqualOp(rule)) return "JL" ;
	if(isLessOp(rule)) return "JGE" ;
	if(isLessEqualOp(rule)) return "JG" ;
	if(isEqualOp(rule)) return "JNE" ;
	if(isNotEqualOp(rule)) return "JE";
	return "";
}

void processRelExpressionComparisonRule(ParseTreeNode *node) {
	auto falseLabel = "L" + to_string(getIncreasedLabel());
	auto exitLabel = "L" + to_string(getIncreasedLabel());
	string code = "\
	POP BX\n\
	XCHG AX, BX\n\
	CMP AX, BX\n\
	" + getJumpOnFalseOfRelop(node->getNthChild(2)->getRule()) + " " + falseLabel + "\n\
	MOV AX, 1" + annotationOfLine(node->getStartOfNode()) + "\
	JMP " + exitLabel + "\n\
" + falseLabel + ":\n\
	XOR AX, AX"+ annotationOfLine(node->getStartOfNode()) +"\
" + exitLabel + ":\n";
	writeToAsm(code);
}

void processLogicExpressionMultipleRelExpressionRule(ParseTreeNode *node) {
	auto trueLabel = "L" + to_string(getIncreasedLabel());
	auto falseLabel = "L" + to_string(getIncreasedLabel());
	auto exitLabel = "L" + to_string(getIncreasedLabel());

	postOrderTraversal(node->getNthChild(1));

	string code = "\tCMP AX, 0\n";

	if(isLogicalAndOp(node->getNthChild(2)->getRule())) {
		code += "\tJE " + falseLabel + "\n";
	}else {
		code += "\tJNE " + trueLabel + "\n";
	}

	writeToAsm(code);

	postOrderTraversal(node->getNthChild(3));

	code = "\tCMP AX, 0\n";

	code += "\tJE " + falseLabel + "\n";

	code += "\
" + trueLabel + ":\n\
	MOV AX, 1" + annotationOfLine(node->getStartOfNode()) + "\
	JMP " + exitLabel + "\n\
" + falseLabel + ":\n\
	XOR AX, AX\n\
" + exitLabel + ":\n";

	writeToAsm(code);
}

void processVariableArrayRule() {
	string code = "\
	PUSH BX\n\
	PUSH CX\n\
	PUSH AX\n";
	writeToAsm(code);
}

void processRuleOfNode(ParseTreeNode *node) {
	string rule = node->getRule();
	if(isDeclarationListRule(rule))processDeclarationListRule(node);
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
	else if(isFactorIDFunctionCallRule(rule))postProcessFactorFunctionCallRule(node);
	else if(isArgumentsRule(rule))processArgumentsRule();
	else if(isRelExpressionComparisonRule(rule))processRelExpressionComparisonRule(node);
	else if(isVariableArrayRule(rule))processVariableArrayRule();
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

void processStatementIfRule(ParseTreeNode *node) {
	postOrderTraversal(node->getNthChild(3));
	auto falseLabel = "L" + to_string(getIncreasedLabel());

	string code = "\
	CMP AX, 0\n\
	JE " + falseLabel + "\n";
	writeToAsm(code);

	auto currentStackPointer = stackPointer;
	postOrderTraversal(node->getNthChild(5));
	auto newStackPointer = stackPointer;
	rollbackStackPointer(currentStackPointer, newStackPointer);
	
	writeToAsm(falseLabel + ":\n");
}

void processStatementWhileRule(ParseTreeNode* node) {
	auto loopLabel = "L" + to_string(getIncreasedLabel());
	auto falseLabel = "L" + to_string(getIncreasedLabel());
	writeToAsm(loopLabel + ":\n");
	postOrderTraversal(node->getNthChild(3));
	string code = "\
	CMP AX, 0\n\
	JE " + falseLabel + "\n";
	writeToAsm(code);

	auto currentStackPointer = stackPointer;
	postOrderTraversal(node->getNthChild(5));
	auto newStackPointer = stackPointer;
	rollbackStackPointer(currentStackPointer,newStackPointer);

	code = "\
	JMP " + loopLabel + "\n"
	+ falseLabel + ":\n";
	writeToAsm(code);
}

void processStatementForLoopRule(ParseTreeNode *node) {
	postOrderTraversal(node->getNthChild(3));
	auto loopLabel = "L" + to_string(labelCount);
	auto exitLabel = "L" + to_string(getIncreasedLabel());

	postOrderTraversal(node->getNthChild(4));

	string code = "\
	CMP AX, 0\n\
	JE " + exitLabel + "\n";

	writeToAsm(code);

	auto currentStackPointer = stackPointer;
	postOrderTraversal(node->getNthChild(7));
	auto newStackPointer = stackPointer;
	rollbackStackPointer(currentStackPointer, newStackPointer);

	postOrderTraversal(node->getNthChild(5));

	code = "\
	JMP " + loopLabel + "\n"
	+ exitLabel + ":\n";

	writeToAsm(code);
}

void processStatementIfElseRule(ParseTreeNode* node) {
	postOrderTraversal(node->getNthChild(3));
	auto falseLabel = "L" + to_string(getIncreasedLabel());
	auto exitLabel = "L" + to_string(getIncreasedLabel());

	string code = "\
	CMP AX, 0\n\
	JE " + falseLabel + "\n";
	writeToAsm(code);

	auto currentStackPointer = stackPointer;
	postOrderTraversal(node->getNthChild(5));
	auto newStackPointer = stackPointer;
	rollbackStackPointer(currentStackPointer, newStackPointer);

	code = "\
	JMP " + exitLabel + "\n\
" + falseLabel + ":\n";
	writeToAsm(code);

	currentStackPointer = stackPointer;
	postOrderTraversal(node->getNthChild(7));
	newStackPointer = stackPointer;
	rollbackStackPointer(currentStackPointer, newStackPointer);

	writeToAsm(exitLabel + ":\n");
}

void processCompoundStatementRule(ParseTreeNode* node) {
	auto currentStackPointer = stackPointer;
	postOrderTraversal(node->getNthChild(1));
	auto newStackPointer = stackPointer;
	rollbackStackPointer(currentStackPointer, newStackPointer);
}

void preProcessFunctionCallRule() {
	writeToAsm("\
	PUSH BX\n\
	PUSH CX\n");
}

bool handleSpecialStatements(ParseTreeNode *node) {
	// skipping some nodes
	if (isGlobalVariableDeclaration(node->getRule()) ||
		isFunctionDeclaration(node->getRule())) return true;

	if (isStatementPrintlnRule(node->getRule())) {
		processStatementPrintlnRule(node);
		return true;
	}

	if (isStatementReturnRule(node->getRule())) {
		processStatementReturnRule(node);
		return true;
	}

	if (isStatementIfRule(node->getRule())) {
		processStatementIfRule(node);
		return true;
	}

	if (isStatementIfElseRule(node->getRule())) {
		processStatementIfElseRule(node);
		return true;
	}

	if (isLogicExpressionMultipleRelExpressionsRule(node->getRule())) {
		processLogicExpressionMultipleRelExpressionRule(node);
		return true;
	}

	if (isFuncDefinitionRule(node->getRule())) {
		preProcessFuncDefinitionRule(node);
		return false;
	}

	if (isStatementWhileRule(node->getRule())) {
		processStatementWhileRule(node);
		return true;
	}

	if (isStatementForLoopRule(node->getRule())) {
		processStatementForLoopRule(node);
		return true;
	}

	if (isFactorIDFunctionCallRule(node->getRule())) {
		preProcessFunctionCallRule();
		return false;
	}

	if(isStatementCompoundStatementRule(node->getRule())) {
		processCompoundStatementRule(node);
		return true;
	}

	return false;
}

void postOrderTraversal(ParseTreeNode *node) {
	if(handleSpecialStatements(node))return;

	for (ParseTreeNode *itr = node->getChild(); itr != nullptr; itr = itr->getSibling()) {
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