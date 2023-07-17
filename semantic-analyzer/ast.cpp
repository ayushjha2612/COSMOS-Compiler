#include "ast.h"

/****************** Node definitions ******************/
Basic_node::Basic_node(Node_type type, Basic_node *left, Basic_node *right): type(type), left(left), right(right) {}

// Declarations
Decls_node::Decls_node(Basic_node **decls, int decl_cnt): decls(decls), decl_cnt(decl_cnt) {}

Decl_node::Decl_node(int data_type, SymbolTable *names): data_type(data_type), names(names) {}

Const_node::Const_node(int const_type, Val val): const_type(const_type), val(val) {}

// Statements
Stmts_node::Stmts_node(Basic_node **stmts, int stmt_cnt): stmts(stmts), stmt_cnt(stmt_cnt) {}

If_node::If_node(Basic_node *cond, Basic_node *if_branch, Basic_node **elif_branches, Basic_node *else_branch, int cnt): cond(cond), if_branch(if_branch), elif_branches(elif_branches), else_branch(else_branch), elif_count(cnt) {}

Elif_node::Elif_node(Basic_node *cond, Basic_node *elif_branch): cond(cond), elif_branch(elif_branch) {}

For_node::For_node(Basic_node *init, Basic_node *cond, Basic_node *inc, Basic_node *for_branch): init(init), cond(cond), inc(inc), for_branch(for_branch) {}

Assign_node::Assign_node(symbolEntry *entry, Basic_node *assign_val): entry(entry), assign_val(assign_val) {}

Jump_node::Jump_node(int stmt_type): stmt_type(stmt_type) {}

Inc_node::Inc_node(symbolEntry *entry,int inc_type, int pf_type): entry(entry), inc_type(inc_type), pf_type(pf_type) {}

Func_call::Func_call(symbolEntry *entry, Basic_node **params, int param_cnt): entry(entry), params(params), param_count(param_cnt) {}

Call_Params_node::Call_Params_node(Basic_node **params, int param_cnt): params(params), param_cnt(param_cnt) {}

Arith_node::Arith_node(Arith_op op, Basic_node *left, Basic_node *right): op(op), left(left), right(right) {}

Bool_node::Bool_node(Bool_op op, Basic_node *left, Basic_node *right): op(op), left(left), right(right) {}

Rel_node::Rel_node(Rel_op op, Basic_node *left, Basic_node *right): op(op), left(left), right(right) {}

Eq_node::Eq_node(Eq_op op, Basic_node *left, Basic_node *right): op(op), left(left), right(right) {}

// Functions
Func_decls::Func_decls(Basic_node **func_decls, int func_decl_cnt): func_decls(func_decls), func_decl_cnt(func_decl_cnt) {}

Func_decl::Func_decl(int ret_type, symbolEntry *entry, bool ptr, Basic_node *decls, Basic_node *stmts, Basic_node *return_node): ret_type(ret_type), entry(entry), ptr(ptr), decls(decls), stmts(stmts), return_node(return_node) {}

Return_type_node::Return_type_node(int ret_type, bool ptr): ret_type(ret_type), ptr(ptr) {}

Decl_Params_node::Decl_Params_node(symbolEntry* params, int param_cnt): params(params), param_cnt(param_cnt) {}

Return_node::Return_node(int ret_type, Basic_node *ret_val): ret_type(ret_type), ret_val(ret_val) {}
/****************** Node definitions ******************/

/*SN Datatype*/
sn::sn(int front = 0, int back = 0, int power = 0): front(front), back(back), power(power) {}