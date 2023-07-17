all	: testing_lexer
	mkdir -p Output && touch Output/test1.txt
	./testing_lexer < testCases/test1.cos > Output/test1.txt
	
	touch Output/test2.txt
	./testing_lexer < testCases/test2.cos > Output/test2.txt
	
	touch Output/test3.txt
	./testing_lexer < testCases/test3.cos > Output/test3.txt
	
	touch Output/test4.txt
	./testing_lexer < testCases/test4.cos > Output/test4.txt
	
	touch Output/test5.txt
	./testing_lexer < testCases/test5.cos > Output/test5.txt

lex.yy.c: test_lexer.l
	flex test_lexer.l

testing_lexer: lex.yy.c
	gcc -o testing_lexer lex.yy.c

clean:
	rm -rf testing_lexer
	rm -rf lex.yy.c
	rm -rf Output/*.txt
	rm -rf Output
