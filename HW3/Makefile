all:myChecker.g
	java -cp antlr-3.5.3-complete-no-st3.jar org.antlr.Tool myChecker.g
	javac -cp antlr-3.5.3-complete-no-st3.jar:. myChecker_test.java
clean:
	rm -f *class myCheckerLexer.java myCheckerParser.java myChecker.tokens


