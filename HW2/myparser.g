grammar myparser;

options {
   language = Java;
}

@header {
    // import packages here.
}

@members {
    boolean TRACEON = true;
}
program:('#' INCLUDE FILE)+ VOID MAIN '(' ')' '{' declarations statements '}'
        {if (TRACEON) System.out.println("program:('#' INCLUDE FILE)+ VOID MAIN () {declarations statements}");};

declarations:type Identifier ';' declarations
             { if (TRACEON) System.out.println("declarations: type Identifier ; declarations"); }
           | { if (TRACEON) System.out.println("declarations: ");} ;

type:INT { if (TRACEON) System.out.println("type: INT"); }
   | FLOAT {if (TRACEON) System.out.println("type: FLOAT"); }
   | DOUBLE {if (TRACEON) System.out.println("type: DOUBLE"); }
   | LONG {if (TRACEON) System.out.println("type: LONG"); }
   | CHAR {if (TRACEON) System.out.println("type: CHAR"); };
	
statements:statement statements {if (TRACEON) System.out.println("statements: statement statements");}
        |;

arith_expression: multExpr
                  ( '+' multExpr
				  | '-' multExpr
				  )*
                  {if (TRACEON) System.out.println("arith_expression: multExpr(+ multExpr | - multExpr)*");};
logic_expression: Identifier logic_sign (Identifier|Integer_constant) logic_and_or_sign {if (TRACEON) System.out.println("logic_expression: Identifier logic_sign (Identifier|Integer_constant) logic_and_or_sign");}; 
logic_and_or_sign: LOGIC_AND_OP logic_expression {if (TRACEON) System.out.println("logic_and_or_sign: LOGIC_AND_OP logic_expression");}
	    | LOGIC_OR_OP logic_expression {if (TRACEON) System.out.println("logic_and_or_sign: LOGIC_OR_OP logic_expression");}
	    | {if (TRACEON) System.out.println("logic_and_or_sign: ");}
	    ;
logic_sign: EQ_OP {if (TRACEON) System.out.println("logic_sign: EQ_OP");}
            | LE_OP {if (TRACEON) System.out.println("logic_sign: LE_OP");}
            | GE_OP {if (TRACEON) System.out.println("logic_sign: GE_OP");}
            | LT_OP {if (TRACEON) System.out.println("logic_sign: LT_OP");}
            | GT_OP {if (TRACEON) System.out.println("logic_sign: GE_OP");}
            | NE_OP {if (TRACEON) System.out.println("logic_sign: NE_OP");}
            ;
multExpr: signExpr
          ( '*' signExpr
          | '/' signExpr
		  )*
		  {if (TRACEON) System.out.println("multExpr: signExpr (* signExpr | / signExpr)*");};

signExpr: primaryExpr {if (TRACEON) System.out.println("signExpr: primaryExpr");}
        | '-' primaryExpr {if (TRACEON) System.out.println("signExpr: - primaryExpr");}
		;
		  
primaryExpr: Integer_constant {if (TRACEON) System.out.println("primaryExpr: Integer_constant");}
           | Floating_point_constant {if (TRACEON) System.out.println("primaryExpr: Floating_point_constant");}
           | Identifier {if (TRACEON) System.out.println("primaryExpr: Identifier");}
		   | '(' arith_expression ')' {if (TRACEON) System.out.println("primaryExpr: (arith_expression)");}
           ;

statement: Identifier '=' arith_expression ';' {if (TRACEON) System.out.println("statement: Identifier = arith_expression;");}
         | IF '(' logic_expression ')' if_then_statements {if (TRACEON) System.out.println("statement: IF (logic_expression) if_then_statements");}
	 | ELSE then_else_statement {if (TRACEON) System.out.println("statement: ELSE then_else_statement");}
         | FOR '('type Identifier '=' arith_expression ';' logic_expression';'Identifier ('++'|'--') ')' for_while_statements {if (TRACEON) System.out.println("statement: FOR '('type Identifier = arith_expression ; logic_expression';'Identifier ('++' | '--') ')' for_while_statements");}
         | WHILE '(' logic_expression ')' for_while_statements {if (TRACEON) System.out.println("statement: WHILE (logic_expression) for_while_statements");}
         | PRINTF '(' Sentence 
         (
            ',' Identifier
         )*
         ')'';' {if (TRACEON) System.out.println("statement: PRINTF(Sentence (,Identifier)*);");}
         | RETURN (Identifier|Integer_constant) ';' {if (TRACEON) System.out.println("statement: RETURN (Identifier|Integer_constant) ;");}
	 | Identifier ('++' | '--') ';' {if (TRACEON) System.out.println("statement: Identifier ('++' | '--');");}
         ;
then_else_statement: if_then_statements {if (TRACEON) System.out.println("then_else_statement: if_then_statement");}
                  | IF if_then_statements ELSE if_then_statements {if (TRACEON) System.out.println("then_else_statement: IF if_then_statements ELSE if_then_statements");}
;
for_while_statements: statement {if (TRACEON) System.out.println("for_while_statements: statement");}
                  | '{' statement '}' {if (TRACEON) System.out.println("for_while_statements: {statement}");}
                  ;
if_then_statements: statement {if (TRACEON) System.out.println("if_then_statements: statement");}
                  | '{' statements '}' {if (TRACEON) System.out.println("if_then_statements: {statement}");}
				  ;

		   
/* description of the tokens */
INCLUDE: 'include';
FILE: '<stdio.h>';
FLOAT:'float';
CHAR: 'char';
INT:'int';
MAIN: 'main';
VOID: 'void';
IF: 'if';
LONG: 'long';
DOUBLE: 'double';
CONST: 'const';
FOR: 'for';
WHILE: 'while';
ELSE: 'else';
EQ_OP : '==';
LE_OP : '<=';
GE_OP : '>=';
LT_OP : '<';
GT_OP : '>';
NE_OP : '!=';
LOGIC_AND_OP: '&&';
LOGIC_OR_OP: '||';
Comma: ',';
Dot: '.';
Underscore: '_';
Double_colon: '::';
COLON: ':';

PRINTF: 'printf';
RETURN: 'return';
Identifier:('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;
Integer_constant:'0'..'9'+;
Floating_point_constant:'0'..'9'+ '.' '0'..'9'+;
Sentence: '"'(options{greedy=false;}: .)* '"';
WS:( ' ' | '\t' | '\r' | '\n' ) {$channel=HIDDEN;};
COMMENT:'/*' .* '*/' {$channel=HIDDEN;};

