#pragma once

#include<stdio.h>
#include<stdlib.h>
#include<string>

// Unit rules

bool isGlobalVariableDeclaration(string rule) { return rule == "unit : var_declaration "; }

bool isFunctionDeclaration(string rule) { return rule == "unit : func_declaration "; }


bool isFuncDefinitionRule(string rule) { 
	return rule == "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement " 
	|| rule == "func_definition : type_specifier ID LPAREN RPAREN compound_statement "; 
}

bool isParameterListRule(string rule) { 
	return rule == "parameter_list : parameter_list COMMA type_specifier ID " 
	|| rule == "parameter_list : parameter_list COMMA type_specifier " 
	|| rule == "parameter_list : type_specifier ID " 
	|| rule == "parameter_list : type_specifier "; 
}

bool isCompoundStatementRule(string rule) { return rule == "compound_statement : LCURL statements RCURL " || rule == "compound_statement : LCURL RCURL "; }

bool isVarDeclarationRule(string rule) { return rule == "var_declaration : type_specifier declaration_list SEMICOLON "; }

bool isTypeSpecifierRule(string rule) { return rule == "type_specifier : INT " || rule == "type_specifier : FLOAT " || rule == "type_specifier : VOID "; }

bool isDeclarationListRule(string rule) { return rule == "declaration_list : declaration_list COMMA ID " || rule == "declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD " || rule == "declaration_list : ID " || rule == "declaration_list : ID LTHIRD CONST_INT RTHIRD "; }

bool isStatementsRule(string rule) { return rule == "statements : statement " || rule == "statements : statements statement "; }

bool isStatementVarDeclarationRule(string rule) { return rule == "statement : var_declaration "; }

bool isStatementExpressionStatementRule(string rule) { return rule == "statement : expression_statement "; }

bool isStatementCompoundStatementRule(string rule) { return rule == "statement : compound_statement "; }

bool isStatementForLoopRule(string rule) { return rule == "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement "; }

bool isStatementIfRule(string rule) { return rule == "statement : IF LPAREN expression RPAREN statement "; }

bool isStatementIfElseRule(string rule) { return rule == "statement : IF LPAREN expression RPAREN statement ELSE statement "; }

bool isStatementWhileRule(string rule) { return rule == "statement : WHILE LPAREN expression RPAREN statement "; }

bool isStatementPrintlnRule(string rule) { return rule == "statement : PRINTLN LPAREN ID RPAREN SEMICOLON "; }

bool isStatementReturnRule(string rule) { return rule == "statement : RETURN expression SEMICOLON "; }

bool isExpressionStatementRule(string rule) { return rule == "expression_statement : SEMICOLON " || rule == "expression_statement : expression SEMICOLON "; }

bool isVariableRule(string rule) { return rule == "variable : ID " || rule == "variable : ID LTHIRD expression RTHIRD "; }

bool isExpressionRule(string rule) { return rule == "expression : logic_expression " || rule == "expression : variable ASSIGNOP logic_expression "; }

bool isLogicExpressionSingleRelExpressionRule(string rule) { return rule == "logic_expression : rel_expression "; }

bool isLogicExpressionMultipleRelExpressionsRule(string rule) { return rule == "logic_expression : rel_expression LOGICOP rel_expression "; }

bool isRelExpressionSimpleExpressionRule(string rule) { return rule == "rel_expression : simple_expression "; }

bool isRelExpressionComparisonRule(string rule) { return rule == "rel_expression : simple_expression RELOP simple_expression "; }

bool isSimpleExpressionTermRule(string rule) { return rule == "simple_expression : term "; }

bool isSimpleExpressionAddOpTermRule(string rule) { return rule == "simple_expression : simple_expression ADDOP term "; }

bool isTermUnaryExpressionRule(string rule) { return rule == "term : unary_expression "; }

bool isTermMulOpUnaryExpressionRule(string rule) { return rule == "term : term MULOP unary_expression "; }

bool isUnaryExpressionAddOpRule(string rule) { return rule == "unary_expression : ADDOP unary_expression "; }

bool isUnaryExpressionNotRule(string rule) { return rule == "unary_expression : NOT unary_expression "; }

bool isUnaryExpressionFactorRule(string rule) { return rule == "unary_expression : factor "; }

bool isFactorVariableRule(string rule) { return rule == "factor : variable "; }

bool isFactorIDFunctionCallRule(string rule) { return rule == "factor : ID LPAREN argument_list RPAREN "; }

bool isFactorExpressionRule(string rule) { return rule == "factor : LPAREN expression RPAREN "; }

bool isFactorConstIntRule(string rule) { return rule == "factor : CONST_INT "; }

bool isFactorConstFloatRule(string rule) { return rule == "factor : CONST_FLOAT "; }

bool isFactorIncOpRule(string rule) { return rule == "factor : variable INCOP "; }

bool isFactorDecOpRule(string rule) { return rule == "factor : variable DECOP "; }

bool isArgumentListRule(string rule) { return rule == "argument_list : arguments " || rule == "argument_list : "; }

bool isArgumentsRule(string rule) { return rule == "arguments : arguments COMMA logic_expression " || rule == "arguments : logic_expression "; }

bool isAssignOpOperation(string rule) { return rule == "expression : variable ASSIGNOP logic_expression "; }

bool isAddOpOperation(string rule) { return rule == "simple_expression : simple_expression ADDOP term ";}

bool isSemiColon(string rule) { return rule == "SEMICOLON : ;"; }

bool isPlusOp(string rule) { return rule == "ADDOP : +"; }
bool isMinusOp(string rule) { return rule == "ADDOP : -"; }

bool isAddOp(string rule) { 
	return isPlusOp(rule) || isMinusOp(rule) ;
}

bool isStarOp(string rule) { return rule == "MULOP : *"; }
bool isDivOp(string rule) { return rule == "MULOP : /"; }
bool isModOp(string rule) { return rule == "MULOP : %"; }

bool isMulOp(string rule) { 
	return isStarOp(rule) || isDivOp(rule) || isModOp(rule);  
}

bool isGreaterOp(string rule) { return rule == "RELOP : >"; }

bool isGreaterEqualOp(string rule) { return rule == "RELOP : >="; }

bool isLessOp(string rule) { return rule == "RELOP : <"; }

bool isLessEqualOp(string rule) { return rule == "RELOP : <="; }

bool isEqualOp(string rule) { return rule == "RELOP : =="; }

bool isNotEqualOp(string rule) { return rule == "RELOP : !="; }

bool isRelop(string rule) { 
	return isGreaterOp(rule) || isGreaterEqualOp(rule) || isLessEqualOp(rule)
	|| isLessOp(rule) || isEqualOp(rule) || isNotEqualOp(rule); 
}

bool isReturn(string rule) { return rule == "RETURN : return"; }

bool isLogicalAndOp(string rule) { return rule == "LOGICOP : &&"; }

bool isLogicalOrOp(string rule) { return rule == "LOGICOP : ||"; }

bool isLogicOp(string rule) { return isLogicalAndOp(rule) || isLogicalOrOp(rule); }