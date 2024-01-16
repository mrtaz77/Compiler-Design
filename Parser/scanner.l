/* Option section */
%option noyywrap

/*automatic init of yylineno and increment on finding newline*/
%option yylineno

/* States for strings and comments */
%x SINGLE_LINE_COMMENT
%x MULTI_LINE_COMMENT

%x SINGLE_LINE_STRING
%x MULTI_LINE_STRING

/* Cpp code section for includes and variables */
%{

#include<stdio.h>
#include<stdlib.h>
#include<string>

// user header file
#include "SymbolTable/SymbolTable.h"
#include "ParseTree/ParseTreeNode.h"

// bison generated header file
#include "parser.tab.h"

extern YYSTYPE yylval;
extern SymbolTable *table;

unsigned long lexicalErrorCount = 0;
unsigned long lexicalWarningCount = 0;

unsigned long startString = 0;
unsigned long startComment = 0;

extern FILE *log_out;
// FILE *token_out;

string stringLiteral = "";
string buffer = "";

void yyerror(char *);

void writeToToken(string token){
	// fprintf(token_out,"<%s, %s>\n",token.c_str(),yytext);
}

void writeToLog(string token){
	fprintf(log_out,"Line# %d: Token <%s> Lexeme %s found\n",yylineno,token.c_str(),yytext);
}

void writeToFile(string token){
	// writeToToken(token);
	writeToLog(token);
}

char getBackSlashCharConstant(char constant){
	switch (constant) {
		case 'a':
			return '\a';
		case 'b':
			return '\b';
		case 'f':
			return '\f';
		case 'n':
			return '\n';
		case 'r':
			return '\r';
		case 't':
			return '\t';
		case 'v':
			return '\v';
		case '0':
			return '\0';
		case '?':
			return '\?';
		case '\\':
			return '\\';
		case '\'':
			return '\'';
		case '\"':
			return '\"';
		default:
			return 'U';
	}
}

char replaceConstCharInString(string constant){
	char backslashConstant = constant[1];
	return getBackSlashCharConstant(backslashConstant);
}

char getTokenFromConstChar(string lexeme) {
	if(lexeme.length() == 3) return lexeme[1];
	if (lexeme.length() == 4 && lexeme[0] == '\'' && lexeme[1] == '\\' && lexeme[lexeme.length() - 1] == '\'') {
		char backslashConstant = lexeme[2];
		return getBackSlashCharConstant(backslashConstant);
	}
	return lexeme[1];
}

void writeToFileChar(){
	char lexeme = getTokenFromConstChar(yytext);
	fprintf(log_out,"Line# %d: Token <CONST_CHAR> Lexeme %c found\n",yylineno,lexeme);
}

void writeErrorToLog(string error){
	lexicalErrorCount++;
	fprintf(log_out,"Error at line# %d: %s %s\n",yylineno,error.c_str(),yytext); 
}

void checkIndentation(string indent){
	string id = table->getCurrentScopeId();

	unsigned long expectedTab = 0;

	for(int i = 0; i < id.length(); i++){
		if(id[i] == '.')expectedTab++;
	}

	unsigned long space = 0;
	unsigned long tab = 0;
	for(int i = 0; i < indent.length(); i++){
		if(indent[i] == ' ')space++;
		else if(indent[i] == '\t')tab++;
	}


	if(space > 0){
		lexicalWarningCount++;
		fprintf(log_out, "Line# %d: Warning, tab requrired but got space.\n",yylineno);
	}
	else if(tab != expectedTab){
		lexicalWarningCount++;
		fprintf(log_out, "Line# %d: warning, %d of tabs needed but got %d tabs.\n",yylineno,expectedTab,tab);
	}
}

// code added for syntax analysis

/* Following functions adjust the yylloc 
first and last line fields for parser usage.
The column values remain unchanged */

/* Since column positions are not needed
for this parser, lines changing 
them have been commented out */

/* macro YY_USER_ACTION can be defined to 
provide an action which is always executed
prior to the matched rule's action */

// #define YY_USER_ACTION yyloc->last_column += yyleng ;

/* Here , whenever a rule is matched, YY_USER_ACTION moves the scanner
pointer to the end of yytext */

void resetCursorPosition() {
	yylloc.first_line = yylloc.last_line;
	// yylloc->first_column = yylloc->last_column; 
}

void adjustYYLLOC() {
	// yylloc->last_column = 1;
	yylloc.last_line = yylineno;
	resetCursorPosition();
}

void assignSymbolInfoToYYLVAL(string type) { 
	yylval.symbolInfo = new SymbolInfo(yytext,type);
}


%}

/* regex section */

DIGIT [0-9]
DIGITS ({DIGIT}+)
INT {DIGITS}

LINE_FEED [\xa]
CARRIAGE_RETURN [\xd]
NEWLINE {CARRIAGE_RETURN}?{LINE_FEED}
BACKSLASH [\\]
ASTERISK [*]
SLASH [/]
DOUBLE_QUOTE [\x22]
SINGLE_QUOTE [\x27]
WS ([ \t]*)

EXP ([Ee][+-]?{DIGITS})
FLOAT (({DIGITS}\.{DIGITS}?)|(\.{DIGITS})){EXP}?|{DIGITS}{EXP}

LETTER [_a-zA-Z]
ID {LETTER}({LETTER}|{DIGIT})*
PRINTABLE [\x20-\x26\x28-\x5b\x5d-\x7e]
BACKSLASH_CONST \\[\\'"abfnrtv0]
CHAR {SINGLE_QUOTE}({PRINTABLE}|{BACKSLASH_CONST}){SINGLE_QUOTE}

INVALID_ID_SUFFIX_NUM_PREFIX ({INT}|{FLOAT}){ID}
TOO_MANY_DECIMAL_POINTS ({DIGIT}*[\.]{DIGIT}*[\.])([\.0-9]*)({EXP}?)
ILLFORMED_EXP [Ee][+-]?([0-9]*)[\.]([0-9]*)
ILLFORMED_NUMBER ({DIGITS}\.{DIGITS}?|\.{DIGITS}|{DIGITS}){ILLFORMED_EXP}

UNRECOGNIZED_CHAR [#$\.:?@`~\\]|'[\x27]'|'{BACKSLASH}[^\\'"abfnrtv0]'
EMPTY_CONST_CHAR ''
MULTICHAR_CONST_CHAR '({PRINTABLE}|({BACKSLASH}[\x20-\x7e]))({PRINTABLE}|({BACKSLASH}[\x20-\x7e]))+'
UNFINISHED_CONST_CHAR '({PRINTABLE}?)|'({BACKSLASH}[\x20-\x7e]?)

%%

"if" { writeToFile("IF"); return IF; }
"else" { writeToFile("ELSE"); return ELSE; }
"for" { writeToFile("FOR"); return FOR; }

"int" { writeToFile("INT"); return INT; }
"float" { writeToFile("FLOAT"); return FLOAT; }
"void" { writeToFile("VOID"); return VOID; }






"return" { writeToFile("RETURN"); return RETURN; }



"println" { writeToFile("PRINTLN"); return PRINTLN; }

%{
// Commented out rules
// "do" { writeToFile("DO"); return DO; }
// "switch" { writeToFile("SWITCH"); return SWITCH; }
// "default" { writeToFile("DEFAULT"); return DEFAULT; }
// "while" { writeToFile("WHILE"); return WHILE; }
// "break" { writeToFile("BREAK"); return BREAK; }
// "char" { writeToFile("CHAR"); return CHAR; }
// "double" { writeToFile("DOUBLE"); return DOUBLE; }
// "case" { writeToFile("CASE"); return CASE; }
// "continue" { writeToFile("CONTINUE"); return CONTINUE; }
// "main" { writeToFile("MAIN"); return MAIN; }
%}	


"+"|"-" { 
	writeToFile("ADDOP");
	assignSymbolInfoToYYLVAL("ADDOP");
	return ADDOP; 
}
"*"|"/"|"%" { 
	writeToFile("MULOP");
	assignSymbolInfoToYYLVAL("MULOP");
	return MULOP; 
}
"++" { writeToFile("INCOP"); return INCOP; }
"--" { writeToFile("DECOP"); return DECOP; }
">"|">="|"<"|"<="|"=="|"!=" { 
	writeToFile("RELOP");
	assignSymbolInfoToYYLVAL("RELOP");
	return RELOP; 
}
"=" { writeToFile("ASSIGNOP"); return ASSIGNOP; }
"&&"|"||" { 
	writeToFile("LOGICOP");
	assignSymbolInfoToYYLVAL("LOGICOP");
	return LOGICOP; 
}
%{
// "&"|"|"|"^"|"<<"|">>" { 
// 	writeToFile("BITOP");
// 	assignSymbolInfoToYYLVAL("BITOP");
// 	return BITOP; 
// }
%}
"!" { writeToFile("NOT"); return NOT; }
"(" { writeToFile("LPAREN"); return LPAREN; }
")" { writeToFile("RPAREN"); return RPAREN; }
"{" { writeToFile("LCURL"); return LCURL; }
"}" { writeToFile("RCURL"); return RCURL; }
"[" { writeToFile("LSQUARE"); return LTHIRD; }
"]" { writeToFile("RSQUARE"); return RTHIRD; }
"," { writeToFile("COMMA"); return COMMA; }
";" { writeToFile("SEMICOLON"); return SEMICOLON; }

{INT} { 
	writeToFile("CONST_INT");
	assignSymbolInfoToYYLVAL("CONST_INT");
	return CONST_INT; 
}

{FLOAT} { 
	writeToFile("CONST_FLOAT");
	assignSymbolInfoToYYLVAL("CONST_FLOAT");
	return CONST_FLOAT; 
}

{CHAR} { writeToFileChar(); }

{ID}  {
	writeToFile("ID");
	auto symbol = table->lookUp(yytext);
	if(symbol == nullptr)assignSymbolInfoToYYLVAL("ID");
	else yylval.symbolInfo = symbol;
	return ID; 
}

{NEWLINE}{WS}{CARRIAGE_RETURN}?$ {
    adjustYYLLOC();
}

{NEWLINE}{WS}"}" {
	adjustYYLLOC();
	// table.exitScope();
	// checkIndentation(yytext);
	fprintf(log_out,"Line# %d: Token <RCURL> Lexeme } found\n",yylineno);
	return RCURL;
}

{NEWLINE}{WS}{SLASH}{ASTERISK} |
{NEWLINE}{WS}{SLASH}{2} {
	adjustYYLLOC();
	yyless(yyleng-2);
}

{NEWLINE}{WS} {
	adjustYYLLOC();
	// checkIndentation(yytext);
}

^{WS}{SLASH}{ASTERISK} |
^{WS}{SLASH}{2} {
	yyless(yyleng-2);
}

^{WS} {
	resetCursorPosition();
	// checkIndentation(yytext);
}

{WS} {}

{INVALID_ID_SUFFIX_NUM_PREFIX} { writeErrorToLog("INVALID_ID_SUFFIX_NUM_PREFIX"); }
{TOO_MANY_DECIMAL_POINTS} { writeErrorToLog("TOO_MANY_DECIMAL_POINTS"); }
{ILLFORMED_NUMBER} { writeErrorToLog("ILLFORMED_NUMBER"); }

{UNRECOGNIZED_CHAR} { writeErrorToLog("UNRECOGNIZED_CHAR"); }
{EMPTY_CONST_CHAR} { writeErrorToLog("EMPTY_CONST_CHAR"); }
{UNFINISHED_CONST_CHAR} { writeErrorToLog("UNFINISHED_CONST_CHAR"); }
{MULTICHAR_CONST_CHAR} { writeErrorToLog("MULTICHAR_CONST_CHAR"); }

{SLASH}{2} {
	startComment = yylineno;
	buffer = yytext;
	BEGIN SINGLE_LINE_COMMENT;
}

<SINGLE_LINE_COMMENT>({BACKSLASH}[^\xd\xa]) |
<SINGLE_LINE_COMMENT>[^\xd\xa\x5c] {
	buffer += yytext;
}

<SINGLE_LINE_COMMENT>({BACKSLASH}{NEWLINE}) {
	buffer += yytext;
	adjustYYLLOC();
}

<SINGLE_LINE_COMMENT><<EOF>> {
	buffer = "";
	startComment = 0;
	BEGIN INITIAL;
}

<SINGLE_LINE_COMMENT>{NEWLINE} {
	// fprintf(log_out,"Line# %d: Token <SINGLE LINE COMMENT> Lexeme %s found\n",startComment,buffer.c_str());
	buffer = "";
	startComment = 0;
	yyless(0);
	BEGIN INITIAL;
}

{SLASH}{ASTERISK} {
	startComment = yylineno;
	BEGIN MULTI_LINE_COMMENT;
	buffer = yytext;
}

<MULTI_LINE_COMMENT>([^\xa\xd]) {
	buffer += yytext;
}

<MULTI_LINE_COMMENT>{NEWLINE} {
	buffer += yytext;
	adjustYYLLOC();
}

<MULTI_LINE_COMMENT>{ASTERISK}{SLASH} {
	// fprintf(log_out,"Line# %d: Token <MULTI LINE COMMENT> Lexeme %s%s found\n",startComment,buffer.c_str(),yytext);
	buffer = "";
	startComment = 0;
	BEGIN INITIAL;
}

<MULTI_LINE_COMMENT><<EOF>> {
	lexicalErrorCount++;
	// fprintf(log_out,"Error at line# %d: UNFINISHED_COMMENT %s\n",yylineno,buffer.c_str());
	buffer = "";
	startComment = 0;
	BEGIN INITIAL;
}

{DOUBLE_QUOTE} {
	startString = yylineno;
	BEGIN SINGLE_LINE_STRING;
	buffer = yytext;
	stringLiteral = "";
}

<MULTI_LINE_STRING>[^\x5c\xa\xd\x22] |
<SINGLE_LINE_STRING>[^\x5c\xa\xd\x22] {
	buffer += yytext;
	stringLiteral += yytext;
}

<MULTI_LINE_STRING>{BACKSLASH}([\\'"abfnrtv0]) |
<SINGLE_LINE_STRING>{BACKSLASH}([\\'"abfnrtv0]) {
	buffer += yytext;
	stringLiteral += replaceConstCharInString(yytext); 
}

<MULTI_LINE_STRING>{BACKSLASH}([^\\'"abfnrtv0\xd\xa]) |
<SINGLE_LINE_STRING>{BACKSLASH}([^\\'"abfnrtv0\xd\xa]) {
	lexicalWarningCount++;
	// fprintf(log_out, "Line# %d: Warning, unknown escape sequence \'%s\' in string\n",yylineno,yytext);
	buffer += yytext;
	stringLiteral += yytext[yyleng - 1];
}

<MULTI_LINE_STRING><<EOF>> |
<SINGLE_LINE_STRING><<EOF>> {
	lexicalErrorCount++;
	fprintf(log_out,"Error at line# %d: UNFINISHED_STRING %s\n",yylineno,buffer.c_str());
	buffer = "";
	stringLiteral = "";
	startString = 0;
	BEGIN INITIAL;
}

<MULTI_LINE_STRING>{NEWLINE} |
<SINGLE_LINE_STRING>{NEWLINE} {
	yyless(0);
	lexicalErrorCount++;
	// fprintf(log_out,"Error at line# %d: UNFINISHED_STRING %s\n",yylineno,buffer.c_str());
	buffer = "";
	stringLiteral = "";
	startString = 0;
	BEGIN INITIAL;
}

<SINGLE_LINE_STRING>{DOUBLE_QUOTE} {
	// fprintf(log_out,"Line# %d: Token <SINGLE LINE STRING> Lexeme %s%s found\n",startString,buffer.c_str(),yytext);
	buffer = "";
	stringLiteral = "";
	startString = 0;
	BEGIN INITIAL;
}

<MULTI_LINE_STRING>{BACKSLASH}{NEWLINE} |
<SINGLE_LINE_STRING>{BACKSLASH}{NEWLINE} {
	BEGIN MULTI_LINE_STRING;
	buffer += yytext;
	adjustYYLLOC();
}

<MULTI_LINE_STRING>{DOUBLE_QUOTE} {
	// fprintf(log_out,"Line# %d: Token <MULTI LINE STRING> Lexeme %s%s found\n",startString,buffer.c_str(),yytext);
	buffer = "";
	stringLiteral = "";
	startString = 0;
	BEGIN INITIAL;
}

%%