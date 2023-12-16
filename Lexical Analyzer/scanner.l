/* Option section */
%option noyywrap

/* States for strings and comments */
%x SINGLE_LINE_COMMENT
%x MULTI_LINE_COMMENT1
%x MULTI_LINE_COMMENT2

%x SINGLE_LINE_STRING
%x MULTI_LINE_STRING

/* Cpp code section for includes and variables */
%{
#define BUCKET_SIZE 10
#define LOG_FILE "log.txt"
#define TOKEN_FILE "token.txt"

#include<stdio.h>
#include<stdlib.h>
#include<string>
#include <cstdint>
#include"SymbolTable/SymbolTable.h"

SymbolTable table(BUCKET_SIZE);

unsigned long errorCount = 0;
unsigned long warningCount = 0;

unsigned long startString = 0;
unsigned long startComment = 0;

FILE *log_out;
FILE *token_out;

string stringLiteral = "";
string buffer = "";

void writeToToken(string token){
    fprintf(token_out,"<%s, %s>\n",token.c_str(),yytext);
}

void writeToLog(string token){
    fprintf(log_out,"Line# %d: Token <%s> Lexeme %s found\n",yylineno,token.c_str(),yytext);
}

void writeToFile(string token){
	writeToToken(token);
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
        /* case '?':
            return '\?'; */
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
	fprintf(token_out,"<CONST_CHAR, %s>\n",lexeme);
	fprintf(log_out,"Line# %d: Token <CONST_CHAR> Lexeme %s found\n",yylineno,lexeme);
}

void writeErrorToLog(string error){
    errorCount++;
    fprintf(log_out,"Error at line# %d: %s %s\n",yylineno,error.c_str(),yytext); 
}

void checkIndentation(string indent){
    string id = table.getCurrentScopeId();

    unsigned long expectedTab = 0;

    for(int i = 0; i < id.length(); i++){
        if(id[i] == '.')expectedTab++;
    }

    if(expectedTab > 0){
        unsigned long space = 0;
        unsigned long tab = 0;
        for(int i = 0; i < indent.length(); i++){
            if(indent[i] == ' ')space++;
            else if(indent[i] == '\t')tab++;
        }

        if(space > 0){
            warningCount++;
            fprintf(log_out, "Line# %d: Warning, tab required but got space.\n",yylineno);
        }
        else if(tab != expectedTab){
            warningCount++;
            fprintf(log_out, "Line# %d: Warning, %d of tabs needed but got %d tabs.\n",yylineno,expectedTab,tab);
        }
    }
}

%}

/* regex section */

DIGIT [0-9]
DIGITS ({DIGIT}+)
INT {DIGITS}

EXP ([Ee][+-]?{DIGITS})
FLOAT {DIGITS}\.{DIGITS}?{EXP}?|\.{DIGITS}{EXP}?|{DIGITS}{EXP}


LETTER [_a-zA-Z]
ID {LETTER}({LETTER}|{DIGIT})*
PRINTABLE '[\x20-\x26\x28-\x5b\x5d-\x7e]'
BACKSLASH '\\[\\'"abfnrtv0]'
CHAR {PRINTABLE}|{BACKSLASH}

ADDOP [+-]
MULOP [*/%]
INCOP [+][+]|[-][-]
ASSIGNOP [=]
RELOP [<>]{ASSIGNOP}?|[!=]{ASSIGNOP}

NEWLINE [\n]

INVALID_ID_SUFFIX_NUM_PREFIX ({INT}{ID})
TOO_MANY_DECIMAL_POINTS ({DIGIT}*[\.]{DIGIT}*[\.])([\.0-9]*)({EXP}?)
ILLFORMED_EXP [Ee][+-]?([0-9]*)[\.]([0-9]*)
ILLFORMED_NUMBER {DIGITS}\.{DIGITS}?{ILLFORMED_EXP}|\.{DIGITS}{ILLFORMED_EXP}|{DIGITS}{ILLFORMED_EXP}

UNRECOGNIZED_CHAR [#$.:?@\\`~]|'[\x27]'|'[\x5c][\x20\x21\x23-\x26\x28-\x2f\x31-\x5b\x5d-\x60\x63-\x65\x67-\x6d\x6f-\x71\x73\x75\x77-\x7e]'
EMPTY_CONST_CHAR ''
UNFINISHED_CONST_CHAR '[\x5c]'|'([\x20-\x26\x28-\x7e]?)
MULTICHAR_CONST_CHAR '([\x5c][\x20-\x26\x28-\x7e]|[\x20-\x26\x28-\x5b\x5d-\x7e])([\x20-\x26\x28-\x7e]+)'

%%

if      { writeToFile("IF"); }
else    { writeToFile("ELSE"); }
for     { writeToFile("FOR"); }
do      { writeToFile("DO"); }
int     { writeToFile("INT"); }
float   { writeToFile("FLOAT"); }
void    { writeToFile("VOID"); }
switch  { writeToFile("SWITCH"); }
default { writeToFile("DEFAULT"); }
while   { writeToFile("WHILE"); }
break   { writeToFile("BREAK"); }
char    { writeToFile("CHAR"); }
double  { writeToFile("DOUBLE"); }
return  { writeToFile("RETURN"); }
case    { writeToFile("CASE"); }
continue { writeToFile("CONTINUE"); }

{ADDOP} { writeToFile("ADDOP"); }
{MULOP} { writeToFile("MULOP"); }
{INCOP} { writeToFile("INCOP"); }
{RELOP} { writeToFile("RELOP"); }
{ASSIGNOP} { writeToFile("ASSIGNOP"); }
"&&"|"||" { writeToFile("LOGICOP"); }
"&"|"|"|"^"|"<<"|">>" { writeToFile("BITOP"); }
"!" { writeToFile("NOT"); }
"(" { writeToFile("LPAREN"); }
")" { writeToFile("RPAREN"); }
"{" { 
    writeToFile("LCURL"); 
    table.enterScope();
}
"}" { 
    writeToFile("RCURL"); 
    table.exitScope();
}
"[" { writeToFile("LSQUARE"); }
"]" { writeToFile("RSQUARE"); }
"," { writeToFile("COMMA"); }
";" { writeToFile("SEMICOLON"); }

{INT} { writeToFile("CONST_INT"); }

{FLOAT} { writeToFile("CONST_FLOAT"); }

{CHAR} { writeToFileChar(); }

{ID}  {
    writeToFile("ID"); 
    bool isInserted = table.insert(new SymbolInfo(yytext,"ID"));
    if(isInserted){
        fprintf(log_out,"%s",table.printAllScopes().c_str());
    }else{
        string tab = TAB;
        fprintf(log_out,"%s%s already exists in the current ScopeTable\n",tab.c_str(),yytext);
    }
}

{NEWLINE}([ \t]*[\xd]) {
    yylineno++;
}

{NEWLINE}([ \t]*)([\x7d]) {
    yylineno++;
    fprintf(token_out,"<RCURL, }>\n");
    fprintf(log_out,"Line# %d: Token <RCURL> Lexeme } found\n",yylineno);
    table.exitScope();
    checkIndentation(yytext);
}

{NEWLINE}([ \t]*) {
    yylineno++;
    checkIndentation(yytext);
}

{INVALID_ID_SUFFIX_NUM_PREFIX} { writeErrorToLog("INVALID_ID_SUFFIX_NUM_PREFIX"); }
{TOO_MANY_DECIMAL_POINTS} { writeErrorToLog("TOO_MANY_DECIMAL_POINTS"); }
{ILLFORMED_NUMBER} { writeErrorToLog("ILLFORMED_NUMBER"); }

{UNRECOGNIZED_CHAR} { writeErrorToLog("UNRECOGNIZED_CHAR"); }
{EMPTY_CONST_CHAR} { writeErrorToLog("EMPTY_CONST_CHAR"); }
{UNFINISHED_CONST_CHAR} { writeErrorToLog("UNFINISHED_CONST_CHAR"); }
{MULTICHAR_CONST_CHAR} { writeErrorToLog("MULTICHAR_CONST_CHAR"); }

[\x2f][\x2f] {
    startComment = yylineno;
    buffer = yytext;
    BEGIN SINGLE_LINE_COMMENT;
}

<SINGLE_LINE_COMMENT>[^\xd\x5c] {
    buffer += yytext;
}

<SINGLE_LINE_COMMENT>([\\][\xd][\n]) {
    buffer += yytext;
    yylineno++;
}

<SINGLE_LINE_COMMENT><<EOF>> |
<SINGLE_LINE_COMMENT>[\xd] {
    fprintf(log_out,"Line# %d: Token <SINGLE LINE COMMENT> Lexeme %s found\n",startComment,buffer.c_str());
    buffer = "";
    startComment = 0;
    BEGIN INITIAL;
}

<SINGLE_LINE_COMMENT>([\\][^\xd]) {
    buffer += yytext;
}

[\x2f][\x2a] {
    startComment = yylineno;
    BEGIN MULTI_LINE_COMMENT1;
    buffer = yytext;
}

<MULTI_LINE_COMMENT1>([^\x2a\n]+) {
    buffer += yytext;
}

<MULTI_LINE_COMMENT1>[\n] {
    buffer += yytext;
    yylineno++;
}

<MULTI_LINE_COMMENT2>[\n] {
    buffer += yytext;
    yylineno++;
    BEGIN MULTI_LINE_COMMENT1;
}

<MULTI_LINE_COMMENT1>[\x2a] {
    buffer += yytext;
    BEGIN MULTI_LINE_COMMENT2;
}

<MULTI_LINE_COMMENT2>[^\x2a\x2f\n] {
    buffer += yytext;
    BEGIN MULTI_LINE_COMMENT1;
}

<MULTI_LINE_COMMENT2>[\x2a] {
    buffer += yytext;
}

<MULTI_LINE_COMMENT2>[\x2f] {
    fprintf(log_out,"Line# %d: Token <MULTI LINE COMMENT> Lexeme %s%s found\n",startComment,buffer.c_str(),yytext);
    buffer = "";
    BEGIN INITIAL;
}

<MULTI_LINE_COMMENT1><<EOF>> |
<MULTI_LINE_COMMENT2><<EOF>> {
    errorCount++;
    fprintf(log_out,"Error at line# %d: UNFINISHED_COMMENT %s\n",yylineno,buffer.c_str());
    buffer = "";
    BEGIN INITIAL;
}

[\x22] {
    startString = yylineno;
    BEGIN SINGLE_LINE_STRING;
    buffer = yytext;
    stringLiteral = "";
}

<MULTI_LINE_STRING>[^\x5c\n\x22] |
<SINGLE_LINE_STRING>[^\x5c\n\x22] {
    buffer += yytext;
    stringLiteral += yytext;
}

<MULTI_LINE_STRING>([\\][\\'"abfnrtv0]) |
<SINGLE_LINE_STRING>([\\][\\'"abfnrtv0]) {
    buffer += yytext;
    stringLiteral += replaceConstCharInString(yytext); 
}

<MULTI_LINE_STRING>([\\][^\\'"abfnrtv0\xd]) |
<SINGLE_LINE_STRING>([\\][^\\'"abfnrtv0\xd]) {
    buffer += yytext;
    fprintf(log_out,"Error at line# %d: UNFINISHED_STRING %s\n",yylineno,buffer.c_str());
    buffer = "";
    stringLiteral = "";
    startString = 0;
    BEGIN INITIAL;
}

<MULTI_LINE_STRING><<EOF>> |
<SINGLE_LINE_STRING><<EOF>> {
    fprintf(log_out,"Error at line# %d: UNFINISHED_STRING %s\n",yylineno,buffer.c_str());
    buffer = "";
    stringLiteral = "";
    startString = 0;
    BEGIN INITIAL;
}

<MULTI_LINE_STRING>[\n] |
<SINGLE_LINE_STRING>[\n] {
    fprintf(log_out,"Error at line# %d: UNFINISHED_STRING %s\n",yylineno,buffer.c_str());
    buffer = "";
    stringLiteral = "";
    startString = 0;
    yylineno++;
    BEGIN INITIAL;
}

<SINGLE_LINE_STRING>[\x22] {
    fprintf(log_out,"Line# %d: Token <SINGLE LINE STRING> Lexeme %s%s found\n",startString,buffer.c_str(),yytext);
    fprintf(token_out,"<SINGLE LINE STRING, %s>\n",stringLiteral.c_str());
    buffer = "";
    stringLiteral = "";
    startString = 0;
    BEGIN INITIAL;
}

<MULTI_LINE_STRING>([\\][\xd][\n]) |
<SINGLE_LINE_STRING>([\\][\xd][\n]) {
    BEGIN MULTI_LINE_STRING;
    buffer += yytext;
    yylineno++;
    // stringLiteral += yytext;
}

<MULTI_LINE_STRING>[\x22] {
    fprintf(log_out,"Line# %d: Token <MULTI LINE STRING> Lexeme %s%s found\n",startString,buffer.c_str(),yytext);
    fprintf(token_out,"<MULTI LINE STRING, %s>\n",stringLiteral.c_str());
    buffer = "";
    stringLiteral = "";
    startString = 0;
    BEGIN INITIAL;
}

%%

/* Main Driver */ 
int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide lexeme file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	log_out = fopen(LOG_FILE,"w");
	token_out = fopen(TOKEN_FILE,"w");

    yylineno = 1;

	yyin= fin;
	yylex();

    fprintf(log_out,"%s",table.printAllScopes().c_str());

    fprintf(log_out,"Total lines: %d\n",yylineno);
    fprintf(log_out,"Total errors: %d\n",errorCount);
    fprintf(log_out,"Total warnings: %d\n",warningCount);

	fclose(yyin);
	fclose(token_out);
	fclose(log_out);
	return 0;
}