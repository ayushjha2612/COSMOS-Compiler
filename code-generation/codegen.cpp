// C++ program to implement code generation
#ifndef CODEGEN_CPP
#define CODEGEN_CPP
#include "codegen.h"

void beginCodeGen()
{
    genfile << " /* Generated file from COSMOS Compiler  */ \n\n"
            << "#include\"scinum.h\"\n";
    genfile << endl;
}

string lowerStr(string s)
{
    string tempStr = "";

    for (int i = 0; i < s.length(); i++)
    {
        char c = s[i];
        if (c >= 'A' && c <= 'Z')
            tempStr.push_back(c + 'a' - 'A');
        else
            tempStr.push_back(c);
    }

    return tempStr;
}

string genCodeTypes(string type)
{
    if (typeConst(type) == "SN")
    {
        return "SN";
    }
    else
    {
        return lowerStr(type);
    }
}
string getCode(int line)
{
    inputfile.seekg(ios::beg);
    string out;
    int i = 1;
    while (getline(inputfile, out))
    {
        if (i == line)
        {
            return out;
        }
        i++;
    }
    out.clear();
    return out;
}

void genCodeFuncDecl(int line)
{
    string code = getCode(line);
    int ind = code.find("proc");

    if (ind != code.npos)
    {
        code.erase(ind, 5);
    }
    genfile << code << endl;
}
int genCodeConst(string val)
{
    if (funcName != "")
    {
        genfile << "\t";
    }

    int ind = val.find("e");
    float num = stof(val.substr(0, ind));
    short int pow = stoi(val.substr(ind + 1));

    genfile << "\tSN C" << to_string(num_const) << " = { " << num << ", " << pow << "};\n";
    num_const++;
    return num_const - 1;
}
string cleanseStr(string code)
{
    while (!constants.empty())
    {
        string cons = constants.front();
        if (code.find(cons) == code.npos)
            break;
        else
        {
            string var = "C"+to_string(genCodeConst(cons));
            int ind = code.find(cons);
            code.erase(ind, cons.size());
            code.insert(ind, var.size(), 'C');
            for (int i = 0; i < var.size(); i++)
            {
                code[ind + i] = var[i];
            }
            constants.pop();
        }
    }

    if (code.find("repeat") != code.npos)
    {
        int ind = code.find("repeat");
        code.erase(ind, 6);
        code.insert(ind, 3, 'f');
        code[ind + 1] = 'o';
        code[ind + 2] = 'r';
    }
    return code;
}

void genCodeFuncDefinition(int start, int end, bool isFunction = true)
{
    for (int i = start; i <= end; i++)
    {

        string code = getCode(i);
        code = cleanseStr(code);
        code = genCodeIO(code);
        genfile << code << endl;
    }
    // symbolEntry *S = symboltable.search("sss", funcName);
    // if (S != NULL)
    // {
    //     cout << "Data : " << S->dataType << "\n";
    // }
}
void genCodeStruct(int start, int end)
{
    for (int i = start; i <= end; i++)
    {
        string code = getCode(i);
        genfile << code << endl;
    }
}
string genCodeIO(string code)
{
    if (code.find("input") != code.npos)
    {
        string iden = inputs.front();
        inputs.pop();
        // cout << "iden : " << iden << "\n";
        symbolEntry *S = symboltable.search(iden, funcName);
        if (S != NULL)
        {
            string dtype = genCodeTypes(S->dataType);
            code.clear();
            if (dtype == "SN")
            {
                code += "\tstring temp_" + to_string(num_ins) + ";\n\tcin >> temp_" + to_string(num_ins) + ";\n\t";
                code += "initSN( " + iden + ", temp_" + to_string(num_ins) + ");";
                num_ins++;
            }
            else
            {
                code += "\tcin >> " + iden + ";\n";
            }
            return code;
        }
    }
    else if (code.find("output") != code.npos)
    {
        string iden = outputs.front();
        outputs.pop();
        if (iden == "CONST")
        {
            int ind1 = code.find("(");
            int ind2 = code.find(")");

            string msg = code.substr(ind1 + 1, ind2 - ind1 - 1);
            code.clear();
            code += "\tcout << " + msg + ";\n";
        }
        else
        {
            symbolEntry *S = symboltable.search(iden, funcName);
            if (S != NULL)
            {
                string dtype = genCodeTypes(S->dataType);
                code.clear();
                if (dtype == "SN")
                {
                    code += "\tcout << " + iden + ".print();\n";
                }
                else
                {
                    code += "\tcout << " + iden + ";\n";
                }
                return code;
            }
        }
    }
    return code;
}
// int main()
// {

//     return 0;
// }
#endif