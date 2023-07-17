// C++ program to implement semantics
#ifndef SEMANTICS_CPP
#define SEMANTICS_CPP
#include "semantics.h"

string upper(string s)
{
    string tempStr = "";

    for (int i = 0; i < s.length(); i++)
    {
        char c = s[i];
        if (c >= 'a' && c <= 'z')
            tempStr.push_back(c - 'a' + 'A');
        else
            tempStr.push_back(c);
    }

    return tempStr;
}
string typeConst(string type)
{
    if (snDtypes.find(type) != snDtypes.end())
    {
        return "SN";
    }
    else
        return type;
}
void handleIdentifierExpression(string idname)
{
    string scope;
    if (funcName == "")
        scope = "GLOBAL";
    else
        scope = funcName;
    symbolEntry *S = symboltable.search(idname, scope);
    if (S == NULL)
    {
        printError("Undeclared variable used name- " + idname, false);
    }
    else
    {
        bool flag = symboltable.isFunction(idname);
        if (!isArg)
            exprType = typeConst(S->dataType);
        if (flag)
        {
            isArg = true;
            exprfuncName = idname;
        }

        if (isArg && !flag)
        {
            string type = typeConst(S->dataType);
            argList.push_back({idname, type});
        }
        if (!isexpr && !isArg)
        {
            exprName = idname;
            isexpr = true;
        }
    }
}

void handleFunctionCall(bool hasZeroArgs = false)
{
    isArg = false;
    symbolEntry *S = symboltable.search(exprfuncName, "GLOBAL");

    if (S == NULL)
    {
        printError("Function is not declared yet", false);
    }
    else
    {
        if (S->symType == FUNCTION)
        {
            
            if (argList.size() != S->arglist.size())
            {
                printError("Argument numbers do not match for " +S->name +" expected " + to_string(argList.size()) + " arguments but got " + to_string(S->arglist.size()), false);
            }
            if (!hasZeroArgs)
            {
                vector<string> expTypes;
                vector<string> actTypes;
                for (auto &s : argList)
                {
                    expTypes.push_back(s.second);
                }
                for (auto &s : S->arglist)
                {
                    actTypes.push_back(typeConst(s.second));
                }
                int index = min(expTypes.size(), actTypes.size());
                for (int i = 0; i < index; i++)
                {
                    if (expTypes[i] != actTypes[i])
                    {
                        printError("Argument " + to_string(i + 1) + " type does not match expected " + expTypes[i] + " but got " + actTypes[i], false);
                    }
                }
            }
        }
        else
        {
            printError(exprName + " is not a function", false);
        }
    }
    argList.clear();
}
void handleArithExpr(string opr = "")
{
    if (opr == "")
    {
        if (exprTerms.first == "" && !isArg)
        {
            exprTerms.first = exprType;
            isexpr = true;
        }
    }
    else
    {
        exprTerms.second = exprType;
        if (exprTerms.first == exprTerms.second && exprTerms.second == "SN")
        {
            exprTerms.second.clear();
        }
        else
        {
            printError("Invalid operand types- " + exprTerms.first + " and " + exprTerms.second +
                           "  for opertaor " + opr,
                       false);
            exprTerms.second.clear();
            exprTerms.first = "INVALID";
        }
    }
}
void handleLogicalExpr(string opr)
{
    exprTerms.second = exprType;
    if (exprTerms.first == exprTerms.second)
    {
        exprTerms.second.clear();
        if (logicalLhs == "")
            logicalLhs = "BOOL";
        else
            logicalRhs = "BOOL";
        exprTerms.first.clear();
        exprType.clear();
    }
    else
    {
        printError("Invalid operand types- " + exprTerms.first + " and " + exprTerms.second +
                       "  for opertaor " + opr,
                   false);
        exprTerms.second.clear();
        exprTerms.first.clear();
        if (logicalLhs == "")
            logicalLhs = "INVALID";
        else
            logicalRhs = "INVALID";

        exprType.clear();
    }
}
void handleAndOr(string opr)
{
    if (logicalLhs == logicalRhs && logicalRhs == "BOOL")
    {
        logicalRhs.clear();
    }
    else
    {
        printError("Invalid operand types- " + logicalLhs + " and " + logicalRhs +
                       "  for opertaor " + opr,
                   false);
        logicalLhs = "BOOL";
    }
}
void handleAssignExpr()
{
    symbolEntry *S = symboltable.search(exprName, funcName);
    if (S == NULL)
    {
        // cout << "Problem in assignment_expression\n";
    }
    else
    {
        exprType = typeConst(S->dataType);
        if (exprType != exprTerms.first)
        {
            printError("Invalid assignment types for " + exprName + " with " + exprType + " and " + exprTerms.first, false);
        }
    }
}
void handleConstExpr()
{
    if (isArg)
    {
        argList.push_back({"CONST", constType});
    }
    else
    {
        exprType = constType;
    }
}
void handleIdentDecl()
{
    string scope = funcName;
    if (funcName == "")
    {
        scope = "GLOBAL";
    }
    if (idenType == "VOID")
    {
        printError("Variable cannot be of type void", false);
    }
    bool flag = symboltable.insert(idenName, idenType, IDENT, scope);
    if (flag == false)
    {
        printError("Redeclaration of " + idenName, false);
    }
    for (string &s : multIden)
    {
        bool flag = symboltable.insert(s, idenType, IDENT, funcName);
        if (flag == false)
        {
            printError("Redeclaration of " + s, false);
        }
    }

    idenType.clear();
    idenName.clear();
    multIden.clear();
}
void handleInitialization()
{
    if (constType != typeConst(idenType))
    {
        printError("Types do not match on both sides of assignment RHS expected " + idenType + " but got " + constType, false);
    }
}
void handleTypes(string type)
{
    if (idenType != "")
    {
        if (type == "VOID")
        {
            printError("Declaring argument of type void", false);
        }
        isParam = true;
        paramType = type;
    }
    else
    {
        idenType = type;
    }
}
void handleIdent(string name)
{
    if (idenName == "")
        idenName = name;
    else
    {
        if (!isParam)
            multIden.push_back(name);
        else
        {
            paramName = name;
        }
    }
}
void handleExprStmt()
{
    exprName.clear();
    exprType.clear();
    isexpr = false;
    exprTerms.first.clear();
    exprTerms.second.clear();
}
void handleFunctionDefinition(string rType)
{
    symbolEntry *S = symboltable.search(funcName);
    if (S == NULL)
    {
        cout << " function_definition problem\n";
    }
    else
    {
        S->isdefined = true;

        if (rType != ReturnType)
            printError(" Return type problem of " + funcName, false);
    }
    if (!hasReturn && ReturnType != "VOID")
    {
        printError("No return found in " + funcName + " expected " + ReturnType, false);
    }
    ReturnType.clear();
    funcName.clear();
    hasReturn = false;
}

void handleReturnStmt()
{

    if (typeConst(ReturnType) != exprTerms.first)
    {
        printError("Function return type - " + exprTerms.first + " does not match with declaration " + ReturnType, false);
    }
    if (ReturnType == "VOID")
    {
        printError("Returning in a void function", false);
    }
    handleExprStmt();
    hasReturn = true;
}
void handleFuncDeclaration(bool hasZeroParams = false)
{
    funcName = idenName;
    ReturnType = idenType;
    bool flag = symboltable.insert(funcName, ReturnType, FUNCTION, "GLOBAL");
    if (flag == false)
    {
        printError(" Redeclaration of " + funcName, false);
    }
    if (!hasZeroParams)
    {
        symbolEntry *S = symboltable.search(funcName);
        if (S == NULL)
        {
            cout << "Problem in declarator\n";
        }
        else
        {
            S->arglist = paramList;
        }
        for (auto &p : paramList)
        {
            bool flag2 = symboltable.insert(p.first, p.second, IDENT, funcName);
            if (flag2 == false)
            {
                printError(" Redeclaration of " + p.first + " in parameters of " + funcName, false);
            }
        }
    }
    idenType.clear();
    idenName.clear();
    paramList.clear();
    isParam = false;
}

void checkUnusedVars()
{
    for (auto &a : symboltable.GlobalTable.table)
    {
        if (!a.second.isUsed)
        {
            printError("Variable " + a.first + " declared in global scope but not used", true);
        }
    }
    for (auto &b : symboltable.functables)
    {
        for (auto &c : b.second.table)
        {
            if (!c.second.isUsed)
            {
                printError("Variable " + c.first + " declared in " + b.first + " but not used", true);
            }
        }
    }
}
// int main()
// {
//     return 0;
// }

#endif