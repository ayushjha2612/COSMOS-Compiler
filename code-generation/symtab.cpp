// C++ program to implement Symbol Table
#ifndef SYMTAB_CPP
#define SYMTAB_CPP

#include "symtab.h"

bool localTable::insert(string _name, string _datatype, SymbolType _symType)
{
    if (table.find(_name) == table.end())
    {

        symbolEntry SE(_name, _datatype, _symType);
        table.insert({_name, SE}); // map insert
        return true;
    }
    else
    {
        return false;
    }
}

symbolEntry *localTable::search(string _name)
{
    if (table.find(_name) != table.end())
    {
        symbolEntry *S = &table[_name];
        S->isUsed = true;
        return S;
    }
    else
    {
        return NULL;
    }
}

bool localTable::Delete(string _name)
{
    if (table.find(_name) != table.end())
    {
        table.erase(_name);
        return true;
    }
    else
    {
        return false;
    }
}
string convert(SymbolType s)
{
    if (s == IDENT)
        return "IDENT";
    else if (s == FUNCTION)
        return "FUNCTION";
    else if (s == STRUCT_IDENT)
        return "STRUCT_IDENT";
    else
        return "UNDEF";
}
void symbolEntry::print()
{
    cout << name << "  " << dataType << "   " << convert(symType) << "\n";
}
void localTable::printTable()
{
    cout << " --- SYMBOL TABLE ---\n\n";
    cout << "NAME   "
         << "DATATYPE   "
         << "ENTRY_TYPE  "
         << "\n\n ";

    for (auto &s : table)
    {
        s.second.print();
    }
}

bool SymbolTable::insert(string _name, string _datatype, SymbolType _symType, string scope = "GLOBAL")
{
    if (scope == "GLOBAL")
    {
        bool result = GlobalTable.insert(_name, _datatype, _symType);
        if (_symType == FUNCTION)
        {
            localTable L;
            functables.insert({_name, L});
        }
        // if (result)
        // cout << "INSERTED " << _name << " type : " << convert(_symType) << " scope : " << scope << "\n";
        return result;
    }
    else
    {
        if (functables.find(scope) == functables.end())
        {
            cout << "Error no such function " << scope << "\n";
            return false;
        }
        else
        {
            localTable *Ftable = &functables[scope];
            bool result = Ftable->insert(_name, _datatype, _symType);
            // if (result)
            //     // cout << "INSERTED " << _name << " type : " << convert(_symType) << " scope : " << scope << "\n";
            //     else
            //         //  cout << "FAILED " << _name << " type : " << convert(_symType) << " scope : " << scope << "\n";

            return result;
        }
    }
}

symbolEntry *SymbolTable::search(string _name, string scope = "GLOBAL")
{
    if (scope == "GLOBAL")
    {
        symbolEntry *S = GlobalTable.search(_name);
        return S;
    }
    else
    {
        if (functables.find(scope) == functables.end())
        {
            cout << "Error no such function " << scope << "\n";
            return NULL;
        }
        else
        {

            localTable *Ftable = &functables[scope];
            symbolEntry *S = Ftable->search(_name);
            if (S == NULL)
            {
                symbolEntry *SM = GlobalTable.search(_name);
                return SM;
            }
            return S;
        }
    }
}
bool SymbolTable::isFunction(string _name)
{
    symbolEntry *S = GlobalTable.search(_name);
    if (S != NULL && S->symType == FUNCTION)
    {
        return true;
    }
    else
    {
        return false;
    }
}
bool SymbolTable::Delete(string _name, string scope = "GLOBAL")
{
    if (scope == "GLOBAL")
    {
        symbolEntry *S = search(_name);
        if (S->symType == FUNCTION)
        {
            if (functables.find(_name) != functables.end())
            {
                functables.erase(_name);
            }
        }
        bool result = GlobalTable.Delete(_name);
        return result;
    }
    else
    {
        if (functables.find(scope) == functables.end())
        {
            cout << "Error no such function " << scope << "\n";
            return false;
        }
        else
        {
            localTable *Ftable = &functables[scope];
            bool result = Ftable->Delete(_name);
            return result;
        }
    }
}
void SymbolTable::printTable(string scope = "GLOBAL")
{
    if (scope == "GLOBAL")
    {
        GlobalTable.printTable();
    }
    else
    {
        if (functables.find(scope) == functables.end())
        {
            cout << "Error no such function " << scope << "\n";
        }
        else
        {
            localTable Ftable = functables[scope];
            Ftable.printTable();
        }
    }
}

// int main()
//  {
//      SymbolTable st;
//      st.insert("main", "int", FUNCTION);
//      st.insert("nut", "bool", FUNCTION);
//      st.insert("ff", "string", FUNCTION);
//      st.insert("a", "int", IDENT, "main");

//     symbolEntry *S = st.search("a", "main");

//     if (S == NULL)
//         cout << "Null\n";
//     else
//         cout << "Found\n";

//     // st.Delete("foo");

//     // st.printTable();
//     // st.printTable("main");
//     // cout << st.functables.size() << endl;
//     return 0;
// }

#endif