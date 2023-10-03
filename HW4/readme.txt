myCompiler.g 除了老師要求的基本功能外,我還做了 Nested if construct、For-loop construct/ while-loop construct和Loop construct + if construct
myCompiler_test.java則是直接用老師給的範例
Makefile則因這次將ANTLR's jar file包含進去,只需要打java -cp antlr-3.5.3-complete-no-st3.jar org.antlr.Tool myCompiler.g和javac -cp antlr-3.5.3-complete-no-st3.jar *.java就行
