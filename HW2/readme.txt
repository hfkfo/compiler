myparser.g 是由老師給的範例去進行修改及補充,將for和while迴圈、if-then-else以及printf處理好
testParser.java則是直接用老師給的範例
Makefile則因這次將ANTLR's jar file包含進去,只需要打java -cp antlr-3.5.3-complete-no-st3.jar org.antlr.Tool myparser.g和javac -cp antlr-3.5.3-complete-no-st3.jar:. testParser.java就行
