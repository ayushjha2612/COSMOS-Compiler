#include <bits/stdc++.h>
#include <experimental/random>
using namespace std;
#define REP(i) for (unsigned j = 1; j <= i; j++)

#define N 30
#define right_prob prob(99, 100)
ofstream fout;
bool prob(int a, int b);
void if_rand(vector<string> &dtypes, int i, bool loop);
void rand_loop(vector<string> &dtypes, int i);
string ident();
string sci_num();
void vars_calc(vector<string> &dtypes, int i);
void break_continue(bool loop, int i);

void break_continue(bool loop, int i)
{
    if (prob(1, 2) && loop)
    {
        if (prob(1, 2))
        {
            REP(i + 1)
            fout << "\t";
            fout << "break ;\n";
        }
        else
        {
            REP(i + 1)
            fout << "\t";
            fout << "continue;\n ";
        }
    }
}

void vars_calc(vector<string> &dtypes, int i)
{
    vector<string> ops = {"+", "-", "*", "/", "%", "^"};
    int randi = std::experimental::randint(3, int(dtypes.size()) - 1);
    REP(i)
    fout << "\t";
    fout << dtypes[randi] << " ";
    if (right_prob)
        fout << ident() << " ";

    if (prob(6, 10))
    {
        if (right_prob)
            fout << " = ";
        if (right_prob)
            fout << sci_num();
        int rndi = std::experimental::randint(0, int(ops.size()) - 1);
        if (right_prob)
            fout << " " << ops[rndi] << " ";
        if (right_prob)
            fout << sci_num();
    }
    else if (prob(5, 10))
    {
        if (right_prob)
            fout << "= ";
        if (right_prob)
            fout << sci_num();
    }

    fout << ";\n";
}

bool prob(int a, int b)
{
    int randi = std::experimental::randint(1, b);
    if (randi <= a)
        return true;
    else
        return false;
}
void if_rand(vector<string> &dtypes, int i, bool loop)
{
    fout << "\n";
    int randi = std::experimental::randint(2, int(dtypes.size()) - 1);
    string str1 = ident(), str2 = ident();
    vector<string> ops = {" == ", " != ", " <= ", " >= ", " < ", " > "};
    int j = std::experimental::randint(0, int(ops.size()) - 1);

    REP(i)
    fout << "\t";
    fout << dtypes[randi] << " " << str1 << " = " << sci_num() << " ," << str2 << "= " << sci_num() << " ;\n";

    if (right_prob)
    {
        REP(i)
        fout << "\t";
        fout << "if( ";
        if (right_prob)
            fout << str1 << ops[j] << str2;
        fout << " )\n";
        REP(i)
        fout << "\t";
        fout << "{\n";
        vars_calc(dtypes, i + 1);

        break_continue(loop, i);
        REP(i)
        fout << "\t";
        fout << "}\n";
    }

    j = std::experimental::randint(0, int(ops.size()) - 1);

    if (prob(5, 10))
    {
        REP(i)
        fout << "\t";
        fout << "else if( ";
        if (right_prob)
            fout << str1 << ops[j] << str2;
        fout << " )\n";
        REP(i)
        fout << "\t";
        fout << "{\n";
        vars_calc(dtypes, i + 1);

        break_continue(loop, i);

        REP(i)
        fout << "\t";
        fout << "}\n";
    }

    if (prob(6, 10))
    {
        REP(i)
        fout << "\t";
        fout << "else \n";
        REP(i)
        fout << "\t";
        fout << "{\n";
        vars_calc(dtypes, i + 1);

        break_continue(loop, i);
        REP(i)
        fout << "\t";
        fout << "}\n";
    }
    fout << "\n";
}
void rand_loop(vector<string> &dtypes, int i)
{
    fout << "\n";
    REP(i)
    fout << "\t";
    vector<string> ops = {" == ", " != ", " <= ", " >= ", " < ", " > "};
    vector<string> ops2 = {" ++ ", " -- "};
    int j = std::experimental::randint(0, int(ops.size()) - 1);

    fout << "repeat (";
    if (right_prob)
    {
        fout << " int ";
        char c = std::experimental::randint(97, 122);
        fout << c << " = " << std::experimental::randint(0, 10) << "; " << c << ops[j] << std::experimental::randint(0, 100);
        fout << " ; " << c;
        int a = std::experimental::randint(0, 1);
        fout << ops2[a];
    }

    fout << ")\n";
    REP(i)
    fout << "\t";
    fout << "{\n";

    int loop = std::experimental::randint(1, 3);
    for (int ll = 0; ll < loop; ll++)
    {
        if (prob(7, 10))
            vars_calc(dtypes, i + 1);
        else
            if_rand(dtypes, i + 1, true);
    }
    REP(i)
    fout << "\t";
    fout << "}\n";
}
string ident()
{
    int sz = std::experimental::randint(3, 8);
    string iden;
    for (int i = 0; i < sz; i++)
    {
        int ch = std::experimental::randint(65, 122);
        if (ch <= 96 && ch >= 91)
            iden.push_back('_');
        else
        {
            char c = ch;
            iden.push_back(c);
        }
    }
    return iden;
}
string sci_num()
{
    string sn;
    int dec = std::experimental::randint(-9, 9);
    if (right_prob)
        sn += to_string(dec);
    if (right_prob)
        sn.push_back('.');
    int frac = std::experimental::randint(0, 999999);
    if (right_prob)
        sn += to_string(frac);
    if (right_prob)
        sn.push_back('e');
    int exp = std::experimental::randint(-100, 100);
    sn += to_string(exp);

    return sn;
}
int main()
{
    srand(time(0));
    vector<string> dtypes = {"int", "bool", "string", "mass", "density", "dist", "time", "speed", "acc", "energy", "force", "freq", "ly", "AU", "solar_mass", "parsec", "temp", "arcsec"};

    for (int i = 0; i < N; i++)
    {
        fout.open("genTestCases/test" + to_string(1 + i) + ".cos");
        if (prob(7, 10))
        {
            fout << "struct " << ident() << "\n{\n";
            int n = std::experimental::randint(1, 15);
            for (unsigned i = 0; i < n; i++)
            {
                int j = std::experimental::randint(0, int(dtypes.size()) - 1);
                fout << "\t" << dtypes[j] << " " << ident() << ";\n";
            }
            fout << "};\n\n";
        }

        fout << "proc int main()\n{\n";
        int lines = std::experimental::randint(15, 30);
        for (int j = 0; j < lines; j++)
        {
            if (prob(8, 10))
            {
                vars_calc(dtypes, 1);
            }
            else if (prob(1, 2))
            {
                if_rand(dtypes, 1, false);
            }
            else
            {
                rand_loop(dtypes, 1);
            }
        }

        fout << "\treturn 0;\n}";
        fout.close();
    }

    return 0;
}