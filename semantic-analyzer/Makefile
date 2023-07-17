.PHONY: clean all 

all	:clean testing_parser
	bash bash.sh

lexer : lexer.l
	flex lexer.l

parser : parser.y
	bison -d -t parser.y

testing_parser: lexer parser
	g++ -o testing_parser.out lex.yy.c parser.tab.c

clean:
	rm -rf testing_parser.out
	rm -rf lex.yy.c
	rm -rf parser.tab.*
	rm -rf output/*.txt
	rm -rf output/*.cpp
	rm -rf output
	

	