%option noyywrap
D                 [0-9]
L                 [a-zA-Z_]
LD      		      {L}|{D}
SN                [+-]?{D}+[.]{D}+[Ee][+-]?{D}+
ps      		      [ -~]
IDENTIFIER        {L}+{LD}*
INTCONST      	   "0"|[0-9]{D}*
CHARCONST      	   (\'{ps}\')|(\'\\[nftrbv]\')
STRING_LITERAL    \"{ps}*\"

%{
#include <stdio.h>
#include "y.tab.h"

int lineno = 1;
void prints(char *token_type);
void lexError(char*);
void comment(void);
%}
%option yylineno
%x COMMENT

%%
"#"               {comment(); }
"/*"				   { BEGIN(COMMENT); }
<COMMENT>"*/" 		{ BEGIN(INITIAL); }
<COMMENT>[^/\n]+
<COMMENT>"*"			
<COMMENT>"\n"		{ lineno += 1; }

"acc"             { return(ACC); }
"arcsec"			   { return(ARCSEC); }
"AU"              { return(AU); }
"bool"            { return(BOOL);}
"break"           { return(BREAK); }
"char"				{ return(CHAR); }
"continue"			{ return(CONTINUE); }
"density"			{ return(DENSITY); }
"dist"            { return(DIST); }
"else"            { return(ELSE); }
"energy"			   { return(ENERGY); }
"false"				{ return(BOOLCONST); }
"force"           { return(FORCE); }
"float"           { return(FLOAT); }
"freq"            { return(FREQ); }
"if"              { return(IF); }
"int"             { return(INT); }
"ly"              { return(LY); }
"mass"            { return(MASS); }
"parsec"			   { return(PARSEC); }
"proc"            { return(PROC); }
"repeat"		 	   { return(REPEAT); }
"return"			   { return(RETURN); }
"solar_mass"		{ return(SOLAR_MASS); }
"speed"           { return(SPEED); }
"string"			   { return(STRING); }
"struct"			   { return(STRUCT); }
"temp"            { return(TEMP); }
"time"            { return(TIME); }
"true"				{ return(BOOLCONST); }
"void"            { return(VOID); }

{IDENTIFIER}      { return(IDENTIFIER); }
{INTCONST}     		{ return(INTCONST); }
{CHARCONST}     		{ return(CHARCONST); }
{STRING_LITERAL}  { return(STRING_LITERAL); }
{SN}		 		   { return(SN_CONST); }

"++"              { return(INC_OP); }
"--"              { return(DEC_OP); }

"&&"              { return(AND_OP); }
"||"              { return(OR_OP); }
"<="              { return(LE_OP); }
">="              { return(GE_OP); }
"=="              { return(EQ_OP); }
"!="              { return(NE_OP); }
"^"					{ return('^'); }
";"					{ return(';'); }
"{"		    		{ return('{'); }
"}"		    		{ return('}'); }
","					{ return(','); }
":"					{ return(':'); }
"="					{ return('='); }
"("					{ return('('); }
")"					{ return(')'); }
"."					{ return('.'); }

"-"					{ return('-'); }
"+"					{ return('+'); }
"*"					{ return('*'); }
"/"					{ return('/'); }
"%"					{ return('%'); }
"<"					{ return('<'); }
">"					{ return('>'); }


"\n"		   		{ lineno += 1; }
[ \t\v\f]			{ /* Eat all the whitespace */ }
.               	{ lexError("Unrecognized character"); }

%%

void comment()
{
	char c;
	while ((c = input()) != '\n' && c != 0) ;
}

void lexError(char *message)
{
   printf("Lexer error: \"%s\" in line %d. Token = %s\n", message, lineno, yytext);
   exit(1);
}