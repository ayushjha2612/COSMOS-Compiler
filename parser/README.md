
# How to use

## Manually run the parser
    Use the following commands
        flex lexer.l
    	yacc -d parser.y
        gcc -o testing_parser lex.yy.c y.tab.c -lfl
        ./testing_parser < input_filepath


## Run a test case
    Use the command make test

## Run all test cases
    Use the command make all

# Error message

The parser will give a error message consisting of a line number which will be the line number of the next token where syntax error occured

