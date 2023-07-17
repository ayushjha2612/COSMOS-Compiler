.PHONY: clean test all 

all	: testing_parser generate
	bash bash.sh

test : testing_parser
	mkdir -p Output && touch Output/test1.txt
	./testing_parser < testCases/test1.cos

gentest : testing_parser generate
	mkdir -p Output && touch Output/gentest1.txt
	./testing_parser < genTestCases/test1.cos

generate : generator.cpp 
	g++ -o generator generator.cpp 
	mkdir genTestCases
	./generator

lexer : lexer.l
	flex lexer.l

parser : parser.y
	yacc -d parser.y

testing_parser: lexer parser
	gcc -o testing_parser lex.yy.c y.tab.c

clean:
	rm -rf testing_parser
	rm -rf lex.yy.c
	rm -rf y.tab.*
	rm -rf output
	rm -rf genTestCases
	rm -rf generator
	rm -rf parser.tab.*