#ifndef CODEGEN_H
#define CODEGEN_H

#include "semantics.h"
#include "semantics.cpp"

ofstream genfile;
ifstream inputfile;
string gfile;
int num_ins = 1;

string lowerStr(string s);
string genCodeTypes(string type);
void beginCodeGen();
string getCode(int line);
void genCodeFuncDecl(int line);
int genCodeConst(string val);
string cleanseStr(string code);
void genCodeFuncDefinition(int start, int end, bool isFunction);
void genCodeStruct(int start, int end);
string genCodeIO(string code);
#endif