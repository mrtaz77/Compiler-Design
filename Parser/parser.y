/* code that should appear at the top of the parser file */
%code top {
	#define BUCKET_SIZE 11

	#include<stdio.h>
	#include<stdlib.h>
	#include<string>

	#include"ParseTree/ParseTreeNode.h"
	#include"SymbolTable/SymbolTable.h"

	File *log_out,*error_out,*parse_tree_out;

	SymbolTable table(BUCKET_SIZE);
}

/* code that should appear after the definition of YYLTYPE */
%code requires {
	void yyerror(const YYLTYPE *loc,const char *error);
}

/* place for non-dependency functions */
%code {
	int yyparse(void);
	int yylex(void);
}

/* for location tracking support,
defines YYLTYPE and YYLOC_DEFAULT */
%locations

/* Specify how the generated parser should include the generated header,
avoid duplication of code and ensure consistency between the parser definition
and its implementation ,i.e, include intead of duplicate */
%define api.header.include { "MyParser.h" }

%union { 
	SymbolInfo* symbolInfo;
	ParseTreeNode* parseTreeNode;
}

%type <parseTreeNode> start program unit var_declaration func_declaration func_definition
%type <parseTreeNode> type_specifier parameter_list compound_statement
%type <parseTreeNode> declaration_list statements statement expression_statement
%type <parseTreeNode> variable expression logic_expression rel_expression simple_expression
%type <parseTreeNode> term unary_expression factor argument_list arguments

%token VOID IF ELSE FOR WHILE INT FLOAT 
%token LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD
%token SEMICOLON COMMA 
%token <symbolInfo> ID CONST_INT CONST_FLOAT 
%token PRINTLN RETURN

%right ASSIGNOP
%left <symbolInfo> LOGICOP
%left <symbolInfo> RELOP
%left <symbolInfo> ADDOP
%left <symbolInfo> MULOP
%right NOT
%right INCOP DECOP

%%

start : program
	{
		//write your code in this block in all the similar blocks below
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


parameter_list  : parameter_list COMMA type_specifier ID
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

expression_statement	: SEMICOLON			
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

term :	unary_expression
	|  term MULOP unary_expression
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

/* in code section at the end of the parser */

void yyerror(const YYLTYPE *loc,const char *error) {
	// TODO write error message format here
}

#define LOG_FILE "log.txt"
#define PARSE_TREE_FILE "parsetree.txt"
#define ERROR_FILE "error.txt"


int main(int argc,char *argv[])
{
	if(argc!=2){ 
		printf("Usage ./a.out <file_name>");
		exit(1); 
	}

	string inputFileName(argv[1]);
    size_t dotPosition = inputFileName.find_last_of('.');
    
    if (dotPosition == npos || inputFileName.substr(dotPosition) != ".c") {
        cout << "Invalid file extension. Please provide a .c file." << endl;
        exit(1);
    }

	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){ 
		printf("Cannot open specified file\n");
		exit(1);
	}

	log_out = fopen(LOG_FILE,"w");
	error_out = fopen(ERROR_FILE,"w");

	yyin = fin;
	yyparse();

	parse_tree_out = fopen(PARSE_TREE_FILE,"w");

	fclose(parse_tree_out);
	fclose(error_out);
	fclose(log_out);

	fclose(yyin);

	// table.~SymbolTable() ;

	return 0;
}