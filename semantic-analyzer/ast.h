#ifndef AST_H
#define AST_H

#include <string>
#include <iostream>
#include "symtab.h"
using namespace std;

/****************** Node Types ******************/
enum class Node_type
{
    BASIC_NODE, // Used for roots only

    // declarations
    DECLS,
    DECL_NODE,  // declaration
    CONST_NODE, // constant

    // statements
    STMTS,
    IF_NODE,     // if statement
    ELIF_NODE,   // else if branch
    FOR_NODE,    // for statement
    ASSIGN_NODE, // assigment
    JUMP_NODE,   // continue, break and "main" return statements
    INC_NODE,    // increment statement (non-expression one)
    FUNC_CALL,   // function call
    CALL_PARAMS,

    // expressions
    ARITH_NODE, // arithmetic expression
    BOOL_NODE,  // boolean expression
    REL_NODE,   // relational expression
    EQ_NODE,    // equality expression

    // functions
    FUNC_DECLS,
    FUNC_DECL,   // function declaration
    RETURN_TYPE,
    DECL_PARAMS,
    RETURN_NODE, // return statement of functions
};
/****************** Node Types ******************/

/****************** Operator Types ******************/
enum class Arith_op
{
    ADD_OP,
    SUB_OP,
    MULT_OP,
    DIV_OP,
    MOD_OP,
    INC_OP,
    DEC_OP,
    POW_OP
};

enum class Bool_op
{
    OR_OP,
    AND_OP
};

enum class Rel_op
{
    GT_OP, // > operator
    LT_OP, // < operator
    GE_OP, // >= operator
    LE_OP  // <= operator
};

enum class Eq_op
{
    EQ_OP, // == operator
    NE_OP  // != operator
};
/****************** Operator Types ******************/

/* SN Datatype defined*/
class sn
{
public:
    sn(int front = 0, int back = 0, int power = 0);
    int front;
    int back;
    int power;
};

/****************** Value ******************/
// Types of values that we can have in constants
typedef union Value
{
    int ival;
    char cval;
    bool bval;
    sn snval;
    string stval;
} Val;
/****************** Value ******************/

/****************** Node definitions ******************/
class Basic_node
{
public:
    Basic_node(Node_type type, Basic_node *left, Basic_node *right);
    Node_type type;    // node type
    Basic_node *left;  // left child
    Basic_node *right; // right child
};

// Declarations
class Decls_node
{
public:
    Decls_node(Basic_node **decls, int decl_cnt);
    Node_type type = Node_type::DECLS;
    Basic_node **decls;
    int decl_cnt;
}; 

class Decl_node
{
public:
    Decl_node(int data_type, SymbolTable *names);
    Node_type type = Node_type::DECL_NODE;
    int data_type;  // data type
    SymbolTable *names; // symbol table entries of the variables
    int var_count;  // number of entries in the "names" array
};

class Const_node
{
public:
    Const_node(int const_type, Val val);
    Node_type type = Node_type::CONST_NODE;
    int const_type; // data type
    Val val;        // constant value
};

// Statements

class Stmts_node
{
public:
    Stmts_node(Basic_node **stmts, int stmt_cnt);
    Node_type type = Node_type::STMTS;
    Basic_node **stmts;
    int stmt_cnt;
};

class If_node
{
public:
    If_node(Basic_node *cond, Basic_node *if_branch, Basic_node **elif_branches, Basic_node *else_branch, int cnt);
    Node_type type = Node_type::IF_NODE;
    Basic_node *cond; // condition
    Basic_node *if_branch;
    Basic_node **elif_branches;
    Basic_node *else_branch;
    int elif_count; // number of else if branches in "elif_branches" array
};

class Elif_node
{
public:
    Elif_node(Basic_node *cond, Basic_node *elif_branch);
    Node_type type = Node_type::ELIF_NODE;
    Basic_node *cond;
    Basic_node *elif_branch; // branch
};

class For_node
{
public:
    For_node(Basic_node *init, Basic_node *cond, Basic_node *inc, Basic_node *for_branch);
    Node_type type = Node_type::FOR_NODE;
    Basic_node *init; // initialization
    Basic_node *cond;
    Basic_node *inc; // increment or decrement
    Basic_node *for_branch;
};

class Assign_node
{
public:
    Assign_node(symbolEntry *entry, Basic_node *assign_val);
    Node_type type = Node_type::ASSIGN_NODE;
    symbolEntry *entry;          // symbol table entry
    Basic_node *assign_val; // assignment value
};

class Jump_node
{
public:
    Jump_node(int stmt_type);
    Node_type type = Node_type::JUMP_NODE;
    int stmt_type; // jump type: 0-continue, 1-break
};

class Inc_node
{
public:
    Inc_node(symbolEntry *entry, int inc_type, int pf_type);
    Node_type type = Node_type::INC_NODE;
    symbolEntry *entry; // identifier
    int inc_type;  // increment or decrement where 0: increment, 1: decrement
    int pf_type;   // postfix or prefix where 0: postfix, 1: prefix
};

class Func_call
{
public:
    Func_call(symbolEntry *entry, Basic_node **params, int param_cnt);
    Node_type type = Node_type::FUNC_CALL;
    symbolEntry *entry;       // function identifier
    Basic_node **params; // call parameters
    int param_count;     // number of parameters in "params" array
};

class Call_Params_node
{
public:
    Call_Params_node(Basic_node **params, int param_cnt);
    Node_type type = Node_type::CALL_PARAMS;
    Basic_node **params;
    int param_cnt;
};

// Expressions
class Arith_node
{
public:
    Arith_node(Arith_op op, Basic_node *left, Basic_node *right);
    Node_type type = Node_type::ARITH_NODE;
    Arith_op op; // operator
    Basic_node *left;
    Basic_node *right;
};

class Bool_node
{
public:
    Bool_node(Bool_op op, Basic_node *left, Basic_node *right);
    Node_type type = Node_type::BOOL_NODE;
    Bool_op op;
    Basic_node *left;
    Basic_node *right;
};

class Rel_node
{
public:
    Rel_node(Rel_op op, Basic_node *left, Basic_node *right);
    Node_type type = Node_type::REL_NODE;
    Rel_op op;
    Basic_node *left;
    Basic_node *right;
};

class Eq_node
{
public:
    Eq_node(Eq_op op, Basic_node *left, Basic_node *right);
    Node_type type = Node_type::EQ_NODE;
    Eq_op op;
    Basic_node *left;
    Basic_node *right;
};

// Functions

class Func_decls
{
public:
    Func_decls(Basic_node **func_decls, int func_decl_cnt);
    Node_type type = Node_type::FUNC_DECLS;
    Basic_node **func_decls;
    int func_decl_cnt;
};

class Func_decl
{
public:
    Func_decl(int ret_type, symbolEntry *entry, bool ptr, Basic_node *decls, Basic_node *stmts, Basic_node *return_node);
    Node_type type = Node_type::FUNC_DECL;
    int ret_type;  // return type
    symbolEntry *entry; // symbol table entry
    bool ptr; // 0: not ptr, 1: ptr
    Basic_node *decls;
    Basic_node *stmts;
    Basic_node *return_node;
};

class Return_type_node
{
public:
    Return_type_node(int ret_type, bool ptr);
    Node_type type = Node_type::RETURN_TYPE;
    int ret_type;
    bool ptr;
};

class Decl_Params_node
{
public:
    Decl_Params_node(symbolEntry* params, int param_cnt);
    Node_type type = Node_type::DECL_PARAMS;
    symbolEntry *params;
    int param_cnt;
};


class Return_node
{
public:
    Return_node(int ret_type, Basic_node *ret_val);
    Node_type type = Node_type::RETURN_NODE;
    int ret_type;
    Basic_node *ret_val; // return value
};
/****************** Node definitions ******************/

#endif