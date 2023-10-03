all:myparser.g
	java -cp antlr-3.5.3-complete-no-st3.jar org.antlr.Tool myparser.g 
	javac -cp antlr-3.5.3-complete-no-st3.jar:. testParser.java
clean:
	rm -f *class myparser.java myparser.tokens myparserParser.java myparserLexer.java


