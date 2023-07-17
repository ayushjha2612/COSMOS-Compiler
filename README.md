
# About

COSMOS is a statically typed programming language, and it serves as a scientific calculator for astronomical problems.
It aims at assisting people with no background in programming. The transpiler for cosmos converts the cosmos source program into their equivalent cpp programs which can further be run using g++

# Phase-1 Lexer
We made a lexical analyzer for COSMOS using flex tool.
The lexer directory contains file lexer.l which generates tokens for cosmos programs. The generated tokens are then directed to YACC for parsing. In order to test that we have generated correct tokens, we made several test cases in testCases directory. The test cases acts as input stream for the output file of test_lexer.l, which when encounters a token prints it in an output stream.
To see tokenization of our program:
1. Go to lexer directory.
2. Use make all command.
3. An output folder will be generated which contains tokens for all test cases in testCases.

# Phase-2 Parser
We made a parser for COSMOS using bison tool.
The parser directory contains file parser.y which defines grammar rules for cosmos programs. In order to test that we have defined correct rules, we made several test cases in testCases directory. The test cases acts as input stream for the output file of lexer and parser, which when checks for syntax correctness.
To see working of our parser:
1. Go to parser directory.
2. Use make all command.
3. An output folder will be generated which contains outputs for all test cases in testCases.

# Phase-3 Semantic-analyzer
We made a semantic-analyzer for COSMOS using cpp programs.
The semantic-analyzer directory contains file symbol table files symtab.h and symtab.cpp and semantics.h and semantics.cpp which check for semantic correctness of the cosmos programs. In order to test that the semantics are wworking fine, we made several test cases in testCases directory. The test cases acts as input stream for the output file of lexer and parser, which in turn using several helper functions checks for semantic correctness.
To see working of our parser:
1. Go to semantic-analyzer directory.
2. Use make all command.
3. An output folder will be generated which contains outputs for all test cases in testCases.


# Phase-4 code-generation
We made a code-generation (transpiler) for COSMOS using cpp programs.
The code-generation directory contains file codehen.h and codegen.cpp which check generate equivalent cpp programs for inputed cosmos programs by looking and analyzing rules of the grammar. In order to test that the transpiled cpp codes are wworking fine, we made several test cases in testCases directory. The test cases acts as input stream for the output file of lexer and parser, which in turn using several helper functions converts the source cosmos programs into their corresponding cpp programs, which can later be checked using g++.
To see working of our parser:
1. Go to code-generation directory.
2. Use make all command.
3. An output folder will be generated which contains outputs for all test cases in testCases.

## Team Members

1. [Avula Dinesh](https://github.com/DineshAvulaMohanaDurga)

2. [Ayush Jha](https://github.com/ayushjha2612)

3. [Yuvraj Singh Shekhawat](https://github.com/yuvrajshekhawat1989)

4. [Rohan Atkurkar](https://github.com/Rohan673)

5. [Shashank Shanbag](https://github.com/SHASHANK-1-ALL)

