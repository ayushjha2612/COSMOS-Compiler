%{
    #include <stdio.h>
    #include <stdlib.h>
    void yyerror(char*);
    extern char yytext[];
    extern int yylex();
    extern int yylineno;
    extern FILE* yyout;
    extern int column;
%}

%token IDENTIFIER INTCONST CHARCONST SN_CONST BOOLCONST STRING_LITERAL
%token INC_OP DEC_OP LE_OP GE_OP EQ_OP NE_OP AND_OP OR_OP
%token CHAR INT FLOAT VOID BOOL STRING
%token STRUCT 
%token IF ELSE REPEAT CONTINUE BREAK RETURN
%token DIST LY AU MASS SOLAR_MASS DENSITY TIME SPEED ACC ENERGY FORCE FREQ PARSEC TEMP ARCSEC
%token PROC
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%start root_unit


%%
primary_expression
    : IDENTIFIER                         
    | constants
    |  '(' expression ')'
    ;
constants
    : INTCONST
    | CHARCONST
    | SN_CONST
    | BOOLCONST
    | STRING_LITERAL
    ;
postfix_expression
    : primary_expression
    |  postfix_expression '(' ')'
    |  postfix_expression '(' argument_expression_list ')' // Function call
    |  postfix_expression '.' IDENTIFIER
    |  postfix_expression INC_OP
    |  postfix_expression DEC_OP
    ;
argument_expression_list
    : assignment_expression
    |  argument_expression_list ',' assignment_expression
    ;
unary_expression
    : postfix_expression
    |  INC_OP unary_expression
    |  DEC_OP unary_expression
    ;
arithmetic_expression
    : unary_expression
	| arithmetic_expression '^' unary_expression
    | arithmetic_expression '*' unary_expression
    | arithmetic_expression '/' unary_expression
    | arithmetic_expression '%' unary_expression 
    | arithmetic_expression '+' unary_expression 
    | arithmetic_expression '-' unary_expression 
    ;
logical_expression
    : arithmetic_expression
    |  logical_expression '<'arithmetic_expression
    |  logical_expression '>'arithmetic_expression
    |  logical_expression LE_OP arithmetic_expression
    |  logical_expression GE_OP arithmetic_expression
    |  logical_expression EQ_OP arithmetic_expression
    |  logical_expression NE_OP arithmetic_expression
    |  logical_expression AND_OP arithmetic_expression
    |  logical_expression OR_OP arithmetic_expression
    ;
assignment_expression
    : logical_expression
    |  unary_expression '=' assignment_expression
    ;

expression
    : assignment_expression
    |  expression ',' assignment_expression    
    ;
declaration
    : type_specifier init_declarator_list ';'
    | struct_specifier
    ;
init_declarator_list
    : init_declarator
    |  init_declarator_list ',' init_declarator     
    ;
init_declarator
    : declarator
    |  declarator '=' assignment_expression
    ;
type_specifier
    : VOID
    |  CHAR
    |  INT
    |  BOOL
    |  STRING
    |  FLOAT
    |  STRUCT IDENTIFIER
    |  DIST
    |  LY
    |  AU
    |  MASS
    |  SOLAR_MASS
    |  DENSITY
    |  TIME
    |  SPEED
    |  ACC
    |  ENERGY
    |  FORCE
    |  FREQ
    |  PARSEC
    |  TEMP
    |  ARCSEC
    ;
struct_specifier
    :  STRUCT IDENTIFIER '{' struct_declaration_list '}' ';'
    ;
struct_declaration_list
    : type_specifier struct_declarator_list ';'
    |  struct_declaration_list type_specifier struct_declarator_list ';'
    ;
struct_declarator_list
    : declarator
    |  struct_declarator_list ',' declarator
    ;   
declarator  
    : IDENTIFIER                       
    |  '(' declarator ')'                 // Function declaration
    |  declarator '(' parameter_list ')'   
    |  declarator '(' ')'
    ;
parameter_list
    : parameter_declaration
    |  parameter_list ',' parameter_declaration
    ;
parameter_declaration
    : type_specifier declarator
    ;
statement
    : compound_statement
    |  expression_statement
    |  selection_statement
    |  iteration_statement
    |  jump_statement
    | error ';'
    | error '}'
    ;
statements_list
    : statement
    |  declaration
    |  statements_list statement
    |  statements_list declaration
    ;
compound_statement
    : '{' '}'
    |  '{' statements_list '}'
    ;
expression_statement
    : ';'
    |  expression ';'
    ;
selection_statement
    : IF '(' expression ')' statement	%prec LOWER_THAN_ELSE 
    |  IF '(' expression ')' statement ELSE statement
    ;
iteration_statement
    : REPEAT '(' expression_statement expression_statement ')' statement
    |  REPEAT'(' expression_statement expression_statement expression ')' statement
    | REPEAT'(' declaration expression_statement expression ')' statement
    | REPEAT'(' declaration expression_statement ')' statement
    ;
jump_statement
    : CONTINUE ';'
    |  BREAK ';'
    |  RETURN ';'
    |  RETURN expression ';'
    ;
root_unit
    : external_declaration
    |  root_unit external_declaration
    ;	
external_declaration
    :  PROC function_definition
    |  PROC function_declaration
    |  declaration
    ;
function_declaration
    : type_specifier declarator ';'
    ;
function_definition
    :  type_specifier declarator compound_statement
    ;
%%

void yyerror(char *s)
{
	fprintf(yyout, "At line no. %d : %s\n",yylineno, s);
}

int main(void)
{
	yyparse();
	return 0;
}