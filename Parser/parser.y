/* for location tracking support,
defines YYLTYPE and YYLOC_DEFAULT */
%locations

/* Includes and definitions 
inserted at the top of the
parser implementation file*/
%code top {
	#define BUCKET_SIZE 11

	#include<stdio.h>
	#include<stdlib.h>
	#include<string>

	#include "ParseTree/ParseTreeNode.h"
	#include "SymbolTable/SymbolTable.h"
	#include "LinkedList/LinkedList.h"

	FILE *log_out, *error_out, *parse_tree_out;
	extern FILE* yyin;
	extern int yylineno;

	SymbolTable *table = new SymbolTable(BUCKET_SIZE);
	LinkedList<SymbolInfo*> ids;

	string current_rule = "";

	unsigned long syntaxErrorCount = 0; 

	// TODO : Decide where the following declaration belongs
	void yyerror(const char *error);
}

%union { 
	SymbolInfo* symbolInfo;
	ParseTreeNode* parseTreeNode;
}

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

%type <parseTreeNode> start program unit var_declaration func_declaration func_definition
%type <parseTreeNode> type_specifier parameter_list compound_statement
%type <parseTreeNode> declaration_list statements statement expression_statement
%type <parseTreeNode> variable expression logic_expression rel_expression simple_expression
%type <parseTreeNode> term unary_expression factor argument_list arguments

/* Code in the parser header file and the parser implementation 
file after the Bison-generated value and location types 
(YYSTYPE and YYLTYPE in C), and token definitions */
%code provides {
	// macros for first_line and last_line of YYLTYPE struct
	#ifndef F_L
	#define F_L first_line
	#endif
	
	#ifndef L_L
	#define L_L last_line
	#endif
}

/* place for non-dependency functions */
%code {
	#define PTN ParseTreeNode

	int yyparse(void);
	int yylex(void);

	void writeRuleToLog(string& rule) {
		fprintf(log_out,"%s\n",rule.c_str());
	}

	void yyerror(const char *error) {
		fprintf(error_out,"%s\n",error);
	}

	void printParseTree(PTN* node) {
		fprintf(parse_tree_out,"%s",node->print().c_str());
	}

	void initRule(string rule) {
		current_rule = rule;
		writeRuleToLog(current_rule);
	}

	string symbolToRule(SymbolInfo* node){
		return node->getType().append(" : ").append(node->getName());
	}

	void insertSymbolsToTable() {
		int currPos = ids.currPos();
		ids.setToBegin();
		for(int i=0;i<ids.length();i++){
			table->insert(ids.getValue());
			ids.next();
		}
		ids.setToPos(currPos);
	}
}

%%

start : program
	{
		initRule("start : program ");
		$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,$1);
		printParseTree($$);
		ids.clear();
	}
	;

program : program unit
		{
			initRule("program : program unit ");
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(2,$1,$2);
		}
		| unit
		{
			initRule("program : unit ");
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,$1);
		}
		;

unit : var_declaration
	{
		initRule("unit : var_declaration ");
		$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,$1);
	}
	| func_declaration
	{
		initRule("unit : func_declaration ");
		$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,$1);
	}
	| func_definition
	{
		initRule("unit : func_definition ");
		$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,$1);
	}
	;

{
	// TODO : Handle 
	// insertion of func declarations in symbol table
}

func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
		{
			initRule("func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON ");
			auto idNode = new PTN(symbolToRule($2),@2.F_L);
			auto lParenNode = new PTN("LPAREN : (",@3.F_L);
			auto rParenNode = new PTN("RPAREN : )",@5.F_L);
			auto semiColonNode = new PTN("SEMICOLON : ;",@6.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(6,$1,idNode,lParenNode,$4,rParenNode,semiColonNode);
		}
		| type_specifier ID LPAREN RPAREN SEMICOLON
		{
			initRule("func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON ");
			auto idNode = new PTN(symbolToRule($2),@2.F_L);
			auto lParenNode = new PTN("LPAREN : (",@3.F_L);
			auto rParenNode = new PTN("RPAREN : )",@4.F_L);
			auto semiColonNode = new PTN("SEMICOLON : ;",@5.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(5,$1,idNode,lParenNode,rParenNode,semiColonNode);
		}
		;

func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement
		{
			initRule("func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement ");
			auto idNode = new PTN(symbolToRule($2),@2.F_L);
			auto lParenNode = new PTN("LPAREN : (",@3.F_L);
			auto rParenNode = new PTN("RPAREN : )",@5.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(6,$1,idNode,lParenNode,$4,rParenNode,$6);
		}
		| type_specifier ID LPAREN RPAREN compound_statement
		{
			initRule("func_definition : type_specifier ID LPAREN RPAREN compound_statement ");
			auto idNode = new PTN(symbolToRule($2),@2.F_L);
			auto lParenNode = new PTN("LPAREN : (",@3.F_L);
			auto rParenNode = new PTN("RPAREN : )",@4.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(5,$1,idNode,lParenNode,rParenNode,$5);		
		}
		;

parameter_list : parameter_list COMMA type_specifier ID
		{
			initRule("parameter_list  : parameter_list COMMA type_specifier ID ");
			auto commaNode = new PTN("COMMA : ,",@2.F_L);
			auto idNode = new PTN(symbolToRule($4),@4.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(4,$1,commaNode,$3,idNode);
		}
		| parameter_list COMMA type_specifier
		{
			initRule("parameter_list : parameter_list COMMA type_specifier ");
			auto commaNode = new PTN("COMMA : ,",@2.F_L);
			auto idNode = new PTN(symbolToRule($4),@4.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(4,$1,commaNode,$3,idNode);
		}
		| type_specifier ID
		{
			initRule("parameter_list COMMA type_specifier ");
			auto idNode = new PTN(symbolToRule($2),@2.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(2,$1,idNode);
		}
		| type_specifier
		{
			initRule("parameter_list COMMA type_specifier ");
			auto idNode = new PTN(symbolToRule($2),@2.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(2,$1,idNode);
		}
		;

compound_statement : LCURL statements RCURL
	| LCURL RCURL
	;

{
	// TODO  : Handle
	// void as type_specifier error
	// redeclaration of variable
}

var_declaration : type_specifier declaration_list SEMICOLON
				{
					initRule("var_declaration : type_specifier declaration_list SEMICOLON ");
					auto semiColonNode = new PTN("SEMICOLON : ;",@3.F_L);
					$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(3,$1,$2,semiColonNode);
					insertSymbolsToTable();
				}
				;

type_specifier	: INT
		{
			initRule("type_specifier	: INT ");
			auto intNode = new PTN("INT : int",@1.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,intNode);
		}
		| FLOAT
		{
			initRule("type_specifier	: FLOAT ");
			auto floatNode = new PTN("FLOAT : int",@1.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,floatNode);
		}
		| VOID
		{
			initRule("type_specifier	: VOID ");
			auto voidNode = new PTN("VOID : void",@1.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,voidNode);
		}
		;

{
	// TODO : Handle negative and fraction as array size
}


declaration_list : declaration_list COMMA ID
				{
					initRule("declaration_list COMMA ID ");
					auto commaNode = new PTN("COMMA : ,",@2.F_L);
					auto idNode = new PTN(symbolToRule($3),@3.F_L);
					$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(3,$1,commaNode,idNode);
					ids.pushBack($3);
				}
				| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
				{
					initRule("declaration_list COMMA ID LSQUARE CONST_INT RSQUARE ");
					auto commaNode = new PTN("COMMA : ,",@2.F_L);
					auto idNode = new PTN(symbolToRule($3),@3.F_L);
					auto lSquareNode = new PTN("LSQUARE : [",@4.F_L);
					auto constIntNode = new PTN(symbolToRule($5),@5.F_L);
					auto rSquareNode = new PTN("RQUARE : ]",@6.F_L);
					$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
					->addChildrenToNode(6,$1,commaNode,idNode,lSquareNode,constIntNode,rSquareNode);
					$3->setType("ARRAY");
					ids.pushBack($3);
				}
				| ID
				{
					initRule("declaration_list : ID ");
					auto idNode = new PTN(symbolToRule($1),@1.F_L);
					$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,idNode);
					ids.pushBack($1);
				}
				| ID LTHIRD CONST_INT RTHIRD
				{
					initRule("ID LSQUARE CONST_INT RSQUARE ");
					auto idNode = new PTN(symbolToRule($1),@1.F_L);
					auto lSquareNode = new PTN("LSQUARE : [",@2.F_L);
					auto constIntNode = new PTN(symbolToRule($3),@3.F_L);
					auto rSquareNode = new PTN("RQUARE : ]",@4.F_L);
					$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
					->addChildrenToNode(4,idNode,lSquareNode,constIntNode,rSquareNode);
					$1->setType("ARRAY");
					ids.pushBack($1);
				}
				;

statements : statement
		{
			initRule("statements : statement ");
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,$1);
		}
		| statements statement
		{
			initRule("statements : statements statement ");
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(2,$1,$2);
		}
		;

statement : var_declaration
		{
			initRule("statement : var_declaration ");
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,$1);
		}
		| expression_statement
		{
			initRule("statement : expression_statement ");
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,$1);
		}
		| compound_statement
		{
			initRule("statement : compound_statement ");
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,$1);
		}
		| FOR LPAREN expression_statement expression_statement expression RPAREN statement
		{
			initRule("statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement ");
			auto forNode = new PTN("FOR : for",@1.F_L);
			auto lParenNode = new PTN("LPAREN : (",@2.F_L);
			auto rParenNode = new PTN("RPAREN : )",@6.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(7,forNode,lParenNode,$3,$4,$5,rParenNode,$7);
		}
		| IF LPAREN expression RPAREN statement
		{
			initRule("statement : IF LPAREN expression RPAREN statement ");
			auto ifNode = new PTN("IF : if",@1.F_L,@1.F_L);
			auto lParenNode = new PTN("LPAREN : (",@2.F_L);
			auto rParenNode = new PTN("RPAREN : )",@4.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(5,ifNode,lParenNode,$3,rParenNode,$5);
		}
		| IF LPAREN expression RPAREN statement ELSE statement
		{
			initRule("statement : IF LPAREN expression RPAREN statement ELSE statement ");
			auto ifNode = new PTN("IF : if",@1.F_L);
			auto lParenNode = new PTN("LPAREN : (",@2.F_L);
			auto rParenNode = new PTN("RPAREN : )",@4.F_L);
			auto elseNode = new PTN("ELSE : else",@6.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(7,ifNode,lParenNode,$3,rParenNode,$5,elseNode,$7);
		}
		| WHILE LPAREN expression RPAREN statement
		{
			initRule("statement : WHILE LPAREN expression RPAREN statement ");
			auto ifNode = new PTN("IF : if",@1.F_L);
			auto lParenNode = new PTN("LPAREN : (",@2.F_L);
			auto rParenNode = new PTN("RPAREN : )",@4.F_L);
			auto elseNode = new PTN("ELSE : else",@6.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(7,ifNode,lParenNode,$3,rParenNode,$5,elseNode,$7);			
		}
		| PRINTLN LPAREN ID RPAREN SEMICOLON
		{
			initRule("statement : PRINTLN LPAREN ID RPAREN SEMICOLON ");
			auto printlnNode = new PTN("PRINTLN : println",@1.F_L);
			auto lParenNode = new PTN("LPAREN : (",@2.F_L);
			auto idNode = new PTN(symbolToRule($3),@3.F_L);
			auto rParenNode = new PTN("RPAREN : )",@4.F_L);
			auto semicolonNode = new PTN("SEMICOLON : ;",@5.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(5,printlnNode,lParenNode,idNode,rParenNode,$5,semicolonNode);				
		}
		| RETURN expression SEMICOLON
		{
			initRule("statement : RETURN expression SEMICOLON ");
			auto printlnNode = new PTN("RETURN : return",@1.F_L);
			auto semicolonNode = new PTN("SEMICOLON : ;",@3.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(3,returnNode,$2,semicolonNode);				
		}
		;

expression_statement : SEMICOLON
					{
						initRule("expression_statement : SEMICOLON ");
						auto semicolonNode = new PTN("SEMICOLON : ;",@1.F_L);
						$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,semicolonNode);
					}
					| expression SEMICOLON
					{
						initRule("expression_statement : expression SEMICOLON ");
						auto semicolonNode = new PTN("SEMICOLON : ;",@2.F_L);
						$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(2,$1,semicolonNode);
					}
					;

variable : ID
		{
			initRule("variable : ID ");
			auto idNode = new PTN(symbolToRule($1),@1.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,idNode);
		}
		| ID LTHIRD expression RTHIRD
		{
			initRule("ID LTHIRD expression RTHIRD ");
			auto idNode = new PTN(symbolToRule($1),@1.F_L);
			auto lSquareNode = new PTN("LSQUARE : [",@2.F_L);
			auto rSquareNode = new PTN("RQUARE : ]",@4.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(4,idNode,lSquareNode,$3,rSquareNode);
		}
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

factor : variable
		| ID LPAREN argument_list RPAREN
		| LPAREN expression RPAREN
		| CONST_INT 
		| CONST_FLOAT
		| variable INCOP 
		| variable DECOP
		;

argument_list : arguments
			;

arguments : arguments COMMA logic_expression
		| logic_expression
		;

%%

/* in code section at the end of the parser */

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

	if (dotPosition == string::npos || inputFileName.substr(dotPosition) != ".c") {
	   cout << "Invalid file extension. Please provide a .c file." << endl;
	   exit(1);
	}

	FILE *fin = fopen(argv[1],"r");
	if(fin==NULL){ 
		printf("Cannot open specified file\n");
		exit(1);
	}

	log_out = fopen(LOG_FILE,"w");
	error_out = fopen(ERROR_FILE,"w");
	parse_tree_out = fopen(PARSE_TREE_FILE,"w");

	yyin = fin;
	yyparse();

	fprintf(log_out,"Total lines: %d\n",yylineno);
	fprintf(log_out,"Total errors: %d\n",syntaxErrorCount);

	fclose(parse_tree_out);
	fclose(error_out);
	fclose(log_out);

	fclose(yyin);

	// table.~SymbolTable() ;

	return 0;
}