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

	#include "SymbolTable/SymbolTable.h"

	FILE *log_out, *error_out, *parse_tree_out;
	extern FILE* yyin;
	extern int yylineno;
	extern unsigned long errorCount;

	SymbolTable *table = new SymbolTable(BUCKET_SIZE);
	SymbolInfo *currentFunction;

	string current_rule = "";

	void yyerror(char *error) {
		fprintf(log_out, "Error at line no %d : syntax error\n",yylineno);
	}
}

%union { 
	SymbolInfo* symbolInfo;
	ParseTreeNode* parseTreeNode;
}

%type <parseTreeNode> start program unit var_declaration func_declaration func_definition
%type <parseTreeNode> type_specifier parameter_list compound_statement
%type <parseTreeNode> declaration_list statements statement expression_statement
%type <parseTreeNode> variable expression logic_expression rel_expression simple_expression
%type <parseTreeNode> term unary_expression factor argument_list arguments

%start start

%token VOID IF ELSE FOR WHILE INT FLOAT 
%token LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD
%token SEMICOLON COMMA 
%token <symbolInfo> ID CONST_INT CONST_FLOAT 
%token PRINTLN RETURN

%nonassoc LOWER_THAN_ELSE_AS_IN_BOOK
%nonassoc ELSE

%right ASSIGNOP
%left <symbolInfo> LOGICOP
%left <symbolInfo> RELOP
%left <symbolInfo> ADDOP
%left <symbolInfo> MULOP
%right NOT
%right INCOP DECOP

%destructor { if($$ != nullptr)$$->~ParseTreeNode();} <parseTreeNode>
%destructor { if($$ != nullptr)$$->~SymbolInfo();} <symbolInfo>

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
	vector<SymbolInfo*> ids,parameters;
	bool parameterRedefined = false;
	bool returnFlag = false;

	int yyparse(void);
	int yylex(void);

	void writeRuleToLog(string& rule) {
		fprintf(log_out,"%s\n",rule.c_str());
	}

	void semanticError(string& error, unsigned long lineNo) {
		errorCount++;
		fprintf(error_out,"Line# %d: %s\n",lineNo,error.c_str());
	}

	void printParseTree(PTN* node) {
		fprintf(parse_tree_out,"%s",node->print().c_str());
	}

	void initRule(string rule) {
		current_rule = rule;
		writeRuleToLog(current_rule);
	}

	void initError(char* error,int lineNo) {
		errorCount++;
		fprintf(error_out,"Line# %d: Syntax error at %s\n",lineNo,error);
	}

	string symbolToRule(SymbolInfo* node){
		return node->getType().append(" : ").append(node->getName());
	}

	bool isParameterRedefined(SymbolInfo* parameter) {
		for(unsigned long i = 0; i < parameters.size(); i++) {
			auto currParam = parameters[i];
			if(currParam->getName() == parameter->getName()){
				parameterRedefined = true;
				string error = "Redefinition of parameter \'" + parameter->getName() + "\'";
				semanticError(error,parameter->getNode()->getStartOfNode());
				return true;
			}
		}
		return false;
	}

	void isAnyParameterUnnamed() {
		for(unsigned long i = 0; i < parameters.size(); i++) {
			auto currParam = parameters[i];
			if(currParam->getName() == ""){
				string error = "Name ommitted for parameter "+ to_string(i+1) +" in definition of function \'" + currentFunction->getName() + "\'";
				semanticError(error,currParam->getNode()->getStartOfNode()); 
			}
		}
	}

	string typeToString(Type_Spec type){
		switch(type) {
			case Type_Spec::TYPE_VOID: return "VOID";
			case Type_Spec::TYPE_INT: return "INT";
			case Type_Spec::TYPE_FLOAT: return "FLOAT";
			default: return "NAT";
		}
	}

	string functionType(Type_Spec type) {
		string strType = "FUNCTION,";
		strType.append(typeToString(type));
		return strType;
	}

	void redeclarationAsDifferentSymbol(SymbolInfo* func){
		auto node = func->getNode();
		if(!node->isFunctionDeclared()){
			string error = "\'" 
							+ currentFunction->getName() 
							+ "\' redeclared as different kind of symbol";
			semanticError(error,currentFunction->getNode()->getStartOfNode());
		}
	}

	void alreadyDefined(SymbolInfo* func){
		auto node = func->getNode();
		if(node->isFunctionDefined()){
			string error = "Redefinition of function \'" 
							+ func->getName() 
							+ "\'" ;
			semanticError(error,currentFunction->getNode()->getStartOfNode());
		}
	}

	void conflictingTypes(SymbolInfo *id) {
		string error = "Conflicting types for \'"
						+ id->getName() + "\'";
		semanticError(error,yylineno);
	}

	bool parameterTypeMismatch(SymbolInfo* func) {
		auto currentParameters = currentFunction->getNode()->getParameters();
		auto prevParameters = func->getNode()->getParameters();

		bool error = false;

		for(unsigned long i = 0 ; i < currentParameters.size(); i++){

			auto curr = currentParameters[i]->getType();
			auto prev = prevParameters[i]->getType();

			if(curr != prev){
				error = true;
				string error = "Type mismatch for parameter " 
								+ to_string(i+1) 
								+ " of \'"
								+ func->getName() 
								+ "\'";
				semanticError(error,currentFunction->getNode()->getStartOfNode());
			}
		}
		return error;
	}

	void argumentTypeMismatch(SymbolInfo* prevFunction,PTN* argumentList){
		auto curr = argumentList->getParameters();
		auto prev = prevFunction->getNode()->getParameters();

		for(unsigned int i = 0;i < curr.size(); i++){

			auto currType = curr[i]->getType();
			auto prevType = prev[i]->getType();


			if(currType != prevType) {
				string error = "Type mismatch for argument "
							+ to_string(i+1) + " of \'"
							+ prevFunction->getName() + "\'";
				semanticError(error,argumentList->getStartOfNode());
			}
		}
	}

	void preProcessFunction(Type_Spec type,SymbolInfo* func) {
		func->setType(functionType(type));
		auto funcNode = func->getNode();
		funcNode->setType(type);
		for(unsigned int i = 0; i < parameters.size(); i++){
			funcNode->addParameter(parameters[i]->getNode());
		}
		funcNode->declareFunction(true);
	}

	void voidAsVariableType(SymbolInfo *id){
		string error = "Variable or field \'" 
						+ id->getName() 
						+ "\' declared void";
		semanticError(error,id->getNode()->getStartOfNode());
	}

	void returnFromVoid(SymbolInfo *id){
		string error = "Return from void type function \'"
						+ id->getName() + "\'";
		semanticError(error,id->getNode()->getStartOfNode());
	}

	void noReturnFromFunction(SymbolInfo *id){
		string error = "Warning: No return from function \'"
						+ id->getName() +"\'";
		semanticError(error,id->getNode()->getStartOfNode());
	}

	void insertFunction(Type_Spec type,SymbolInfo* func,bool defineNow) {
		currentFunction = func;
		preProcessFunction(type,func);
		if(defineNow) {
			auto funcNode = func->getNode();
			funcNode->defineFunction(true);
			isAnyParameterUnnamed();
		}
		parameters.clear();
		parameterRedefined = false;
		if(table->lookUp(func->getName()) == nullptr) {
			if(!defineNow)table->insert(func);
			return;
		}

		auto prevFunction = table->lookUp(func->getName());
		auto prevFuncNode = prevFunction->getNode();

		if(!prevFuncNode->isFunctionDeclared())redeclarationAsDifferentSymbol(prevFunction);
		else if(prevFuncNode->isFunctionDefined())alreadyDefined(prevFunction);
		else {
			if(!((prevFuncNode->getType() == type) && (prevFuncNode->getNumParameters() == func->getNode()->getNumParameters())))conflictingTypes(prevFunction);
			else if(type == Type_Spec::TYPE_VOID && returnFlag)returnFromVoid(func);
			else if(type != Type_Spec::TYPE_VOID && !returnFlag)noReturnFromFunction(func);
			else {
				auto error = parameterTypeMismatch(prevFunction);
				if(!error) {
					if(defineNow) {
						prevFuncNode->defineFunction(true);
						prevFuncNode->setParameters(func->getNode()->getParameters());
						currentFunction = prevFunction;
					}
					else{
						string error = "Redeclaration of function \'" + func->getName() + "\'";
						semanticError(error,func->getNode()->getStartOfNode());
					}
				}
			}
		}	
	}

	string idNameFromRule(string rule){
		if(rule.length() <= 5) return "";
		else {
			string name = "";
			for(int i = 5; i < rule.length() ; i++) {
				name += rule[i];
			}
			return name;
		}
	}

	void insertParametersToScope() {
		auto params = currentFunction->getNode()->getParameters();
		for(int i = 0; i < params.size() ; i++) {
			auto name = idNameFromRule(params[i]->getRule());
			auto type = typeToString(params[i]->getType());
			auto symbol = new SymbolInfo(name,type);
			symbol->setNode(params[i]);
			table->insert(symbol);
		}
	}

	void insertParametersForErrorRecovery() {
		for(int i = 0; i < parameters.size() ; i++) {
			auto symbol = parameters[i];
			if(symbol->getName() == "")symbol->setName("NN");
			symbol->setType(typeToString(symbol->getNode()->getType()));
			table->insert(symbol);
		}
		parameters.clear();
	}

	void undeclaredVariable(SymbolInfo* id) {
		string error = "Undeclared variable \'" 
					+ id->getName() + "\'";
		semanticError(error,yylineno);
	}

	void variableTypeMisMatch(SymbolInfo* id,string type) {
		string error = "\'" + id->getName() 
						+ "\' is not "
						+ type;
		semanticError(error,yylineno);
	}

	SymbolInfo* validVariable(SymbolInfo* id) {
		auto prevId = table->lookUp(id->getName());
		if(prevId == nullptr)undeclaredVariable(id);
		else if(prevId->getNode()->isFunctionDeclared())variableTypeMisMatch(id,"an id of valid type");
		return prevId;
	}

	SymbolInfo* validArray(SymbolInfo* id) {
		auto prevId = validVariable(id);
		if(prevId != nullptr && !prevId->getNode()->isArray())variableTypeMisMatch(id,"an array");
		return prevId;
	}

	void invalidArraySubscript(PTN* node) {
		string error = "Array subscript is not an integer";
		semanticError(error,node->getStartOfNode());
	}

	Type_Spec typecast(Type_Spec type1, Type_Spec type2) {
		if(type1 == Type_Spec::TYPE_VOID || type2 == Type_Spec::TYPE_VOID)return Type_Spec::TYPE_VOID;
		else if(type1 == Type_Spec::TYPE_FLOAT || type2 == Type_Spec::TYPE_FLOAT)return Type_Spec::TYPE_FLOAT;
		else if(type1 == Type_Spec::TYPE_INT || type2 == Type_Spec::TYPE_INT)return Type_Spec::TYPE_INT;
		else return Type_Spec::NAT;
	}

	void printSymbolTable() {
		fprintf(log_out,"%s",table->printAllScopes().c_str());
	}

	void insertVariables(Type_Spec type){
		for(unsigned long i = 0; i < ids.size(); i++) {
			auto id = ids[i];
			if(type == 23)voidAsVariableType(id);
			else {
				if(id->getType() != "ARRAY")id->setType(typeToString(type));
				id->getNode()->setType(type);
				bool isNewDeclaration = table->insert(id);
				bool isConflictingType = false;
				if(!isNewDeclaration) {
					auto prevId = table->lookUp(id->getName());
					if(prevId->getType() == id->getType()){
						if(prevId->getNode()->getType() == id->getNode()->getType()){
							if(prevId->getNode()->getArraySize() == id->getNode()->getArraySize()){
								string error = "Redeclaration of variable \'" + id->getName() + "\'";
								semanticError(error,id->getNode()->getStartOfNode());
								prevId->getNode()->setStartOfNode(id->getNode()->getStartOfNode());
							}
							else isConflictingType = true;
						}
						else isConflictingType = true;
					}
					else isConflictingType = true;
					if(isConflictingType)conflictingTypes(id);
				}
			}
		}
	}

	bool arrayAsOperands(PTN* node1, PTN* node2,SymbolInfo* op){
		auto isArr1 = node1->isArray();
		auto isArr2 = node2->isArray();
		if(isArr1||isArr2) {
			string error = "Invalid array type operands to operator \'" 
							+ op->getName() + "\'";
			semanticError(error,yylineno);
			return true;
		}
		return false;
	}
}

%%

start : program
	{
		initRule("start : program ");
		$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,$1);
		printParseTree($$);
		ids.clear();
		printSymbolTable();
		// table->~SymbolTable();
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

func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
		{
			initRule("func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON ");
			auto idNode = new PTN(symbolToRule($2),@2.F_L);
			$2->setNode(idNode);
			insertFunction($1->getType(),$2,false);
			auto lParenNode = new PTN("LPAREN : (",@3.F_L);
			auto rParenNode = new PTN("RPAREN : )",@5.F_L);
			auto semiColonNode = new PTN("SEMICOLON : ;",@6.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(6,$1,idNode,lParenNode,$4,rParenNode,semiColonNode);
			$$->setType($1->getType());
		}
		| type_specifier ID LPAREN RPAREN SEMICOLON
		{
			initRule("func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON ");
			auto idNode = new PTN(symbolToRule($2),@2.F_L);
			$2->setNode(idNode);
			insertFunction($1->getType(),$2,false);
			auto lParenNode = new PTN("LPAREN : (",@3.F_L);
			auto rParenNode = new PTN("RPAREN : )",@4.F_L);
			auto semiColonNode = new PTN("SEMICOLON : ;",@5.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(5,$1,idNode,lParenNode,rParenNode,semiColonNode);
			$$->setType($1->getType());
		}
		| type_specifier ID LPAREN parameter_list error RPAREN SEMICOLON
		{
			initError("parameter list of function declaration",@$.F_L);
			auto idNode = new PTN(symbolToRule($2),@2.F_L);
			auto lParenNode = new PTN("LPAREN : (",@3.F_L);
			auto errorNode = new PTN("parameter_list : error",$4->getStartOfNode());
			auto rParenNode = new PTN("RPAREN : )",@6.F_L);
			auto semiColonNode = new PTN("SEMICOLON : ;",@7.F_L);
			$$ = (new PTN("type_specifier ID LPAREN parameter_list RPAREN SEMICOLON ",@$.F_L,@$.L_L))
			->addChildrenToNode(6,$1,idNode,lParenNode,errorNode,rParenNode,semiColonNode);
		}
		| type_specifier ID LPAREN error RPAREN SEMICOLON
		{
			initError("parameter list of function declaration",@$.F_L);
			auto idNode = new PTN(symbolToRule($2),@2.F_L);
			auto lParenNode = new PTN("LPAREN : (",@3.F_L);
			auto errorNode = new PTN("parameter_list : error",@4.F_L);
			auto rParenNode = new PTN("RPAREN : )",@5.F_L);
			auto semiColonNode = new PTN("SEMICOLON : ;",@6.F_L);
			$$ = (new PTN("type_specifier ID LPAREN RPAREN SEMICOLON ",@$.F_L,@$.L_L))
			->addChildrenToNode(6,$1,idNode,lParenNode,errorNode,rParenNode,semiColonNode);
		}
		;

func_definition : type_specifier ID LPAREN parameter_list RPAREN {
			auto idNode = new PTN(symbolToRule($2),@2.F_L);
			$2->setNode(idNode);
			insertFunction($1->getType(),$2,true);
		} compound_statement
		{
			initRule("func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement ");
			auto lParenNode = new PTN("LPAREN : (",@3.F_L);
			auto rParenNode = new PTN("RPAREN : )",@5.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(6,$1,$2->getNode(),lParenNode,$4,rParenNode,$7);
			$$->setType($1->getType());
			table->insert($2);
		}
		| type_specifier ID LPAREN RPAREN {
			auto idNode = new PTN(symbolToRule($2),@2.F_L);
			$2->setNode(idNode);
			insertFunction($1->getType(),$2,true);
		} compound_statement
		{
			initRule("func_definition : type_specifier ID LPAREN RPAREN compound_statement ");
			auto lParenNode = new PTN("LPAREN : (",@3.F_L);
			auto rParenNode = new PTN("RPAREN : )",@4.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(5,$1,$2->getNode(),lParenNode,rParenNode,$6);
			$$->setType($1->getType());
			table->insert($2);
		}
		| type_specifier ID LPAREN parameter_list error RPAREN compound_statement
		{
			initError("parameter list of function definition",@$.F_L);
			auto idNode = new PTN(symbolToRule($2),@2.F_L);
			auto lParenNode = new PTN("LPAREN : (",@3.F_L);
			auto errorNode = new PTN("parameter_list : error",$4->getStartOfNode());
			auto rParenNode = new PTN("RPAREN : )",@6.F_L);
			$$ = (new PTN("func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement ",@$.F_L,@$.L_L))
			->addChildrenToNode(6,$1,idNode,lParenNode,errorNode,rParenNode,$7);
		}
		| type_specifier ID LPAREN error RPAREN compound_statement
		{
			initError("parameter list of function definition",@$.F_L);
			auto idNode = new PTN(symbolToRule($2),@2.F_L);
			auto lParenNode = new PTN("LPAREN : (",@3.F_L);
			auto errorNode = new PTN("parameter_list : error",@4.F_L);
			auto rParenNode = new PTN("RPAREN : )",@5.F_L);
			$$ = (new PTN("func_definition : type_specifier ID LPAREN RPAREN compound_statement ",@$.F_L,@$.L_L))
			->addChildrenToNode(6,$1,idNode,lParenNode,errorNode,rParenNode,$6);
		}
		;

parameter_list : parameter_list COMMA type_specifier ID
		{
			initRule("parameter_list : parameter_list COMMA type_specifier ID ");
			auto commaNode = new PTN("COMMA : ,",@2.F_L);
			auto idNode = new PTN(symbolToRule($4),@4.F_L);
			idNode->setType($3->getType());
			$4->setNode(idNode);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(4,$1,commaNode,$3,idNode);
			if(!isParameterRedefined($4) && !parameterRedefined)parameters.push_back($4);
		}
		| parameter_list COMMA type_specifier
		{
			initRule("parameter_list : parameter_list COMMA type_specifier ");
			auto commaNode = new PTN("COMMA : ,",@2.F_L);
			auto id = new SymbolInfo("","ID");
			auto idNode = new PTN(symbolToRule(id),@3.L_L);
			idNode->setType($3->getType());
			id->setNode(idNode);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(4,$1,commaNode,$3,idNode);
			parameters.push_back(id);
		}
		| type_specifier ID
		{
			initRule("parameter_list : type_specifier ID ");
			auto idNode = new PTN(symbolToRule($2),@2.F_L);
			idNode->setType($1->getType());
			$2->setNode(idNode);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(2,$1,idNode);
			parameters.clear();
			parameters.push_back($2);
		}
		| type_specifier
		{
			initRule("parameter_list : type_specifier ");
			auto id = new SymbolInfo("","ID");
			auto idNode = new PTN(symbolToRule(id),@1.L_L);
			idNode->setType($1->getType());
			id->setNode(idNode);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(2,$1,idNode);
			parameters.clear();
			parameters.push_back(id);
		}
		;

compound_statement : LCURL {
		table->enterScope();
		if(currentFunction != nullptr)insertParametersToScope();
		else insertParametersForErrorRecovery();
	} statements RCURL
	{
		initRule("compound_statement : LCURL statements RCURL ");
		auto lCurlNode = new PTN("LCURL : {",@1.F_L);
		auto rCurlNode = new PTN("RCURL : }",@4.F_L);
		$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
		->addChildrenToNode(3,lCurlNode,$3,rCurlNode);
		printSymbolTable();
		table->exitScope();
	}
	| LCURL {
		table->enterScope();
		if(currentFunction != nullptr)insertParametersToScope();
		else insertParametersForErrorRecovery();
	} RCURL
	{
		initRule("compound_statement : LCURL RCURL ");
		auto lCurlNode = new PTN("LCURL : {",@1.F_L);
		auto rCurlNode = new PTN("RCURL : }",@3.F_L);
		$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
		->addChildrenToNode(2,lCurlNode,rCurlNode);
		printSymbolTable();
		table->exitScope();
	}
	;

var_declaration : type_specifier declaration_list SEMICOLON
				{
					initRule("var_declaration : type_specifier declaration_list SEMICOLON ");
					auto semiColonNode = new PTN("SEMICOLON : ;",@3.F_L);
					$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(3,$1,$2,semiColonNode);
					insertVariables($1->getType());
				}
				| type_specifier declaration_list error SEMICOLON
				{
					initError("declaration list of variable declaration",@$.F_L);
					auto errorNode = new PTN("declaration_list : error",$2->getStartOfNode());
					auto semiColonNode = new PTN("SEMICOLON : ;",@4.F_L);
					$$ = (new PTN("var_declaration : type_specifier declaration_list SEMICOLON ",@$.F_L,@$.L_L))
					->addChildrenToNode(3,$1,errorNode,semiColonNode);
					insertVariables($1->getType());
				}
				| type_specifier error SEMICOLON
				{
					initError("declaration list of variable declaration",@$.F_L);
					auto errorNode = new PTN("declaration_list : error",@2.F_L);
					auto semiColonNode = new PTN("SEMICOLON : ;",@3.F_L);
					$$ = (new PTN("var_declaration : type_specifier declaration_list SEMICOLON ",@$.F_L,@$.L_L))
					->addChildrenToNode(3,$1,errorNode,semiColonNode);
				}
				;

type_specifier : INT
		{
			initRule("type_specifier : INT");
			auto intNode = new PTN("INT : int",@1.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(1,intNode);
			$$->setType(Type_Spec::TYPE_INT);
		}
		| FLOAT
		{
			initRule("type_specifier : FLOAT");
			auto floatNode = new PTN("FLOAT : float",@1.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(1,floatNode);
			$$->setType(Type_Spec::TYPE_FLOAT);
		}
		| VOID
		{
			initRule("type_specifier : VOID");
			auto voidNode = new PTN("VOID : void",@1.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(1,voidNode);
			$$->setType(Type_Spec::TYPE_VOID);
		}
		;

declaration_list : declaration_list COMMA ID
				{
					initRule("declaration_list : declaration_list COMMA ID  ");
					auto commaNode = new PTN("COMMA : ,",@2.F_L);
					auto idNode = new PTN(symbolToRule($3),@3.F_L);
					$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(3,$1,commaNode,idNode);
					$3->setNode(idNode);
					ids.push_back($3);
				}
				| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
				{
					initRule("declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE ");
					auto commaNode = new PTN("COMMA : ,",@2.F_L);
					auto idNode = new PTN(symbolToRule($3),@3.F_L);
					idNode->setArraySize(stol($5->getName(), nullptr, 10));
					auto lSquareNode = new PTN("LSQUARE : [",@4.F_L);
					auto constIntNode = new PTN(symbolToRule($5),@5.F_L);
					auto rSquareNode = new PTN("RSQUARE : ]",@6.F_L);
					$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
					->addChildrenToNode(6,$1,commaNode,idNode,lSquareNode,constIntNode,rSquareNode);
					$3->setType("ARRAY");
					$3->setNode(idNode);
					ids.push_back($3);
				}
				| declaration_list COMMA ID LTHIRD RTHIRD ASSIGNOP LCURL argument_list RCURL
				{
					initRule("declaration_list : declaration_list COMMA ID LSQUARE RSQUARE ASSIGNOP LCURL argument_list RCURL ");
					auto idNode = new PTN(symbolToRule($3),@3.F_L);
					idNode->setArraySize($8->getParameters().size());
					$3->setNode(idNode);
					$3->setType("ARRAY");
					auto commaNode = new PTN("COMMA : ,",@2.F_L);
					auto lSquareNode = new PTN("LSQUARE : [",@4.F_L);
					auto rSquareNode = new PTN("RSQUARE : ]",@5.F_L);
					auto assignOpNode = new PTN("ASSIGNOP : =",@6.F_L);
					auto lCurlNode = new PTN("LCURL : {",@7.F_L);
					auto rCurlNode = new PTN("RCURL : }",@9.F_L);
					$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
					->addChildrenToNode(9,$1,commaNode,idNode,lSquareNode,rSquareNode,assignOpNode,lCurlNode,$8,rCurlNode);
					ids.push_back($3);
				}
				| ID
				{
					initRule("declaration_list : ID ");
					auto idNode = new PTN(symbolToRule($1),@1.F_L);
					$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,idNode);
					$1->setNode(idNode);
					ids.clear();
					ids.push_back($1);
				}
				| ID LTHIRD CONST_INT RTHIRD
				{
					initRule("declaration_list : ID LSQUARE CONST_INT RSQUARE ");
					auto idNode = new PTN(symbolToRule($1),@1.F_L);
					idNode->setArraySize(stol($3->getName(), nullptr, 10));
					auto lSquareNode = new PTN("LSQUARE : [",@2.F_L);
					auto constIntNode = new PTN(symbolToRule($3),@3.F_L);
					auto rSquareNode = new PTN("RSQUARE : ]",@4.F_L);
					$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
					->addChildrenToNode(4,idNode,lSquareNode,constIntNode,rSquareNode);
					$1->setType("ARRAY");
					$1->setNode(idNode);
					ids.clear();
					ids.push_back($1);
				}
				| ID LTHIRD RTHIRD ASSIGNOP LCURL argument_list RCURL
				{
					initRule("declaration_list : ID LSQUARE RSQUARE ASSIGNOP LCURL argument_list RCURL ");
					auto idNode = new PTN(symbolToRule($1),@1.F_L);
					idNode->setArraySize($6->getParameters().size());
					$1->setNode(idNode);
					$1->setType("ARRAY");
					auto lSquareNode = new PTN("LSQUARE : [",@2.F_L);
					auto rSquareNode = new PTN("RSQUARE : ]",@3.F_L);
					auto assignOpNode = new PTN("ASSIGNOP : =",@4.F_L);
					auto lCurlNode = new PTN("LCURL : {",@5.F_L);
					auto rCurlNode = new PTN("RCURL : }",@7.F_L);
					$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
					->addChildrenToNode(7,idNode,lSquareNode,rSquareNode,assignOpNode,lCurlNode,$6,rCurlNode);
					ids.clear();
					ids.push_back($1);
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
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(2,$1,$2);
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
		| IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE_AS_IN_BOOK
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
			auto whileNode = new PTN("WHILE : while",@1.F_L);
			auto lParenNode = new PTN("LPAREN : (",@2.F_L);
			auto rParenNode = new PTN("RPAREN : )",@4.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(5,whileNode,lParenNode,$3,rParenNode,$5);			
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
			->addChildrenToNode(5,printlnNode,lParenNode,idNode,rParenNode,semicolonNode);
			if(table->lookUp($3->getName()) == nullptr)undeclaredVariable($3);		
		}
		| RETURN expression SEMICOLON
		{
			initRule("statement : RETURN expression SEMICOLON ");
			auto returnNode = new PTN("RETURN : return",@1.F_L);
			auto semicolonNode = new PTN("SEMICOLON : ;",@3.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(3,returnNode,$2,semicolonNode);	
			returnFlag = true;			
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
					| error SEMICOLON
					{
						initError("expression of expression statement",@$.F_L);
						auto errorNode = new PTN("expression : error",@1.F_L);
						auto semicolonNode = new PTN("SEMICOLON : ;",@2.F_L);
						$$ = (new PTN("expression_statement : expression SEMICOLON ",@$.F_L,@$.L_L))
						->addChildrenToNode(2,errorNode,semicolonNode);
					}
					;

variable : ID
		{
			initRule("variable : ID ");
			auto idNode = new PTN(symbolToRule($1),@1.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,idNode);
			auto prevId = validVariable($1);
			if(!prevId)$$->setType(Type_Spec::NAT);
			else {
				$$->setType(prevId->getNode()->getType());
				$$->setArraySize(prevId->getNode()->getArraySize());
			} 
		}
		| ID LTHIRD expression RTHIRD
		{
			initRule("variable : ID LSQUARE expression RSQUARE ");
			auto idNode = new PTN(symbolToRule($1),@1.F_L);
			auto lSquareNode = new PTN("LSQUARE : [",@2.F_L);
			auto rSquareNode = new PTN("RSQUARE : ]",@4.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(4,idNode,lSquareNode,$3,rSquareNode);
			auto prevId = validArray($1);
			if(!prevId)$$->setType(Type_Spec::NAT);
			else $$->setType(prevId->getNode()->getType());
			if($3->getType() != 01)invalidArraySubscript($3);
		}
		| ID LTHIRD error RTHIRD
		{
			initError("array subscript of variable",@3.F_L);
			auto idNode = new PTN(symbolToRule($1),@1.F_L);
			auto lSquareNode = new PTN("LSQUARE : [",@2.F_L);
			auto errorNode = new PTN("expression : error",@3.F_L);
			auto rSquareNode = new PTN("RSQUARE : ]",@4.F_L);
			$$ = (new PTN("variable : ID LSQUARE expression RSQUARE ",@$.F_L,@$.L_L))
			->addChildrenToNode(4,idNode,lSquareNode,errorNode,rSquareNode);
			auto prevId = validArray($1);
			if(!prevId)$$->setType(Type_Spec::NAT);
			else $$->setType(prevId->getNode()->getType());
		}
		;

expression : logic_expression
		{
			initRule("expression : logic_expression ");
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,$1);
			$$->setType($1->getType());
			$$->setArraySize($1->getArraySize());
		}
		| variable ASSIGNOP logic_expression
		{
			initRule("expression : variable ASSIGNOP logic_expression ");
			auto assignopNode = new PTN("ASSIGNOP : =",@1.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(3,$1,assignopNode,$3);

			if($1->getType() == 23 || $3->getType() == 23){
				string error = "Void cannot be used in expression ";
				unsigned long lineNo;
				if($1->getType() != 23) lineNo = @3.F_L;
				else if($3->getType() != 23) lineNo = @1.F_L;
				else lineNo = @$.F_L;
				semanticError(error,lineNo);
			}
			else if($1->getType() == Type_Spec::TYPE_INT && $3->getType() == Type_Spec::TYPE_FLOAT) {
				string error = "Warning: possible loss of data in assignment of FLOAT to INT";
				semanticError(error,@1.F_L);
			}
			arrayAsOperands($1,$3,new SymbolInfo("=","ASSIGNOP"));
			$$->setType($1->getType());
		}
		;

logic_expression : rel_expression
				{
					initRule("logic_expression : rel_expression ");
					$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,$1);
					$$->setType($1->getType());
					$$->setArraySize($1->getArraySize());
				}
				| rel_expression LOGICOP rel_expression
				{
					initRule("logic_expression : rel_expression LOGICOP rel_expression ");
					auto logicopNode = new PTN(symbolToRule($2),@2.F_L);
					$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(3,$1,logicopNode,$3);	
					if($1->getType() == 23 || $3->getType() == 23){
						$$->setType(Type_Spec::TYPE_VOID);
					}
					else $$->setType(Type_Spec::TYPE_INT);
					if(arrayAsOperands($1,$3,$2))$$->setType(Type_Spec::NAT);
				}
				;

rel_expression : simple_expression
			{
				initRule("rel_expression : simple_expression ");
				$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,$1);
				$$->setType($1->getType());
				$$->setArraySize($1->getArraySize());
			}
			| simple_expression RELOP simple_expression
			{
				initRule("rel_expression : simple_expression RELOP simple_expression ");
				auto relopNode = new PTN(symbolToRule($2),@2.F_L);
				$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(3,$1,relopNode,$3);
				if($1->getType() == 23 || $3->getType() == 23){
					$$->setType(Type_Spec::TYPE_VOID);
				}
				else $$->setType(Type_Spec::TYPE_INT);
				if(arrayAsOperands($1,$3,$2))$$->setType(Type_Spec::NAT);
			}
			;

simple_expression : term
				{
					initRule("simple_expression : term ");
					$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,$1);
					$$->setType($1->getType());
					$$->setArraySize($1->getArraySize());
				}
				| simple_expression ADDOP term
				{
					initRule("simple_expression : simple_expression ADDOP term ");
					auto addopNode = new PTN(symbolToRule($2),@2.F_L);
					$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(3,$1,addopNode,$3);
					$$->setType(typecast($1->getType(),$3->getType()));
					if(arrayAsOperands($1,$3,$2))$$->setType(Type_Spec::NAT);
				}
				;

term : unary_expression
	{
		initRule("term : unary_expression ");
		$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,$1);
		$$->setType($1->getType());
		$$->setArraySize($1->getArraySize());
	}
	| term MULOP unary_expression
	{
		initRule("term : term MULOP unary_expression ");
		auto mulopNode = new PTN(symbolToRule($2),@2.F_L);
		$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(3,$1,mulopNode,$3);
		$$->setType(typecast($1->getType(),$3->getType()));

		if($2->getName() == "%") {
			if(!(($1->getType() == Type_Spec::TYPE_INT) && ($3->getType() == Type_Spec::TYPE_INT))) {
				string error = "Operands of modulus must be integers ";
				semanticError(error,@$.F_L);
				$$->setType(Type_Spec::NAT);
			}
		}
		if($2->getName() == "%" || $2->getName() == "/") {
			if(atof($3->getVal().c_str()) == 0){
				string error = "Warning: division by zero";
				semanticError(error,@3.F_L);
			}
		}
		if(arrayAsOperands($1,$3,$2))$$->setType(Type_Spec::NAT);
	}
	;

unary_expression : ADDOP unary_expression
				{
					initRule("unary_expression : ADDOP unary_expression ");
					auto addopNode = new PTN(symbolToRule($1),@1.F_L);
					$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(2,addopNode,$2);
					$$->setType($2->getType());
					$$->setArraySize($2->getArraySize());
				}
				| NOT unary_expression
				{
					initRule("NOT unary_expression ");
					auto notNode = new PTN("NOT : !",@1.F_L);
					$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(2,notNode,$2);
					$$->setType($2->getType());
					$$->setArraySize($2->getArraySize());
				}
				| factor
				{
					initRule("unary_expression : factor ");
					$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,$1);
					$$->setType($1->getType());
					$$->setVal($1->getVal());
					$$->setArraySize($1->getArraySize());
				}
				;

factor : variable
		{
			initRule("factor : variable ");
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,$1);
			$$->setType($1->getType());
			$$->setArraySize($1->getArraySize());
		}
		| ID LPAREN argument_list RPAREN
		{
			initRule("factor : ID LPAREN argument_list RPAREN ");
			auto idNode = new PTN(symbolToRule($1),@1.F_L);
			auto lParenNode = new PTN("LPAREN : (",@2.F_L);
			auto rParenNode = new PTN("RPAREN : )",@4.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(4,idNode,lParenNode,$3,rParenNode);

			auto id = table->lookUp($1->getName());
			if(id == nullptr){
				string error = "Undeclared function \'"
								+ $1->getName() + "\'";
				semanticError(error,@1.F_L);
				$$->setType(Type_Spec::NAT);
			}
			else {
				auto idNode = id->getNode();
				$$->setType(idNode->getType());

				if(!idNode->isFunctionDeclared()){
					string error = "\'"
								+ $1->getName() 
								+ "\' is not a function";
					semanticError(error,@1.F_L);
				}
				else if(idNode->getNumParameters() < $3->getNumParameters()){
					string error = "Too many arguments to function \'"
								+ $1->getName() 
								+ "\'";
					semanticError(error,@1.F_L);
				}
				else if(idNode->getNumParameters() > $3->getNumParameters()){
					string error = "Too few arguments to function \'"
								+ $1->getName() 
								+ "\'";
					semanticError(error,@1.F_L);
				}
				else argumentTypeMismatch(id,$3);
			}
		}
		| LPAREN expression RPAREN
		{
			initRule("factor : LPAREN expression RPAREN ");
			auto lParenNode = new PTN("LPAREN : (",@1.F_L);
			auto rParenNode = new PTN("RPAREN : )",@3.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))
			->addChildrenToNode(3,lParenNode,$2,rParenNode);
			$$->setType($2->getType());
		}
		| CONST_INT
		{
			initRule("factor : CONST_INT ");
			auto constIntNode = new PTN(symbolToRule($1),@1.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,constIntNode);
			$$->setVal($1->getName());
			$$->setType(Type_Spec::TYPE_INT);
		}
		| CONST_FLOAT
		{
			initRule("factor : CONST_FLOAT ");
			auto constFloatNode = new PTN(symbolToRule($1),@1.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,constFloatNode);
			$$->setVal($1->getName());
			$$->setType(Type_Spec::TYPE_FLOAT);
		}
		| variable INCOP
		{
			initRule("factor : variable INCOP ");
			auto incopNode = new PTN("INCOP : ++",@2.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(2,$1,incopNode);
			if($1->isArray()){
				string error = "Array cannot be used with increment operator";
				semanticError(error,@1.F_L);
				$$->setType(Type_Spec::NAT);
			}
			else $$->setType($1->getType());
		}
		| variable DECOP
		{
			initRule("factor : variable DECOP ");
			auto decopNode = new PTN("DECOP : --",@2.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(2,$1,decopNode);
			if($1->isArray()){
				string error = "Array cannot be used with decrement operator";
				semanticError(error,@1.F_L);
				$$->setType(Type_Spec::NAT);
			}
			else $$->setType($1->getType());
		}
		;

argument_list : arguments
			{
				initRule("argument_list : arguments");
				$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,$1);
				$$->setParameters($1->getParameters());
			}
			| arguments error
			{
				initError("arguments of argument list",@1.F_L);
				auto errorNode = new PTN("arguments : error",$1->getStartOfNode());
				$$ = (new PTN("argument_list : arguments ",@$.F_L,@$.L_L))
				->addChildrenToNode(1,errorNode);
				$$->setParameters($1->getParameters());
			}
			|
			{
				initRule("argument_list : ");
				$$ = new PTN(current_rule,@$.F_L,@$.L_L);
			}
			;

arguments : arguments COMMA logic_expression
		{
			initRule("arguments : arguments COMMA logic_expression");
			auto commaNode = new PTN("COMMA : ,",@2.F_L);
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(3,$1,commaNode,$3);
			$$->setParameters($1->getParameters());
			$$->addParameter($3);
		}
		| logic_expression
		{
			initRule("arguments : logic_expression");
			$$ = (new PTN(current_rule,@$.F_L,@$.L_L))->addChildrenToNode(1,$1);
			$$->addParameter($1);
		}
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
		printf("Invalid file extension. Please provide a .c file.");
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
	fprintf(log_out,"Total errors: %d\n",errorCount);

	fclose(parse_tree_out);
	fclose(error_out);
	fclose(log_out);

	fclose(yyin);

	return 0;
}