#ifndef SYMTAB_H
#define SYMTAB_H

#include <string>
#include <list>
#include <vector>
#include <map>
#include <iostream>
#include <fstream>
#include <set>
using namespace std;

class syntax_tree_node
{
public:
    string name;
    string type;

    syntax_tree_node(){};
    syntax_tree_node(string _name, string _type)
    {
        name = _name;
        type = _type;
    }
};
enum SymbolType
{
    IDENT,
    FUNCTION,
    STRUCT_IDENT,
    UNDEF
};

class symbolEntry
{
public:
    string name;
    string dataType;
    SymbolType symType;
    bool isUsed;

    // For functions
    bool isdefined;
    list<pair<string, string>> arglist;

    symbolEntry(){};
    symbolEntry(string _name, string _type, SymbolType _symType)
    {
        name = _name;
        dataType = _type;
        symType = _symType;
        isdefined = false;
        isUsed = false;
    }
    void print();
};

// Restricted to a function
class localTable
{
public:
    map<string, symbolEntry> table;
    localTable(){};

    bool insert(string _name, string datatype, SymbolType _symType);
    symbolEntry *search(string _name);
    bool Delete(string _name);
    // bool modify(string _name, string _dtype, int _line_no);
    void printTable();
};

class SymbolTable
{
public:
    localTable GlobalTable;
    map<string, localTable> functables;

    bool insert(string _name, string _datatype, SymbolType _symType, string scope);
    symbolEntry *search(string _name, string scope);
    bool Delete(string _name, string scope);
    // bool modify(string _name, string _dtype, int _line_no);
    void printTable(string scope);
    bool isFunction(string _name);
};
#endif