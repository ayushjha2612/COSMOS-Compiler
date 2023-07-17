%{
    #include "codegen.h"
    #include "codegen.cpp"

    using namespace std;
    void yyerror(string);
    extern char yytext[];
    extern int yylex();
    extern int yylineno;
    extern FILE* yyout;
    extern FILE* yyin;
    extern int column;
    extern int lineno;
    extern ofstream errorfile;
    extern ofstream logfile;
    extern ofstream genfile; 
    extern ifstream inputfile;
    void printError(string error, bool isWarn);

    int num_errors=0;
    int num_warns=0;
%}

%union{
    syntax_tree_node* node;
}

%token<node> IDENTIFIER INTCONST CHARCONST SN_CONST BOOLCONST STRING_LITERAL
%token INC_OP DEC_OP AND_OP OR_OP LE_OP GE_OP EQ_OP NE_OP  
                    
%token CHAR INT VOID BOOL STRING
%token DIST LY AU MASS SOLAR_MASS DENSITY TIME SPEED ACC ENERGY FORCE FREQ PARSEC TEMP ARCSEC
%token STRUCT 
%token IF ELSE REPEAT CONTINUE BREAK RETURN
%token PROC

%type<node> primary_expression constants postfix_expression argument_list unary_expression arithmetic_expression 
            logical_expression assignment_expression expression declaration init_declarator init_declarator_list 
            type_specifier struct_specifier struct_declaration_list struct_declarator_list declarator parameter_list 
            parameter_declaration statement statements_list compound_statement expression_statement 
            selection_statement iteration_statement jump_statement root_unit external_declaration 
            function_definition

%left '(' ')' '[' ']' '.'
%right INC_OP DEC_OP
%left '^' '*' '/'
%left '+' '-'
%left '>' '<' GE_OP LE_OP
%left EQ_OP
%left OR_OP
%left AND_OP
%right '='
%left ','
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%start root_unit


%%
primary_expression
    : IDENTIFIER     
    {
        $$=$1;
        logfile << "primary_expression - "  << $1->name << "\n";
        string idname = $1->name;
        handleIdentifierExpression(idname);
        
    }                    
    | constants
    {
        $$ = $1;
        logfile << " primary_expression- constants  \n";
        handleConstExpr();
    }
    |  '(' expression ')'
    {
        $$ = new syntax_tree_node( "(" + $2->name+ ")" + "\n", " ( EXPRESSION )", lineno);
        logfile << " primary_expression-  '(' expression ')'\n  ";
        delete $2;
    }
    ;
constants
    : INTCONST
    {
        $$=$1;
        logfile << " constants- "<< $1->name << "\n";
        constType = "INT";
    }
    | CHARCONST
    {
        $$=$1;
        logfile << " constants- "<< $1->name << "\n";
        constType = "CHAR";
    }
    | SN_CONST
    {
        $$=$1;
        logfile << " constants- "<< $1->name << "\n";
        constType= "SN";
        string val = $$->name;
        constants.push(val);
    }
    | BOOLCONST
    {
        $$=$1;
        logfile << " constants- "<< $1->name << "\n";
        constType= "BOOL";
    }
    | STRING_LITERAL
    {
        $$=$1;
        logfile << " constants- "<< $1->name << "\n";
        constType= "STRING";
    }
    ;
postfix_expression
    : primary_expression
    {
        $$=$1;
        logfile << "postfix_expression- primary_expression\n  ";
    }
    |  postfix_expression '(' ')'
    {
        $$ = new syntax_tree_node($1->name + "(" + ")" + "\n", "VOID_FUNCTION_CALL", lineno );
        logfile << "postfix_expression- postfix_expression '(' ')' \n  ";
        handleFunctionCall(true);
        delete $1;
    }
    |  postfix_expression '(' argument_list ')' // Function call
    {
        $$ = new syntax_tree_node($1->name + "(" + $3->name + ")" + "\n", "FUNCTION_CALL", lineno );
        logfile << "postfix_expression- postfix_expression '(' argument_list ')' \n  ";
        handleFunctionCall();
        delete $1; delete $3;
    }
    |  postfix_expression '.' IDENTIFIER
    {
        $$ = new syntax_tree_node($1->name + "." + $3->name + "\n" , "STRUCT_ACCESS", lineno );
        logfile << "postfix_expression- postfix_expression '.'" << $3->name <<"\n  ";
        delete $1; delete $3;
    }
    |  postfix_expression INC_OP
    {
        $$ = new syntax_tree_node($1->name + "++" + "\n", "POST_INCREMENT", lineno );
        logfile << "postfix_expression- postfix_expression INC_OP \n  ";
        delete $1;
    }
    |  postfix_expression DEC_OP
    {
        $$ = new syntax_tree_node($1->name + "--" + "\n", "POST_DECREMENT", lineno );
        logfile << "postfix_expression- postfix_expression DEC_OP \n  ";
        delete $1;
    }
    ;
argument_list
    : assignment_expression
    {
        $$=$1;
        logfile << "argument_list- assignment_expression \n  ";
    }
    |  argument_list ',' assignment_expression
    {
        $$ = new syntax_tree_node($1->name + "," + $3->name + "\n", "MULTIPLE_ARGUMENTS" , lineno);
        logfile << "argument_list- argument_list ',' assignment_expression \n  ";
        delete $1;
        delete $3;
    }
    ;
unary_expression
    : postfix_expression
    {
        $$=$1;
        logfile << "unary_expression- postfix_expression \n  ";
    }
    |  INC_OP unary_expression
    {
        $$ = new syntax_tree_node("++" + $2->name  + "\n", "PRE_INCREMENT", lineno );
        logfile << "unary_expression- INC_OP unary_expression \n  ";
        delete $2;
    }
    |  DEC_OP unary_expression
    {
        $$ = new syntax_tree_node("--" + $2->name  + "\n", "PRE_DECREMENT", lineno );
        logfile << "unary_expression- DEC_OP unary_expression \n  ";
        delete $2;
    }
    ;
arithmetic_expression
    : unary_expression
    {
        $$=$1;
        logfile << "arithmetic_expression- unary_expression \n  ";
        handleArithExpr();
    }
	| arithmetic_expression '^' unary_expression
    {
        $$ = new syntax_tree_node($1->name + "^" + $3->name  + "\n", "POW_EXPRESSION", lineno );
        logfile << "arithmetic_expression- arithmetic_expression '^' unary_expression \n  ";
        handleArithExpr("^");
        delete $1; delete $3;
    }
    | arithmetic_expression '*' unary_expression
    {
        $$ = new syntax_tree_node($1->name + "*" + $3->name  + "\n", "MUL_EXPRESSION", lineno );
        logfile << "arithmetic_expression- arithmetic_expression '*' unary_expression \n  ";
        handleArithExpr("*");
        delete $1; delete $3;
    }
    
    | arithmetic_expression '/' unary_expression
    {
        $$ = new syntax_tree_node($1->name + "/" + $3->name  + "\n", "DIV_EXPRESSION", lineno );
        logfile << "arithmetic_expression- arithmetic_expression '/' unary_expression \n  ";
        handleArithExpr("/");
        delete $1; delete $3;
    }
    | arithmetic_expression '+' unary_expression 
    {
        $$ = new syntax_tree_node($1->name + "+" + $3->name  + "\n", "ADD_EXPRESSION", lineno );
        logfile << "arithmetic_expression- arithmetic_expression '+' unary_expression  \n  ";
        handleArithExpr("+");
        delete $1;  delete $3;
    }
    | arithmetic_expression '-' unary_expression 
    {
        $$ = new syntax_tree_node($1->name + "-" + $3->name  + "\n", "SUB_EXPRESSION", lineno );
        logfile << "arithmetic_expression- arithmetic_expression '-' unary_expression  \n  ";
        handleArithExpr("-");
        delete $1;  delete $3;
    }
    ;
logical_expression
    : arithmetic_expression
    {
        $$=$1;
        logfile << "logical_expression- arithmetic_expression \n  ";
        
    }
    |  arithmetic_expression '<' arithmetic_expression
    {
        $$ = new syntax_tree_node($1->name + "<" + $3->name  + "\n", "LT_EXPRESSION", lineno );
        logfile << "logical_expression-  arithmetic_expression '<' arithmetic_expression \n  ";
        handleLogicalExpr("<");
        delete $1; delete $3;
    }
    |  arithmetic_expression '>' arithmetic_expression
    {
        $$ = new syntax_tree_node($1->name + ">" + $3->name  + "\n", "GT_EXPRESSION", lineno );
        logfile << "logical_expression- arithmetic_expression'>' arithmetic_expression \n  ";
        handleLogicalExpr(">");
        delete $1;
        delete $3;
    }
    |  arithmetic_expression LE_OP arithmetic_expression
    {
        $$ = new syntax_tree_node($1->name + "<=" + $3->name  + "\n", "LE_EXPRESSION", lineno );
        logfile << "logical_expression- arithmetic_expression LE_OP arithmetic_expression\n  ";
        handleLogicalExpr("<=");
        delete $1;
        delete $3;
    }
    |  arithmetic_expression GE_OP arithmetic_expression
    {
        $$ = new syntax_tree_node($1->name + ">=" + $3->name  + "\n", "GE_EXPRESSION", lineno );
        logfile << "logical_expression- arithmetic_expression GE_OP arithmetic_expression \n  ";
        handleLogicalExpr(">=");
        delete $1;
        delete $3;
    }
    |  arithmetic_expression EQ_OP arithmetic_expression
    {
        $$ = new syntax_tree_node($1->name + "==" + $3->name  + "\n", "EQUAL_EXPRESSION" , lineno);
        logfile << "logical_expression- arithmetic_expression EQ_OP arithmetic_expression\n  ";
        handleLogicalExpr("==");
        delete $1;
        delete $3;
    }
    |  arithmetic_expression NE_OP arithmetic_expression
    {
        $$ = new syntax_tree_node($1->name + "!=" + $3->name  + "\n", "NOTEQUAL_EXPRESSION", lineno );
        logfile << "logical_expression- arithmetic_expression NE_OP arithmetic_expression \n  ";
        handleLogicalExpr("!=");
        delete $1;
        delete $3;
    }
    |  arithmetic_expression AND_OP arithmetic_expression
    {
        $$ = new syntax_tree_node($1->name + "&&" + $3->name  + "\n", "AND_EXPRESSION", lineno );
        logfile << "logical_expression- arithmetic_expression AND_OP arithmetic_expression \n  ";
        handleAndOr("&&");
        delete $1;
        delete $3;
    }
    |  arithmetic_expression OR_OP arithmetic_expression
    {
        $$ = new syntax_tree_node($1->name + "||" + $3->name  + "\n", "OR_EXPRESSION", lineno );
        logfile << "logical_expression- arithmetic_expression OR_OP arithmetic_expression \n  ";
        handleAndOr("||");
        delete $1;
        delete $3;
    }
    ;
assignment_expression
    : logical_expression
    {
        $$=$1;
        logfile << "assignment_expression- logical_expression \n  ";
    }
    |  unary_expression '=' assignment_expression
    {
        $$ = new syntax_tree_node($1->name + "=" + $3->name  + "\n", "ASSIGN_EXPRESSION", lineno );
        logfile << "assignment_expression- unary_expression '=' assignment_expression \n  ";
        handleAssignExpr();
        delete $1;  delete $3;
    }
    ;

expression
    : assignment_expression
    {
        $$=$1;
        logfile << "expression- assignment_expression\n  ";
    }
    |  expression ',' assignment_expression    
    {
        $$ = new syntax_tree_node($1->name + " , " + $3->name  + "\n", "MULT_ASSIGN_EXPRESSION", lineno );
        logfile << "expression- expression ',' assignment_expression \n  ";
        delete $1; delete $3;
    }
    ;
declaration
    : type_specifier init_declarator_list ';'
    {
        $$ = new syntax_tree_node($1->name + $2->name + ";"  + "\n", "TYPE_INIT_DECLARATION_LIST" , lineno);
        logfile << "declaration- type_specifier init_declarator_list ';' \n  ";
        if(funcName=="")
            genCodeFuncDefinition($1->line, $1->line,false);
        handleIdentDecl();
        delete $1; delete $2;
    }
    | struct_specifier
    {
        $$=$1;
        logfile << "declaration- struct_specifier \n  ";
    }
    ;
init_declarator_list
    : init_declarator
    {
        $$=$1;
        logfile << "init_declarator_list- init_declarator \n  ";
    }
    |  init_declarator_list ',' init_declarator     
    {
        $$ = new syntax_tree_node($1->name + "," + $3->name + "\n", "MULT_INIT_DECLARATOR", lineno );
        logfile << "init_declarator_list- init_declarator_list ',' init_declarator \n  ";
        delete $1;  delete $3;
    }
    ;
init_declarator
    : declarator
    {
        $$=$1;
        logfile << "init_declarator - declarator \n  ";
    }
    |  declarator '=' assignment_expression
    {
        $$ = new syntax_tree_node($1->name + "=" + $3->name  + "\n", "DECALRATION_ASSIGNMENT", lineno );
        logfile << "init_declarator - declarator '=' assignment_expression \n  ";
        delete $1; delete $3;
    }
    ;
type_specifier
    : VOID
    {
        $$ = new syntax_tree_node("VOID", "VOID_TYPE", lineno); 
        logfile << "type_specifier -"<< $$->name <<  " \n";
        handleTypes($$->name);
    }
    | CHAR
    {   
        $$ = new syntax_tree_node("CHAR", "CHAR_TYPE", lineno);
        logfile << "type_specifier -"<< $$->name <<  " \n"; 
        handleTypes($$->name);
    }
    | INT
    {
        $$ = new syntax_tree_node("INT", "INT_TYPE", lineno);   
        logfile << "type_specifier -"<< $$->name <<  " \n";
        handleTypes($$->name);
    }
    | BOOL
    {   
        $$ = new syntax_tree_node("BOOL", "BOOL_TYPE", lineno);
        logfile << "type_specifier -"<< $$->name <<  " \n  ";
        handleTypes($$->name);
    }
    | STRING
    {
        $$ = new syntax_tree_node("STRING", "STRING_TYPE", lineno);
        logfile << "type_specifier -"<< $$->name <<  " \n  ";
        handleTypes($$->name);
    }
    | STRUCT IDENTIFIER
    {
        $$ = new syntax_tree_node("STRUCT_" + $2->name, "STRUCT_" + $2->name + "_TYPE", lineno);
        logfile << "type_specifier -"<< $$->name <<  " \n  ";
        handleTypes($$->name);
        delete $2;
    }
    | DIST
    {
        $$ = new syntax_tree_node("DIST", "DIST_TYPE", lineno);
        logfile << "type_specifier -"<< $$->name <<  " \n  ";
        handleTypes($$->name);
    }
    | LY
    {
        $$ = new syntax_tree_node("LY", "LY_TYPE", lineno);
        logfile << "type_specifier -"<< $$->name <<  " \n  ";
        handleTypes($$->name);
    }
    | AU
    {
        $$ = new syntax_tree_node("AU", "AU_TYPE", lineno);
        logfile << "type_specifier -"<< $$->name <<  " \n  ";
        handleTypes($$->name);
    }
    | MASS
    {
        $$ = new syntax_tree_node("MASS", "MASS_TYPE", lineno);
        logfile << "type_specifier -"<< $$->name <<  " \n  ";
        handleTypes($$->name);
    
    }
    | SOLAR_MASS
    {
        $$ = new syntax_tree_node("SOLAR_MASS", "SOLAR_MASS_TYPE", lineno);
        logfile << "type_specifier -"<< $$->name <<  " \n  ";
        handleTypes($$->name);
    }
    | DENSITY
    {
        $$ = new syntax_tree_node("DENSITY", "DENSITY_TYPE", lineno);
        logfile << "type_specifier -"<< $$->name <<  " \n  ";
        handleTypes($$->name);
    }
    | TIME
    {
        $$ = new syntax_tree_node("TIME", "TIME_TYPE", lineno);
        logfile << "type_specifier -"<< $$->name <<  " \n  ";
        handleTypes($$->name);
    }
    | SPEED
    {
        $$ = new syntax_tree_node("SPEED", "SPEED_TYPE", lineno);
        logfile << "type_specifier -"<< $$->name <<  " \n  ";
        handleTypes($$->name);
    }
    | ACC
    {
        $$ = new syntax_tree_node("ACC", "ACC_TYPE", lineno);
        logfile << "type_specifier -"<< $$->name <<  " \n  ";
        handleTypes($$->name);
    }
    | ENERGY
    {
        $$ = new syntax_tree_node("ENERGY", "ENERGY_TYPE", lineno);
        logfile << "type_specifier -"<< $$->name <<  " \n  ";
        handleTypes($$->name);
    }
    | FORCE
    {
        $$ = new syntax_tree_node("FORCE", "FORCE_TYPE", lineno);
        logfile << "type_specifier -"<< $$->name <<  " \n  ";
        handleTypes($$->name);
    }
    | FREQ
    {
        $$ = new syntax_tree_node("FREQ", "FREQ_TYPE", lineno);
        logfile << "type_specifier -"<< $$->name <<  " \n  ";
        handleTypes($$->name);
    }
    | PARSEC
    {
        $$ = new syntax_tree_node("PARSEC", "PARSEC_TYPE", lineno);
        logfile << "type_specifier -"<< $$->name <<  " \n  ";
        handleTypes($$->name);
    }
    | TEMP
    {
        $$ = new syntax_tree_node("TEMP", "TEMP_TYPE", lineno);
        logfile << "type_specifier -"<< $$->name <<  " \n  ";
        handleTypes($$->name);
    }
    | ARCSEC
    {
        $$ = new syntax_tree_node("ARCSEC", "ARCSEC_TYPE", lineno);
        logfile << "type_specifier -"<< $$->name <<  " \n  ";
        handleTypes($$->name);
    };
struct_specifier
    :  STRUCT IDENTIFIER '{' struct_declaration_list '}' ';'
    {
        $$ = new syntax_tree_node("STRUCT" + $2->name + "{" + $4->name + "}" + "; \n", "STRUCT_DECLARATION", lineno );
        logfile << "struct_specifier - STRUCT "<< $2->name << " '{' struct_declaration_list '}' ';' \n  ";
        genCodeStruct($2->line, $4->line+1);
        handleStructDecl();
        delete $2; delete $4;
    }
    ;
struct_declaration_list
    : type_specifier struct_declarator_list ';'
    {
        $$ = new syntax_tree_node($1->name + $2->name + ";"+ "\n", "STRUCT_BODY", lineno );
        logfile << "struct_declaration_list - type_specifier struct_declarator_list ';' \n  ";
        delete $1;
        delete $2;
    }
    |  struct_declaration_list type_specifier struct_declarator_list ';'
    {
        $$ = new syntax_tree_node($1->name + "," + $3->name + "\n", "MULT_INIT_DECLARATOR", lineno );
        logfile << "struct_declaration_list - struct_declaration_list type_specifier struct_declarator_list ';' \n  ";
        delete $1;
        delete $2;
        delete $3;
    }
    ;
struct_declarator_list
    : declarator
    {
        $$=$1;
        logfile << "struct_declarator_list - declarator \n  ";
    }
    |  struct_declarator_list ',' declarator
    {
        $$ = new syntax_tree_node($1->name + "," + $3->name  + "\n", "MULT_STRUCT_DECLARATOR" , lineno);
        logfile << "struct_declarator_list - struct_declarator_list ',' declarator \n  ";
        delete $1;
        delete $3;
    }
    
    ;   
declarator  
    : IDENTIFIER 
    {
        $$=$1;
        logfile << "declarator - " << $1->name << "\n  ";
        handleIdent($1->name);
    }                      
    |  declarator '(' parameter_list ')'   
    {
        $$ = new syntax_tree_node($1->name + "(" + $3->name + ")" + "\n", "FUNCTION_DECLARATION", lineno );
        logfile << "declarator - declarator '(' parameter_list ')' \n  ";
        handleFuncDeclaration();
        genCodeFuncDecl(lineno);
        delete $1;  delete $3;
    }
    |  declarator '(' ')'
    {
        $$ = new syntax_tree_node($1->name + "(" + ")"  + "\n", "FUNCTION_DECL_NO_ARGS", lineno );
        logfile << "declarator - declarator '(' ')' \n  ";
        handleFuncDeclaration(true);
        genCodeFuncDecl(lineno);
        delete $1;
    }
    ;
parameter_list
    : parameter_declaration
    {
        $$=$1;
        logfile << "parameter_list - parameter_declaration \n  ";
        paramName.clear();
        paramType.clear();
    }
    |  parameter_list ',' parameter_declaration
    {
        $$ = new syntax_tree_node($1->name + "," + $3->name  + "\n", "MULT_PARAMETERS" , lineno);
        logfile << "parameter_list - parameter_list ',' parameter_declaration \n  ";
        delete $1; delete $3;
    }
    ;
parameter_declaration
    : type_specifier declarator
    {
        $$ = new syntax_tree_node($1->name + "" + $2->name  + "\n", "PARAMETER_DECALRATION", lineno );
        logfile << "parameter_declaration - type_specifier declarator\n  ";
        paramList.push_back({paramName, paramType});
        delete $1;
        delete $2;
    }
    ;
statement
    : compound_statement
    {
        $$=$1;
        logfile << "statement - compound_statement \n  ";
    }
    |  expression_statement
    {
        $$=$1;
        logfile << "statement - expression_statement \n  ";
    }
    |  selection_statement
    {
        $$=$1;
        logfile << "statement - selection_statement \n  ";
    }
    |  iteration_statement
    {
        $$=$1;
        logfile << "statement - iteration_statement \n  ";
    }
    |  jump_statement
    {
        $$=$1;
        logfile << "statement - jump_statement \n  ";
    }
    // | error ';'
    // | error '}'
    ;
statements_list
    : statement
    {
        $$=$1;
        logfile << "statements_list - statement \n  ";
    }
    |  declaration
    {
        $$=$1;
        logfile << "statements_list - declaration\n  ";
    }
    |  statements_list statement
    {
        $$ = new syntax_tree_node($1->name + "" + $2->name  + "\n", "MULT_STATEMENTS", lineno );
        logfile << "statements_list - statements_list statement \n  ";
        delete $1;
        delete $2;
    }
    |  statements_list declaration
    {
        $$ = new syntax_tree_node($1->name + "" + $2->name  + "\n", "MULT_DECLARATION_LIST", lineno );
        logfile << "statements_list - statements_list declaration \n  ";
        delete $1;
        delete $2;
    }
    ;
compound_statement
    : '{' '}'
    {
        $$ = new syntax_tree_node("{}\n", "EMPTY_BRACES", lineno );
        logfile << "compound_statement - '{' '}' \n  ";
    }
    |  '{' statements_list '}'
    {
        $$ = new syntax_tree_node("{" + $2->name + "}" + "\n", "COMPOUND_STATEMENT", lineno );
        logfile << "compound_statement - '{' statements_list '}' \n  ";
        delete $2;
    }
    ;
expression_statement
    : ';'    
    {
        $$ = new syntax_tree_node( ";\n", "EMPTY_STATEMENT", lineno );
        logfile << "expression_statement - ';'  \n  ";
        handleExprStmt();
    }
    |  expression ';'
    {
        $$ = new syntax_tree_node($1->name + ";"  + "\n", "EMPTY_EXPRSESSION", lineno );
        logfile << "expression_statement - expression '; \n  ";
        handleExprStmt();
        //genCodeExprStmt(lineno);
        delete $1;
    }
    ;
selection_statement
    : IF '(' expression ')' statement	%prec LOWER_THAN_ELSE 
    {
        $$ = new syntax_tree_node("IF (" + $3->name + ")" + $5->name  + "\n", "IF_STATEMENT", lineno );
        logfile << "selection_statement - IF '(' expression ')' statement \n  ";
        delete $5;
        delete $3;
    }
    |  IF '(' expression ')' statement ELSE statement
    {
        $$ = new syntax_tree_node("IF (" + $3->name + ")" + $5->name+ "ELSE" + $7->name + "\n", "IF_STATEMENT", lineno );
        logfile << "selection_statement - IF '(' expression ')' statement ELSE statement \n  ";
        delete $5;
        delete $3;
        delete $7;
    }
    ;
iteration_statement
    : REPEAT '(' expression_statement expression_statement ')' statement
    {
        $$ = new syntax_tree_node("REPEAT (" + $3->name + $4->name + ")" + $6->name + "\n", "REPEAT_NO_UPDATE_NO_DECL", lineno );
        logfile << "iteration_statement - REPEAT '(' expression_statement expression_statement ')' statement\n  ";
        delete $3;
        delete $4;
        delete $6;
    }
    |  REPEAT'(' expression_statement expression_statement expression ')' statement
    {
        $$ = new syntax_tree_node("REPEAT (" + $3->name + $4->name+ $5->name + ")" + $7->name + "\n", "REPEAT_NO_DECL", lineno );
        logfile << "iteration_statement - REPEAT'(' expression_statement expression_statement expression ')' statement \n  ";
        delete $3;
        delete $4;
        delete $5;
        delete $7;
    }
    | REPEAT'(' declaration expression_statement expression ')' statement
    {
        $$ = new syntax_tree_node("REPEAT (" + $3->name + $4->name+ $5->name + ")" + $7->name + "\n", "REPEAT_NO_UPDATE", lineno );
        logfile << "iteration_statement - REPEAT'(' declaration expression_statement expression ')' statement \n  ";
        delete $3;
        delete $4;
        delete $5;
        delete $7;
    }
    | REPEAT'(' declaration expression_statement ')' statement
    {
        $$ = new syntax_tree_node("REPEAT (" + $3->name+ $4->name+ + ")" + $6->name + "\n", "REPEAT", lineno );
        logfile << "iteration_statement - REPEAT'(' declaration expression_statement ')' statement \n  ";
        delete $3;
        delete $4;
        delete $6;
    }
    ;
jump_statement
    : CONTINUE ';'
    {
        $$ = new syntax_tree_node("CONTINUE ;\n", "CONTINUE" , lineno);
        logfile << "jump_statement - CONTINUE ';' \n  ";
        genfile << "\tcontinue;\n";
    }
    |  BREAK ';'
    {
        $$ = new syntax_tree_node("BREAK ;\n", "BREAK", lineno );
        logfile << "jump_statement -  BREAK ';' \n  ";
        genfile << "\tbreak;\n";
    }
    |  RETURN ';'
    {
        $$ = new syntax_tree_node("RETURN ;\n", "RETURN" , lineno);
        logfile << "jump_statement - RETURN ';' \n  ";
        genfile << "\treturn;\n";
    }
    |  RETURN expression ';'
    {
        $$ = new syntax_tree_node( "RETURN" + $2->name +"; \n", "RETURN EXPRESSION", lineno );
        logfile << "jump_statement - RETURN expression ';' \n  ";  
       // genCodeExprStmt(lineno);
        handleReturnStmt();
        delete $2;
    }
    ;
root_unit
    : external_declaration
    {
        $$=$1;
        logfile << "root_unit - external_declaration \n  ";
    }
    |  root_unit external_declaration
    {
        $$ = new syntax_tree_node( $1->name + $2->name +"\n", "MULT_EXTERNAL_DECLARATION" , lineno);
        logfile << "root_unit - root_unit external_declaration\n  ";
        delete $1; delete $2;
    }
    ;	
external_declaration
    :  PROC function_definition
    {
        $$ = new syntax_tree_node( "PROC" + $2->name +"; \n", "PROC_FUNCTION_DEFINITON", lineno );
        logfile << "external_declaration - PROC function_definition \n  ";
        delete $2;
    }
    |  declaration
    {
        $$=$1;
        logfile << "external_declaration - declaration \n  ";
    }
    ;
function_definition
    :  type_specifier declarator compound_statement
    {
        $$ = new syntax_tree_node( $1->name + $2->name + $3->name +"\n", "ACT_FUNCTION_DEFINITION" , lineno);
        logfile << "function_definition - type_specifier declarator compound_statement \n  ";
        int start_func = $1->line;
        int end_func = $3->line;
        genCodeFuncDefinition(start_func+1, end_func);
        handleFunctionDefinition($1->name);
        delete $1;  delete $2;  delete $3;
    }
    ;
%%

void printError(string error, bool isWarn =false)
{
    if(!isWarn)
    {
        errorfile << "ERROR at line no. " << lineno << " : " << error << endl;
        num_errors++;
    }
    else
    {
        errorfile << "Warning : " << error << endl;
        num_warns++;
    }
    
   
}
void yyerror(string s) {
        printError("Syntax Error", false);
    }

int main(int argc, char* argv[])
{
    if(argc != 2) {
        cout << "Please provide input file name and try again\n";
        return 0;
    }

    FILE* fin = fopen(argv[1], "r");
    
    if(fin == NULL) {
        printf("Cannot open input file\n");
        return 0;
    } 
    yyin = fin;
    string input_file = string(argv[1]);
    string temp = input_file;
    inputfile.open(input_file);
    int ind = input_file.find(".cos");
    input_file.erase(ind);

    string efile = input_file + "_logs.txt";
    string lfile = input_file + "_rules.txt";
    gfile = input_file + "_gen.cpp";

    
    errorfile.open(efile);
    logfile.open(lfile);
    genfile.open(gfile);

    beginCodeGen();
    handleIO();

	yyparse();
    
    checkUnusedVars();
    

    if(num_errors>0)
    {
         errorfile << "\n\nCompilation terminated! " << num_errors <<  " errors and "<< num_warns <<" warnings generated.\n " <<
         " Check ../testCases/" << temp << " to coreect them.\n";
         remove(gfile.c_str());
    }
    else
    {
        errorfile << "\nCompilation successful, no errors detected and "<< num_warns << " warnings generated!"<< "\nPlease Check output/" 
        << gfile << " generated file.\n";
        
    }
    remove(lfile.c_str());
    fclose(fin);
    errorfile.close();
    inputfile.close();
    genfile.close();
	return 0;
}