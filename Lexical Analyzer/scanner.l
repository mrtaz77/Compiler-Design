/* Option section */
%option noyywrap

/* Cpp code section for includes and variables */
%{
#define BUCKET_SIZE 10

#include<stdio.h>
#include<stdlib.h>
#include<string>
#include <cstdint>
#include"SymbolTable/SymbolTable.h"

SymbolTable table(BUCKET_SIZE);

FILE *log_out;
FILE *token_out;

// files
void writeToFile(string token){
	fprintf(token_out,"<%s, %s>\n",token.c_str(),yytext);
	fprintf(log_out,"Line no %d: TOKEN %s Lexeme %s found\n",yylineno,token.c_str(),yytext);
}

string extractCharacter(string lexeme) {
    if(lexeme.length() == 3) return lexeme.substr(1, lexeme.length() - 2);
    if (lexeme.length() == 4 && lexeme[0] == '\'' && lexeme[1] == '\\' && lexeme[lexeme.length() - 1] == '\'') {
        char backslashConstant = lexeme[2];
        switch (backslashConstant) {
            case 'a':
                return "\a";
            case 'b':
                return "\b";
            case 'f':
                return "\f";
            case 'n':
                return "\n";
            case 'r':
                return "\r";
            case 't':
                return "\t";
            case 'v':
                return "\v";
            case '0':
                return "\0";
            case '?':
                return "\?";
			case '\\':
                return "\\";
			case '\'':
                return "\'";
			case '\"':
                return "\"";
            default:
                return "Unknown";
        }
    }

    return lexeme.substr(1, lexeme.length() - 2);
}

void writeToFileChar(){
	string lexeme = extractCharacter(yytext);
	fprintf(token_out,"<CONST_CHAR, %s>\n",lexeme.c_str());
	fprintf(log_out,"Line no %d: TOKEN CONST_CHAR Lexeme %s found\n",yylineno,lexeme.c_str());
}

%}

/* regex section */

DIGIT [0-9]
INT {DIGIT}+
LETTER [a-zA-Z_]
EXP [Ee][+-]?{INT}
FLOAT1 {INT}.{INT}?{EXP}? 
FLOAT2 {INT}{EXP}
FLOAT3 .{INT}{EXP}? 
ID {LETTER}({LETTER}|{DIGIT})*
PRINTABLE '[ -~]'
BACKSLASH '\\[\\'"abfnrtv0?]'

ADDOP [+-]
MULOP [*/%]
INCOP [+][+]|[-][-]
ASSIGNOP [=]
GREATER_LESSER_EQUAL [<>]{ASSIGNOP}?
EQUAL_NOT_EQUAL [!=]{ASSIGNOP}

NEWLINE [\n]

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
{EQUAL_NOT_EQUAL} |
{GREATER_LESSER_EQUAL} { writeToFile("RELOP"); }
{ASSIGNOP} { writeToFile("ASSIGNOP"); }
"&&" |
"||" { writeToFile("LOGICOP"); }
"&" |
"|" |
"^" |
"<<" |
">>" { writeToFile("BITOP"); }
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
";" { 
    writeToFile("SEMICOLON");
}


{INT} { writeToFile("INT"); }

{FLOAT1} |
{FLOAT2} |
{FLOAT3} { writeToFile("CONST_FLOAT"); }

{PRINTABLE} |
{BACKSLASH} {
    writeToFileChar();
}

{ID}  {
    writeToFile("ID"); 
    bool isInserted = table.insert(new SymbolInfo(yytext,"ID"));
    if(isInserted){
        fprintf(log_out,"%s",table.printAllScopes().c_str());
    }else{
        string tab = TAB;
        fprintf(log_out,"%s%s already exists in the current ScopeTable",tab.c_str(),yytext);
    }
}

{NEWLINE} {
    yylineno++;
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
	
	log_out = fopen("log.txt","w");
	token_out = fopen("token.txt","w");

    yylineno = 1;

	yyin= fin;
	yylex();

	fclose(yyin);
	fclose(token_out);
	fclose(log_out);
	return 0;
}