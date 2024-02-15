#pragma once

void generateASM(ParseTreeNode *node);

void writeToAsm(std::string code);

void printHeaderComment(std::string comment);

std::string annotationOfLine(unsigned long lineNo);

void adjustStackPointer();

void printPopAx(ParseTreeNode *node);

void headerCode();

void footerCode();

std::string printNewlineCode();

void printOutput();

void declareGlobalVariablesInASM();

void printLabel(unsigned long labelCount);

unsigned long getIncreasedLabel();

void insertFunctionHeaderCode(SymbolInfo* func);

void insertFunctionFooterCode(SymbolInfo* func);

void processIdNode(ParseTreeNode* node);

void processAssignOpNode(ParseTreeNode* node);

void processFactorConstIntRule(ParseTreeNode *node);

void processAddOpNode(ParseTreeNode *node);

void processMulOpNode();

void processRelOpNode();

void processSimpleExpressionAddOpTermRule(ParseTreeNode *node);

void processTermMulOpUnaryExpressionRule(ParseTreeNode *node);

void processFactorFunctionCallRule(ParseTreeNode *node);

void postOrderTraversal(ParseTreeNode *node);

void processRelExpressionSimpleExpressionRule(ParseTreeNode *node);

void processSimpleExpressionTermRule(ParseTreeNode *node);

void processUnaryExpressionFactorRule(ParseTreeNode *node);

void processTermUnaryExpressionRule(ParseTreeNode *node);

void postProcessFunctionDefintionRule(ParseTreeNode *node);

void processArgumentsRule();

void processRelExpressionComparisonRule(ParseTreeNode *node);

void processStatementIfRule(ParseTreeNode *node);

void processStatementIfElseRule(ParseTreeNode *node);