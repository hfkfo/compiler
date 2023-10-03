myChecker.g 是拿老師的範例和我的project2合在一起,基本上沒新增新的東西
myChecker_test.java則是直接用老師給的範例
Makefile則因這次將ANTLR's jar file包含進去,只需要打java -cp antlr-3.5.3-complete-no-st3.jar org.antlr.Tool myChecker.g和javac -cp antlr-3.5.3-complete-no-st3.jar:. myChecker_test.java就行
