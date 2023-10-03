all:mylexer.g
	java -cp antlr-3.5.3-complete-no-st3.jar org.antlr.Tool mylexer.g 
	javac -cp ./antlr-3.5.3-complete-no-st3.jar testLexer.java mylexer.java
clean:
	rm -f *class mylexer.java mylexer.tokens


