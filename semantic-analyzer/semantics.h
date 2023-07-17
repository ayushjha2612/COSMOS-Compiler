#ifndef SEMANTICS_H
#define SEMANTICS_H

#include "symtab.h"
#include "symtab.cpp"

set<string> snDtypes = {"DIST", "LY", "AU", "MASS", "SOLAR_MASS", "DENSITY", "TIME", "SPEED", "ACC", "ENERGY", "FORCE", "FREQ", "PARSEC", "TEMP", "ARCSEC"};
ofstream errorfile;
ofstream logfile;
extern int lineno;

string upper(string s);
SymbolTable symboltable;

bool hasReturn = false;
bool isexpr = false;
bool isParam = false;
bool isArg = false;

string funcName;
string ReturnType;
list<pair<string, string>> paramList; // Contains the parameter list <name, type> of the currently declared function
list<pair<string, string>> argList;   // Contans argument list while calling a function
string paramType;
string paramName;

string idenType; // Contains recent variable type
string idenName;
string constType;
list<string> multIden;

string exprName;
string exprfuncName;
string exprType;
pair<string, string> exprTerms;
list<string> assignTypes;
string logicalLhs;
string logicalRhs;

string typeConst(string type);
extern void printError(string error, bool iswarn);
void handleIdentifierExpression(string idname);
void handleFunctionCall(bool hasZeroArgs);
void handleArithExpr(string opr);
void handleAssignExpr();
void handleIdentDecl();
void handleInitialization();
void handleTypes(string type);
void handleIdent(string name);
void handleExprStmt();
void handleFunctionDefinition(string rType);
void handleReturnStmt();
void checkUnusedVars();
void handleConstExpr();
void handleFuncDeclaration(bool hasZeroParams);
void handleLogicalExpr(string opr);
void handleAndOr(string opr);
#endif