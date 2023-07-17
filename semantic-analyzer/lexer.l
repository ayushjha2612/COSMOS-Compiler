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
#include "symtab.h"
#include "parser.tab.h"

extern void printError(string error, bool isWarn);
int lineno = 1;
void prints(char *token_type);
// void lexError(char*);
void comment(void);
%}
%option yylineno
%x COMMENT
%%

"/*"				   { BEGIN(COMMENT); }
<COMMENT>"*/" 		{ BEGIN(INITIAL); }
<COMMENT>[^/\n]+		
<COMMENT>"\n"		{ lineno += 1; }

[#]                 { comment(); }

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
"false"				{ yylval.node = new syntax_tree_node(string(yytext), "BOOLCONST");
                    return(BOOLCONST); }
"force"           { return(FORCE); }
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
"true"				 { yylval.node = new syntax_tree_node(string(yytext), "BOOLCONST");
                    return(BOOLCONST); }
"void"            { return(VOID); }

{IDENTIFIER}      { yylval.node = new syntax_tree_node(string(yytext), "IDENTIFIER");
                    return(IDENTIFIER); }

{INTCONST}     	{ yylval.node = new syntax_tree_node(string(yytext), "INTCONST");
                    return(INTCONST); }

{CHARCONST}     	{ yylval.node = new syntax_tree_node(string(yytext), "CHARCONST");
                    return(CHARCONST); }

{STRING_LITERAL}  { yylval.node = new syntax_tree_node(string(yytext), "STRING_LITERAL"); 
                    return(STRING_LITERAL); }

{SN}		 		   { yylval.node = new syntax_tree_node(string(yytext), "SN_CONST"); 
                    return(SN_CONST); }

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
"<"					{ return('<'); }
">"					{ return('>'); }


"\n"		   		{ lineno += 1; }
[ \t\v\f]			{ /* Eat all the whitespace */ }
.               	{printError("Unrecognized symbol found "+ string(yytext), false);}

%%
void comment()
{
    char c = yyinput();
    while(c!= '\n')
    {
       c =yyinput();
    }
    lineno++;
     
}

// void lexError(char *message)
// {
//    printf("Lexer error: \"%s\" in line %d. Token = %s\n", message, lineno, string(yytext));
//    exit(1);
// }
