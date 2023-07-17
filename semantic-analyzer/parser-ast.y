%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "ast.h"
    void yyerror(char*);
    extern char yytext[];
    extern int yylex();
    extern int yylineno;
    extern FILE* yyout;
    extern int column;

    Func_decl *func;
%}

/* YYSTYPE union */
%union{
    // Types of values that we can have in constants
    Val val;

	// structures
    symbolEntry* symbol_table_item;
	Basic_node* node;

    // for declarations
	int data_type;
    int const_type;

    symbolEntry *entry;
}

%token <val> CHAR INT FLOAT VOID BOOL STRING IF ELSE REPEAT CONTINUE BREAK RETURN
%token <val> '+' '-' '*' '/' '%' INC_OP DEC_OP LE_OP GE_OP '>' '<' EQ_OP NE_OP AND_OP OR_OP 
%token <val> '{' '}' '(' ')' '[' ']' ';' ':' '.' ',' '=' '^'
%token <entry> IDENTIFIER
%token STRUCT
%token DIST LY AU MASS SOLAR_MASS DENSITY TIME SPEED ACC ENERGY FORCE FREQ PARSEC TEMP ARCSEC /*ASTROBJECT*/
%token PROC
%token <val> INTCONST CHARCONST SN_CONST BOOLCONST STRING_LITERAL

%left '(' ')' '[' ']' '.'
%right INC_OP DEC_OP
%left '^' '*' '/' '%'
%left '+' '-'
%left '>' '<' GE_OP LE_OP
%left EQ_OP
%left OR_OP
%left AND_OP
%right '='
%left ','

%type <node> root_unit
%type <data_type> type_specifier
%type <node> primary_expression constants postfix_expression
%type <node> unary_expression arithmetic_expression logical_expression assignment_expression expression
%type<node> argument_expression_list jump_statement statements_list compound_statement expression_statement statement


%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%start translation_unit
%%

primary_expression
    : IDENTIFIER    {$$ = $1;}               
    | constants { $$ = $1; }
    |  '(' expression ')'   { $$ = $2; }
    ;
constants
    : INTCONST  { $$ = new Const_node(INT_TYPE, $1); }
    | CHARCONST { $$ = new Const_node(CHAR_TYPE, $1); }
    | SN_CONST  { $$ = new Const_node(SN_TYPE, $1); }
    | BOOLCONST { $$ = new Const_node(BINARY_TYPE, $1); }
    | STRING_LITERAL    { $$ = new Const_node(STRING_TYPE, $1); }
    ;
postfix_expression
    : primary_expression    { $$ = $1; }
    |  postfix_expression '(' ')'   { $$ = $1; }
    |  postfix_expression '(' argument_expression_list ')' // Function call
    |  postfix_expression '.' IDENTIFIER
    |  postfix_expression INC_OP
    {
        $$ = new Inc_node($2,0,0);
    }
    |  postfix_expression DEC_OP
    {
        $$ = new Inc_node($2,1,0);
    }
    ;
argument_expression_list
    : assignment_expression { $$ = $1; }
    |  argument_expression_list ',' assignment_expression
    ;
unary_expression
    : postfix_expression    { $$ = $1; }
    |  INC_OP unary_expression
    {
        $$ = new Inc_node($2,0,1);
    }
    |  DEC_OP unary_expression
    {
        $$ = new Inc_node($2,1,1);
    }
    ;
arithmetic_expression
    : unary_expression  { $$ = $1; }
	| arithmetic_expression '^' unary_expression
    {
        $$ = new Arith_node(POW_OP,$1,$3);
    }
    | arithmetic_expression '*' unary_expression
    {
        $$ = new Arith_node(MULT_OP,$1,$3);
    }
    | arithmetic_expression '/' unary_expression
    {
        $$ = new Arith_node(DIV_OP,$1,$3);
    }
    | arithmetic_expression '%' unary_expression
    {
        $$ = new Arith_node(MOD_OP,$1,$3);
    }
    | arithmetic_expression '+' unary_expression
    {
        $$ = new Arith_node(ADD_OP,$1,$3);
    }
    | arithmetic_expression '-' unary_expression
    {
        $$ = new Arith_node(SUB_OP,$1,$3);
    }
    ;
logical_expression
    : arithmetic_expression { $$ = $1; }
    |  logical_expression '<'arithmetic_expression
    {
        $$ = new Rel_node(LT_OP,$1,$3);
    }
    |  logical_expression '>'arithmetic_expression
    {
        $$ = new Rel_node(GT_OP,$1,$3);
    }
    |  logical_expression LE_OP arithmetic_expression
    {
        $$ = new Rel_node(LE_OP,$1,$3);
    }
    |  logical_expression GE_OP arithmetic_expression
    {
        $$ = new Rel_node(GE_OP,$1,$3);
    }
    |  logical_expression EQ_OP arithmetic_expression
    {
        $$ = new Eq_node(EQ_OP,$1,$3);
    }
    |  logical_expression NE_OP arithmetic_expression
    {
        $$ = new Eq_node(NE_OP,$1,$3);
    }
    |  logical_expression AND_OP arithmetic_expression
    { 
        $$ = new Bool_node(AND_OP,$1,$3); 
    }
    |  logical_expression OR_OP arithmetic_expression
    { 
        $$ = new Bool_node(OR_OP,$1,$3);
    }
    ;
assignment_expression
    : logical_expression    { $$ = $1; }
    |  unary_expression '=' assignment_expression
    ;

expression
    : assignment_expression { $$ = $1; }
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
    : VOID  { $$ = VOID_TYPE; }
    |  CHAR { $$ = CHAR_TYPE; }
    |  INT  { $$ = INT_TYPE; }
    |  BOOL { $$ = BOOL_TYPE; }
    |  STRING   {$$ = STRING_TYPE; }
    |  FLOAT    { $$ = FLOAT_TYPE; }
    |  STRUCT IDENTIFIER
    |  DIST { $$ = SN_TYPE; }
    |  LY   { $$ = SN_TYPE; }
    |  AU   { $$ = SN_TYPE; }
    |  MASS { $$ = SN_TYPE; }
    |  SOLAR_MASS   { $$ = SN_TYPE; }
    |  DENSITY  { $$ = SN_TYPE; }
    |  TIME { $$ = SN_TYPE; }
    |  SPEED    { $$ = SN_TYPE; }
    |  ACC  { $$ = SN_TYPE; }
    |  ENERGY   { $$ = SN_TYPE; }
    |  FORCE    { $$ = SN_TYPE; }
    |  FREQ { $$ = SN_TYPE; }
    |  PARSEC   { $$ = SN_TYPE; }
    |  TEMP { $$ = SN_TYPE; }
    |  ARCSEC   { $$ = SN_TYPE; }
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
    : compound_statement    { $$ = $1; }
    |  expression_statement { $$ = $1; }
    |  selection_statement  { $$ = $1; }
    |  iteration_statement  { $$ = $1; }
    |  jump_statement   { $$ = $1; }
    | error ';'
    | error '}'
    ;
statements_list
    : statement { $$ = Stmts_node(NULL, 0, $1); }
    |  declaration  { $$ = Decls_node(NULL, 0, $1); }
    |  statements_list statement    
    { 
        Stmts_node *stmt = $1;
        $$ = Stmts_node(stmt->stmts, stmt_cnt, $2);
    }
    |  statements_list declaration
    ;
compound_statement
    : '{' '}'
    |  '{' statements_list '}'  { $$ = $2; }
    ;
expression_statement
    : ';'
    |  expression ';'   {$$ = $1; }
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
    : CONTINUE ';'  { $$ = new Jump_node(0); }
    |  BREAK ';'    { $$ = new Jump_node(1); }
    |  RETURN expression ';'    { func->return_node = new Return_node(func->ret_type, $2); }
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