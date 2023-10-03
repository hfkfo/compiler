grammar myChecker;

@header {
    // import packages here.
    import java.util.HashMap;
}

@members {
    boolean TRACEON = false;
    HashMap<String,Integer> symtab = new HashMap<String,Integer>();

	/*
    public enum TypeInfo {
        Integer,
		Float,
		Unknown,
		No_Exist,
		Error
    }
    */

    /* attr_type:
       1 => integer,
       2 => float,
       -1 => do not exist,
       -2 => error
     */	   
}

program:'#' INCLUDE FILE VOID MAIN '(' ')' '{' declarations statements '}'
        {if (TRACEON) System.out.println("program:('#' INCLUDE FILE)+ VOID MAIN () {declarations statements}");};
declarations
	: type Identifier ';' declarations
     	{
	   if (TRACEON) System.out.println("declarations: type Identifier : declarations");
	 
  	   if (symtab.containsKey($Identifier.text)) {
		   System.out.println("Error! " + 
				              $Identifier.getLine() + 
							  ": Redeclared identifier.");
	   } else {
		   /* Add ID and its attr_type into the symbol table. */
		   symtab.put($Identifier.text, $type.attr_type);	   
	   }
	 }
	| { if (TRACEON) System.out.println("declarations: "); }
	;

type returns [int attr_type]
	:INT    { if (TRACEON) System.out.println("type: INT");  $attr_type = 1; }
	| FLOAT { if (TRACEON) System.out.println("type: FLOAT");  $attr_type = 2; }
	| BOOLEAN {if (TRACEON) System.out.println("type: BOOLEAN"); $attr_type = 3;}
	;

statements
	:statement statements
	|;

logic_sign: EQ_OP {if (TRACEON) System.out.println("logic_sign: EQ_OP");}
            | LE_OP {if (TRACEON) System.out.println("logic_sign: LE_OP");}
            | GE_OP {if (TRACEON) System.out.println("logic_sign: GE_OP");}
            | LT_OP {if (TRACEON) System.out.println("logic_sign: LT_OP");}
            | GT_OP {if (TRACEON) System.out.println("logic_sign: GE_OP");}
            | NE_OP {if (TRACEON) System.out.println("logic_sign: NE_OP");}
            ;

arith_expression returns [int attr_type]
	: a = multExpr { $attr_type = $a.attr_type; }
      (( '+' b = multExpr
	    { if ($a.attr_type != $b.attr_type) {
			  System.out.println("Error! " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the operator + in an expression.");
		      $attr_type = -2;
		  }
        }
	  | '-' c = multExpr
		{ if ($a.attr_type != $c.attr_type) {
			  System.out.println("Error! " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the operator - in an expression.");
		      $attr_type = -2;
		  }
        }
	  )* 
	  |logic_sign d = multExpr
	  	{
			if ($a.attr_type != $d.attr_type) {
				System.out.println("Error! " + 
									$a.start.getLine() +
									": Type mismatch for the operator logic in an expression.");
				$attr_type = -2;
			}
			else
			{
				$attr_type = 3;
			}
		} 
		)
	  
	;
multExpr returns [int attr_type]
	: a = signExpr { $attr_type = $a.attr_type; }
      ( '*' b = signExpr
	  	{ if ($a.attr_type != $b.attr_type) {
			  System.out.println("Error! " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the operator * in an expression.");
		      $attr_type = -2;
		  }
        }
      | '/' c = signExpr
	  	{ if ($a.attr_type != $c.attr_type) {
			  System.out.println("Error! " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the operator / in an expression.");
		      $attr_type = -2;
		  }
        }
	  )*
	;

signExpr returns [int attr_type]
	: primaryExpr { $attr_type = $primaryExpr.attr_type; }
	| '-' primaryExpr { $attr_type = $primaryExpr.attr_type; }
	;
		  
primaryExpr returns [int attr_type] 
	: Integer_constant        { $attr_type = 1; }
	| Floating_point_constant { $attr_type = 2; }
	| Identifier
		{
			if (symtab.containsKey($Identifier.text)) {
				$attr_type = symtab.get($Identifier.text);
			} else {
				/* Add codes to report and handle this error */
				System.out.println("Error! " + 
				              $Identifier.getLine() +
						      ": Undeclared identifier.");
				$attr_type = -2;
				return $attr_type;
			}
	 	}
	| '(' arith_expression ')' { $attr_type = $arith_expression.attr_type; }
    ;

statement returns [int attr_type]
	: Identifier '=' arith_expression ';'
	 {
	   if (symtab.containsKey($Identifier.text)) {
	       $attr_type = symtab.get($Identifier.text);
	   } else {
           /* Add codes to report and handle this error */
		System.out.println("Error! " + 
				              $arith_expression.start.getLine() +
						      ": Undeclared identifier.");
	       $attr_type = -2;
		   return $attr_type;
	   }
		
	   if ($attr_type != $arith_expression.attr_type) {
           System.out.println("Error! " + 
				              $arith_expression.start.getLine() +
						      ": Type mismatch for the two silde operands in an assignment statement.");
		   $attr_type = -2;
       }
	 }
	| IF '(' a = arith_expression (LOGIC_AND_OP  b = arith_expression | LOGIC_OR_OP  c = arith_expression )*')' if_then_statements
		{
			if($a.attr_type != 3 || $b.attr_type != 3 || $c.attr_type != 3)
			{
				System.out.println("Error! " + 
								$a.start.getLine() +
								": Type mismatch for IF.");
			$attr_type = -2;
			}
		}
	| ELSE then_else_statement {if (TRACEON) System.out.println("statement: ELSE then_else_statement");}
	| WHILE '(' a = arith_expression (LOGIC_AND_OP  b = arith_expression | LOGIC_OR_OP  c = arith_expression )* ')' while_for_statements
		{
			if($a.attr_type != 3 || $b.attr_type != 3 || $c.attr_type != 3)
			{
				System.out.println("Error! " + 
								$a.start.getLine() +
								": Type mismatch for WHILE.");
			$attr_type = -2;
			}
		}
	| FOR '('type Identifier '=' primaryExpr ';' arith_expression ';'Identifier ('++'|'--') ')' while_for_statements
		{
			if($arith_expression.attr_type != 3)
			{
				System.out.println("Error! " + 
								$arith_expression.start.getLine() +
								": Type mismatch for FOR.");
				$attr_type = -2;
			}
			else if ($type.attr_type != $primaryExpr.attr_type)
			{
				System.out.println("Error! " + 
				              $arith_expression.start.getLine() +
						      ": Type mismatch for the two silde operands in an assignment statement.");
		  		 $attr_type = -2;
			}
		}
	| PRINTF '(' Sentence (',' Identifier)*')'';' {if (TRACEON) System.out.println("statement: PRINTF(Sentence (,Identifier)*);");}
	| RETURN (Identifier|Integer_constant) ';' {if (TRACEON) System.out.println("statement: RETURN (Identifier|Integer_constant) ;");}
	| Identifier ('++' | '--') ';' {if (TRACEON) System.out.println("statement: Identifier ('++' | '--');");}
	;
then_else_statement returns [int attr_type]
	: if_then_statements {if (TRACEON) System.out.println("then_else_statement: if_then_statement"); $attr_type = 3;}
    | IF '(' a = arith_expression (LOGIC_AND_OP  b = arith_expression | LOGIC_OR_OP  c = arith_expression )* ')' if_then_statements ELSE if_then_statements 
		{
			if (TRACEON) System.out.println("then_else_statement: IF if_then_statements ELSE if_then_statements");
			if($a.attr_type != 3 || $b.attr_type != 3 || $c.attr_type != 3)
			{
				System.out.println("Error! " + 
								$a.start.getLine() +
								": Type mismatch for ELSE IF.");
				$attr_type = -2;
			}
			else
			{
				$attr_type = 3;
			}
		}
	;
if_then_statements
	: '{' statements '}'
	;
while_for_statements
	: '{' statement '}'
	;
		   
/* ====== description of the tokens ====== */
INCLUDE: 'include';
FILE: '<stdio.h>';
FLOAT:'float';
INT:'int';
BOOLEAN: 'bool';
MAIN: 'main';
VOID: 'void';
IF: 'if';
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
