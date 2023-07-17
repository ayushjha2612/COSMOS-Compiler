%option noyywrap
D                 [0-9]
L                 [a-zA-Z_]
LD      		      {L}|{D}
SN                [+-]?{D}+[.]{D}+[Ee][+-]?{D}+
ps      		      [ -~]
IDENTIFIER        {L}+{LD}*
ICONST      	   "0"|[0-9]{D}*
CCONST      	   (\'{ps}\')|(\'\\[nftrbv]\')
STRING_LITERAL    \"{ps}*\"

%{
#include <stdio.h>

int lineno = 1;
void prints(char *token_type);
void yyerror(char*);
%}

%x COMMENT

%%
"#/"				      { printf("Ate comment from line %d ", lineno); BEGIN(COMMENT); }
<COMMENT>"/#" 		   { printf("to line %d\n", lineno); BEGIN(INITIAL); }
<COMMENT>[^/\n]+
<COMMENT>"/"			
<COMMENT>"\n"		   { lineno += 1; }

"acc"                { prints("ACC"); }
"arcsec"			      { prints("ARCSEC"); }
"AU"                 { prints("AU"); }
"bool"               { prints("BOOL"); }
"break"              { prints("BREAK"); }
"char"				   { prints("CHAR"); }
"continue"			   { prints("CONTINUE"); }
"density"		   	{ prints("DENSITY"); }
"dist"               { prints("DIST"); }
"else"               { prints("ELSE"); }
"energy"			      { prints("ENERGY"); }
"false"				   { prints("CONSTANT"); }
"force"              { prints("FORCE"); }
"float"              { prints("FLOAT"); }
"freq"               { prints("FREQ"); }
"if"                 { prints("IF"); }
"int"                { prints("INT"); }
"ly"                 { prints("LY"); }
"mass"               { prints("MASS"); }
"parsec"			      { prints("PARSEC"); }
"proc"               { prints("PROC"); }
"repeat"		 	      { prints("REPEAT"); }
"return"			      { prints("RETURN"); }
"short"              { prints("SHORT"); }
"solar_mass"		   { prints("SOLAR_MASS"); }
"speed"              { prints("SPEED"); }
"string"			      { prints("STRING"); }
"struct"			      { prints("STRUCT"); }
"temp"               { prints("TEMP"); }
"time"               { prints("TIME"); }
"true"				   { prints("CONSTANT"); }
"void"               { prints("VOID"); }

{IDENTIFIER}         { prints("IDENTIFIER"); }
{ICONST}     		   { prints("ICONST"); }
{CCONST}     		   { prints("CCONST"); }
{STRING_LITERAL}     { prints("STRING_LITERAL"); }
{SN}		 		      { prints("SN_CONST"); }

"..."				      { prints("ELLIPSIS"); }
"++"                 { prints("INC_OP"); }
"--"                 { prints("DEC_OP"); }

"&&"                 { prints("AND_OP"); }
"||"                 { prints("OR_OP"); }
"<="                 { prints("LE_OP"); }
">="                 { prints("GE_OP"); }
"=="                 { prints("EQ_OP"); }
"!="                 { prints("NE_OP"); }
"^"                  { prints(yytext); }
";"                  { prints(yytext); }
"{"		        	   { prints(yytext); }
"}"		        	   { prints(yytext); }
","                  { prints(yytext); }
":"                  { prints(yytext); }
"="		    		   { prints(yytext); }
"(" 		    	      { prints(yytext); }
")"		    		   { prints(yytext); }
"["		         	{ prints(yytext); }
"]"		        	   { prints(yytext); }
"."		    		   { prints(yytext); }

"-"               	{ prints(yytext); }
"+"               	{ prints(yytext); }
"*"               	{ prints(yytext); }
"/"               	{ prints(yytext); }
"%"               	{ prints(yytext); }
"<"               	{ prints(yytext); }
">"               	{ prints(yytext); }


"\n"		   		{ lineno += 1; }
[ \t\v\f]			{ /* Eat all the whitespace */ }
.               	{ yyerror("Unrecognized character"); }

%%

void prints(char *token_type)
{
   printf("%s \t%s \t%d\n", yytext, token_type, lineno);
}

void yyerror(char *message)
{
   printf("Lexer error: \"%s\" in line %d. Token = %s\n", message, lineno, yytext);
   exit(1);
}


int main()
{
	printf("YYTEXT \tTOKEN \tLINENO.\n");
	yylex();
	return 0;
}