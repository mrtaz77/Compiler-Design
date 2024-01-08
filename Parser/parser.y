%{
#define YYSTYPE SymbolInfo*

#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include<fstream>
#include<sstream>

#include"Symboltable/SymbolInfo.h"

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;

ofstream logout, parseout, errorout;


%}

%union {
	SymbolInfo* symbolInfo;
}

%type start program unit var_declaration func_declaration func_definition
%type type_specifier parameter_list compound_statement
%type declaration_list statements statement expression_statement
%type variable expression logic_expression rel_expression simple_expression
%type term unary_expression factor argument_list arguments

%token VOID IF ELSE FOR WHILE INT FLOAT 
%token LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD
%token SEMICOLON COMMA 
%token <symbolInfo> ID CONST_INT CONST_FLOAT 
%token PRINTLN RETURN

%right ASSIGNOP
%nonassoc <symbolInfo> LOGICOP
%nonassoc <symbolInfo> RELOP
%left <symbolInfo> ADDOP
%left <symbolInfo> MULOP
%right NOT
%right INCOP DECOP

%%

start : program
	{
		// Write your code in this block in all the similar blocks below
	}
	;

program : program unit 
	| unit
	;
	
unit : var_declaration
	| func_declaration
	| func_definition
	;
	
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
		| type_specifier ID LPAREN RPAREN SEMICOLON
		;
		
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement
		| type_specifier ID LPAREN RPAREN compound_statement
		;				


parameter_list: parameter_list COMMA type_specifier ID
		| parameter_list COMMA type_specifier
		| type_specifier ID
		| type_specifier
		;

compound_statement : LCURL statements RCURL
			| LCURL RCURL
			;

var_declaration : type_specifier declaration_list SEMICOLON
		;
				
type_specifier	: INT
		| FLOAT
		| VOID
		;
				
declaration_list : declaration_list COMMA ID
		| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
		| ID
		| ID LTHIRD CONST_INT RTHIRD
		;
				
statements : statement
	| statements statement
	;
	
statement : var_declaration
	| expression_statement
	| compound_statement
	| FOR LPAREN expression_statement expression_statement expression RPAREN statement
	| IF LPAREN expression RPAREN statement
	| IF LPAREN expression RPAREN statement ELSE statement
	| WHILE LPAREN expression RPAREN statement
	| PRINTLN LPAREN ID RPAREN SEMICOLON
	| RETURN expression SEMICOLON
	;
	
expression_statement 	: SEMICOLON			
			| expression SEMICOLON 
			;
	
variable : ID		
	| ID LTHIRD expression RTHIRD 
	;
	
expression : logic_expression	
	| variable ASSIGNOP logic_expression 	
	;
			
logic_expression : rel_expression 	
		| rel_expression LOGICOP rel_expression 	
		;
			
rel_expression	: simple_expression 
		| simple_expression RELOP simple_expression	
		;
				
simple_expression : term 
		| simple_expression ADDOP term 
		;
					
term : unary_expression
	| term MULOP unary_expression
	;

unary_expression : ADDOP unary_expression 
		| NOT unary_expression 
		| factor 
		;
	
factor	: variable 
	| ID LPAREN argument_list RPAREN
	| LPAREN expression RPAREN
	| CONST_INT 
	| CONST_FLOAT
	| variable INCOP 
	| variable DECOP
	;
	
argument_list : arguments
			|
			;
	
arguments : arguments COMMA logic_expression
		| logic_expression
		;


%%

#define LOG_FILE "log.txt"
#define PARSE_TREE_FILE "parsetree.txt"
#define ERROR_FILE "error.txt"


int main(int argc,char *argv[])
{

	if(argc!=2){
		printf("Usage ./a.out <file_name>");
		return 0;
	}

	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}

	logout.open(LOG_FILE,out);
	parseout.open(PARSE_TREE_FILE,out);
	errorout.open(ERROR_FILE,out);
	

	yyin = fin;
	yyparse();
	

	fclose(yyin);

	logout.close();
	parseout.close();
	errorout.close();
	
	return 0;
}