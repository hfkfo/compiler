grammar myCompiler;

options {
   language = Java;
}

@header {
    // import packages here.
    import java.util.HashMap;
    import java.util.ArrayList;
}

@members {
    boolean TRACEON = false;

    // Type information.
    public enum Type{
       ERR, BOOL, INT, FLOAT, CHAR, CONST_INT;
    }
    public enum Logic{
      GT, GE, EQ, NE, LT, LE;
    }
    // This structure is used to record the information of a variable or a constant.
    class tVar {
	   int   varIndex; // temporary variable's index. Ex: t1, t2, ..., etc.
	   int   iValue;   // value of constant integer. Ex: 123.
	   float fValue;   // value of constant floating point. Ex: 2.314.
      Logic lValue; 
	};

    class Info {
       Type theType;  // type information.
       tVar theVar;
	   
	   Info() {
          theType = Type.ERR;
		  theVar = new tVar();
	   }
    };

	
    // ============================================
    // Create a symbol table.
	// ArrayList is easy to extend to add more info. into symbol table.
	//
	// The structure of symbol table:
	// <variable ID, [Type, [varIndex or iValue, or fValue]]>
	//    - type: the variable type   (please check "enum Type")
	//    - varIndex: the variable's index, ex: t1, t2, ...
	//    - iValue: value of integer constant.
	//    - fValue: value of floating-point constant.
    // ============================================

    HashMap<String, Info> symtab = new HashMap<String, Info>();

    // labelCount is used to represent temporary label.
    // The first index is 0.
    int labelCount = 0;
	
    // varCount is used to represent temporary variables.
    // The first index is 0.
    int varCount = 0;
    int condCount = 0;
    int endCount = 0;
    int strCount = 0;
    int print = 2;
    // Record all assembly instructions.
    List<String> TextCode = new ArrayList<String>();
    String print_id = new String();

    /*
     * Output prologue.
     */
    void prologue()
    {
       TextCode.add("; === prologue ====");
       TextCode.add("declare dso_local i32 @printf(i8*, ...)\n");
	   TextCode.add("define dso_local i32 @main()");
	   TextCode.add("{");
    }
    
	
    /*
     * Output epilogue.
     */
    void epilogue()
    {
       /* handle epilogue */
       TextCode.add("\n; === epilogue ===");
	   TextCode.add("ret i32 0");
       TextCode.add("}");
    }
    
    
    /* Generate a new label */
    String newLabel()
    {
       labelCount ++;
       return (new String("L")) + Integer.toString(labelCount);
    } 
    
    
    public List<String> getTextCode()
    {
       return TextCode;
    }
}

program: VOID MAIN '(' ')'
        {
           /* Output function prologue */
           prologue();
        }

        '{' 
           declarations
           statements
        '}'
        {
	   if (TRACEON)
	      System.out.println("VOID MAIN () {declarations statements}");

           /* output function epilogue */	  
           epilogue();
        }
        ;


declarations: type Identifier ';' declarations
        {
           if (TRACEON)
              System.out.println("declarations: type Identifier : declarations");

           if (symtab.containsKey($Identifier.text)) {
              // variable re-declared.
              System.out.println("Type Error: " + 
                                  $Identifier.getLine() + 
                                 ": Redeclared identifier.");
              System.exit(0);
           }
                 
           /* Add ID and its info into the symbol table. */
	       Info the_entry = new Info();
		   the_entry.theType = $type.attr_type;
		   the_entry.theVar.varIndex = varCount;
		   varCount ++;
		   symtab.put($Identifier.text, the_entry);

           // issue the instruction.
		   // Ex: \%a = alloca i32, align 4
           if ($type.attr_type == Type.INT) { 
              TextCode.add("\%t" + the_entry.theVar.varIndex + " = alloca i32, align 4");
           }
        }
        | 
        {
           if (TRACEON)
              System.out.println("declarations: ");
        }
        ;


type
returns [Type attr_type]
    : INT { if (TRACEON) System.out.println("type: INT"); $attr_type=Type.INT; }
    | CHAR { if (TRACEON) System.out.println("type: CHAR"); $attr_type=Type.CHAR; }
    | FLOAT {if (TRACEON) System.out.println("type: FLOAT"); $attr_type=Type.FLOAT; }
	;

relation_op
returns [Logic OP]
   : '>'  {$OP=Logic.GT;}
   | '>=' {$OP=Logic.GE;}
   | '<'  {$OP=Logic.LT;}
   | '<=' {$OP=Logic.LE;}
   | '==' {$OP=Logic.EQ;}
   | '!=' {$OP=Logic.NE;}
   ;

statements:statement statements
          |
          ;


statement: assign_stmt ';'
         | if_stmt
         | func_no_return_stmt ';'
         | for_stmt
         | while_stmt
         | print_stmt ';'
         | 'return 0;'
         ;
while_stmt: WHILE while_judge block_stmt
            {
               TextCode.add("br label \%L" + $while_judge.top);
               TextCode.add("L" + $while_judge.next_label + ":");
            }
         ;
while_judge
returns [int next_label, int top]
         : '(' 
         {
            TextCode.add("br label \%L" + labelCount);
            TextCode.add("L" + labelCount + ":");
            $top = labelCount;
            labelCount++;
         }
         cond_expression 
         {
            TextCode.add("br i1 \%cond" + condCount + ", label \%L" + labelCount + ", label \%L" + (labelCount+1));			
            TextCode.add("L" + labelCount + ":");
            condCount++;
            labelCount++;
            $next_label = labelCount;
            labelCount++;
         }
         ')'
      ; 
for_stmt: FOR for_judge
            {
               TextCode.add("br label \%L" + $for_judge.top);
               TextCode.add("L" + $for_judge.label + ":");
            }
          block_stmt
            {
               TextCode.add("br label \%L" + $for_judge.assign_label);
               TextCode.add("L" + $for_judge.next_label + ":");
            }
        ;

for_judge
returns [int label, int next_label, int top, int assign_label]
         : '(' assign_stmt 
            {
               TextCode.add("br label \%L" + labelCount);
               TextCode.add("L" + labelCount + ":");
               $top = labelCount;
               labelCount++;
            }
            ';' cond_expression
            {
               
               TextCode.add("br i1 \%cond" + condCount + ", label \%L" + labelCount + ", label \%L" + (labelCount+1));			
               $label = labelCount;
               condCount++;
               labelCount++;
               $next_label = labelCount;
               labelCount++;
               TextCode.add("br label \%L" + labelCount);
               TextCode.add("L" + labelCount + ":");
               $assign_label = labelCount;
               labelCount++;
            }
             ';'assign_stmt
             ')'
         ;
print_stmt: PRINTF '(' STRING_LITERAL 
            {
               print_id = new String();
            }
            (COMMA arith_expression
            {
               print_id = print_id + ", i32 \%t" + (varCount-1);
            }
            )* 
            {
               String sentence = new String($STRING_LITERAL.text);
               sentence = sentence.replace("\\n","\n");
               sentence = sentence.replace("\"","");
               sentence = sentence + '\0';
               int length = sentence.length();
               sentence = sentence.replace("\n","\\0A");
               sentence = sentence.replace(Character.toString('\0'),"\\00");
               
               TextCode.add(print,"@str" + strCount + "= private unnamed_addr constant [" + length + " x i8] c\"" + sentence + "\"");
               print++;
               TextCode.add("\%t" + varCount + "= call i32 (i8*, ...) @printf(i8* getelementptr inbounds (["+ length + " x i8], [" + length + " x i8]* @str" + strCount + ", i64 0, i64 0)" + print_id + ")");
               varCount++;
               strCount++;
            }
            ')' 
         ;
		 
if_stmt
            : if_then_stmt
            {
               TextCode.add("L" + $if_then_stmt.next_label + ":");
            } 
            if_else_stmt
            {
               TextCode.add("Lend" + endCount + ":");
               endCount++;
            }
            
            ;

	   
if_then_stmt
returns [int next_label]
            : IF '(' cond_expression ')' 
            {
               TextCode.add("br i1 \%cond" + condCount + ", label \%L" + labelCount + ", label \%L" + (labelCount+1));			
               TextCode.add("L" + labelCount + ":");
               condCount++;
               labelCount++;
               $next_label = labelCount;
               labelCount++;
            }
            block_stmt
            {
               TextCode.add("br label \%Lend" + endCount);
            }
            ;


if_else_stmt
            : ELSE then_or_else 
            {
               if($then_or_else.next_label >= 0)
               {
                  TextCode.add("L" + $then_or_else.next_label + ":");
               }
            }
            if_else_stmt
            |
            ;

then_or_else
returns [int next_label]
            : IF '(' cond_expression ')' 
            {
               TextCode.add("br i1 \%cond" + condCount + ", label \%L" + labelCount + ", label \%L" + (labelCount+1));			
               TextCode.add("L" + labelCount + ":");
               condCount++;
               labelCount++;
               $next_label = labelCount;
               labelCount++;
            }
            block_stmt
            {
               TextCode.add("br label \%Lend" + endCount); 
            }
            | block_stmt
            {
               $next_label = -1;
               TextCode.add("br label \%Lend" + endCount);
            }
            ;
				  
block_stmt: '{' statements '}'
	  ;


assign_stmt: Identifier '=' arith_expression
             {
               if (!symtab.containsKey($Identifier.text)) {
                  System.out.println("Error! " + 
                           $Identifier.getLine()  +
                           ": Undeclared identifier.");
                  System.exit(0);
	            }
		
               Info theRHS = $arith_expression.theInfo;
				   Info theLHS = symtab.get($Identifier.text); 
		   
               if ((theLHS.theType == Type.INT) && (theRHS.theType == Type.INT)) {		   
                   // issue store insruction.
                   // Ex: store i32 \%tx, i32* \%ty
                   TextCode.add("store i32 \%t" + theRHS.theVar.varIndex + ", i32* \%t" + theLHS.theVar.varIndex);
				   } 
               else if ((theLHS.theType == Type.INT) && (theRHS.theType == Type.CONST_INT)) {
                   // issue store insruction.
                   // Ex: store i32 value, i32* \%ty
                   TextCode.add("store i32 " + theRHS.theVar.iValue + ", i32* \%t" + theLHS.theVar.varIndex);				
				   }
               else
               {
                  System.out.println("Error! " + 
                                    $Identifier.getLine()  +
                                    ": Type mismatch for the two silde operands in an assignment statement.");
                  System.exit(0);
               }
			 }
             ;

		   
func_no_return_stmt: Identifier '(' argument ')'
                   ;


argument: arg (',' arg)*
        ;

arg: arith_expression
   | STRING_LITERAL
   ;
		   
cond_expression
               : a=arith_expression c=relation_op b=arith_expression
               {
                  Info arithL = $a.theInfo;
                  Info arithR = $b.theInfo;
                  switch($c.OP){
                     case GT:
                        if ((arithL.theType == Type.INT) && (arithR.theType == Type.INT)) {
                           TextCode.add("\%cond" + condCount + " = icmp sgt i32 \%t" + arithL.theVar.varIndex + ", \%t" + arithR.theVar.varIndex);

                        } else if ((arithL.theType == Type.INT) && (arithR.theType == Type.CONST_INT)) {
                           TextCode.add("\%cond" + condCount + " = icmp sgt i32 \%t" + arithL.theVar.varIndex + ", " + arithR.theVar.iValue);
                        }
                        else
                        {
                           System.out.println("Error! " + 
                                    $relation_op.start.getLine()  +
                                    ":Type mismatch for the operator > in an expression.");
                           System.exit(0);

                        }
                        break;
                     case GE:
                        if ((arithL.theType == Type.INT) && (arithR.theType == Type.INT)) {
                           TextCode.add("\%cond" + condCount + " = icmp sge i32 \%t" + arithL.theVar.varIndex + ", \%t" + arithR.theVar.varIndex);

                        } else if ((arithL.theType == Type.INT) && (arithR.theType == Type.CONST_INT)) {
                           TextCode.add("\%cond" + condCount + " = icmp sge i32 \%t" + arithL.theVar.varIndex + ", " + arithR.theVar.iValue);
                        }
                        else
                        {
                           System.out.println("Error! " + 
                                    $relation_op.start.getLine()  +
                                    ":Type mismatch for the operator >= in an expression.");
                           System.exit(0);
                        }
                        break;
                     case LT:
                        if ((arithL.theType == Type.INT) && (arithR.theType == Type.INT)) {
                           TextCode.add("\%cond" + condCount + " = icmp slt i32 \%t" + arithL.theVar.varIndex + ", \%t" + arithR.theVar.varIndex);

                        } else if ((arithL.theType == Type.INT) && (arithR.theType == Type.CONST_INT)) {
                           TextCode.add("\%cond" + condCount + " = icmp slt i32 \%t" + arithL.theVar.varIndex + ", " + arithR.theVar.iValue);
                        }
                        else
                        {
                           System.out.println("Error! " + 
                                    $relation_op.start.getLine()  +
                                    ":Type mismatch for the operator < in an expression.");
                           System.exit(0);
                        }
                        break;
                     case LE:
                        if ((arithL.theType == Type.INT) && (arithR.theType == Type.INT)) {
                           TextCode.add("\%cond" + condCount + " = icmp sle i32 \%t" + arithL.theVar.varIndex + ", \%t" + arithR.theVar.varIndex);

                        } else if ((arithL.theType == Type.INT) && (arithR.theType == Type.CONST_INT)) {
                           TextCode.add("\%cond" + condCount + " = icmp sle i32 \%t" + arithL.theVar.varIndex + ", " + arithR.theVar.iValue);
                        }
                        else
                        {
                           System.out.println("Error! " + 
                                    $relation_op.start.getLine()  +
                                    ":Type mismatch for the operator <= in an expression.");
                           System.exit(0);
                        }
                        break;
                     case EQ:
                        if ((arithL.theType == Type.INT) && (arithR.theType == Type.INT)) {
                           TextCode.add("\%cond" + condCount + " = icmp eq i32 \%t" + arithL.theVar.varIndex + ", \%t" + arithR.theVar.varIndex);

                        } else if ((arithL.theType == Type.INT) && (arithR.theType == Type.CONST_INT)) {
                           TextCode.add("\%cond" + condCount + " = icmp eq i32 \%t" + arithL.theVar.varIndex + ", " + arithR.theVar.iValue);
                        }
                        else
                        {
                           System.out.println("Error! " + 
                                    $relation_op.start.getLine()  +
                                    ":Type mismatch for the operator == in an expression.");
                           System.exit(0);
                        }
                        break;
                     case NE:
                        if ((arithL.theType == Type.INT) && (arithR.theType == Type.INT)) {
                           TextCode.add("\%cond" + condCount + " = icmp ne i32 \%t" + arithL.theVar.varIndex + ", \%t" + arithR.theVar.varIndex);

                        } else if ((arithL.theType == Type.INT) && (arithR.theType == Type.CONST_INT)) {
                           TextCode.add("\%cond" + condCount + " = icmp ne i32 \%t" + arithL.theVar.varIndex + ", " + arithR.theVar.iValue);
                        }
                        else
                        {
                           System.out.println("Error! " + 
                                    $relation_op.start.getLine()  +
                                    ":Type mismatch for the operator != in an expression.");
                           System.exit(0);
                        }
                        break;
                  }

               }
               ;

arith_expression
returns [Info theInfo]
@init {theInfo = new Info();}
                : a=multExpr { $theInfo=$a.theInfo; }
                 ( PLUS b=multExpr
                    {
                        // We need to do type checking first.
                        // ...
                        
                        // code generation.				
                        Info arithR = $b.theInfo;	   
                        if (($a.theInfo.theType == Type.INT) && (arithR.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + arithR.theVar.varIndex);
                     
                           // Update arith_expression's theInfo.
                           $theInfo.theType = Type.INT;
                           $theInfo.theVar.varIndex = varCount;
                           varCount ++;
                        } 
                        else if (($a.theInfo.theType == Type.INT) && (arithR.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + arithR.theVar.iValue);
                     
                           // Update arith_expression's theInfo.
                           $theInfo.theType = Type.INT;
                           $theInfo.theVar.varIndex = varCount;
                           varCount ++;
                        }
                        else
                        {
                           System.out.println("Error! " + 
                                    $PLUS.getLine()  +
                                    ": Type mismatch for the operator + in an expression.");
                           System.exit(0);
                        }
                     }
                 | MINUS c=multExpr
                     {
                        
                        Info arithR = $c.theInfo;	   
                        if (($a.theInfo.theType == Type.INT) && (arithR.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = sub nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + arithR.theVar.varIndex);
                     
                           // Update arith_expression's theInfo.
                           $theInfo.theType = Type.INT;
                           $theInfo.theVar.varIndex = varCount;
                           varCount ++;
                        } 
                        else if (($a.theInfo.theType == Type.INT) && (arithR.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = sub nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + arithR.theVar.iValue);
                     
                           // Update arith_expression's theInfo.
                           $theInfo.theType = Type.INT;
                           $theInfo.theVar.varIndex = varCount;
                           varCount ++;
                        }
                        else
                        {
                           System.out.println("Error! " + 
                                    $MINUS.getLine()  +
                                    ": Type mismatch for the operator - in an expression.");
                           System.exit(0);
                        }
                     }
                 )*
                 ;

multExpr
returns [Info theInfo]
@init {theInfo = new Info();}
          : a=signExpr { $theInfo=$a.theInfo; }
          ( MUL b=signExpr
            {
               
               Info arithR = $b.theInfo;	   
               if (($a.theInfo.theType == Type.INT) && (arithR.theType == Type.INT)) {
                  TextCode.add("\%t" + varCount + " = mul nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + arithR.theVar.varIndex);
            
                  // Update arith_expression's theInfo.
                  $theInfo.theType = Type.INT;
                  $theInfo.theVar.varIndex = varCount;
                  varCount ++;
               } 
               else if (($a.theInfo.theType == Type.INT) && (arithR.theType == Type.CONST_INT)) {
                  TextCode.add("\%t" + varCount + " = mul nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + arithR.theVar.iValue);
            
                  // Update arith_expression's theInfo.
                  $theInfo.theType = Type.INT;
                  $theInfo.theVar.varIndex = varCount;
                  varCount ++;
               }
               else
               {
                  System.out.println("Error! " + 
                                    $MUL.getLine()  +
                                    ": Type mismatch for the operator * in an expression.");
                           System.exit(0);
                  System.exit(0);
               }
            }
          | DIV c=signExpr
            {
               
               Info arithR = $c.theInfo;	   
               if (($a.theInfo.theType == Type.INT) && (arithR.theType == Type.INT)) {
                  TextCode.add("\%t" + varCount + " = sdiv i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + arithR.theVar.varIndex);
            
                  // Update arith_expression's theInfo.
                  $theInfo.theType = Type.INT;
                  $theInfo.theVar.varIndex = varCount;
                  varCount ++;
               } 
               else if (($a.theInfo.theType == Type.INT) && (arithR.theType == Type.CONST_INT)) {
                  TextCode.add("\%t" + varCount + " = sdiv i32 \%t" + $theInfo.theVar.varIndex + ", " + arithR.theVar.iValue);
            
                  // Update arith_expression's theInfo.
                  $theInfo.theType = Type.INT;
                  $theInfo.theVar.varIndex = varCount;
                  varCount ++;
               }
               else
               {
                  System.out.println("Error! " + 
                                    $DIV.getLine()  +
                                    ": Type mismatch for the operator / in an expression.");
                           System.exit(0);
                  System.exit(0);
               }
            }
	  )*
	  ;

signExpr
returns [Info theInfo]
@init {theInfo = new Info();}
         : a=primaryExpr { $theInfo=$a.theInfo; } 
         | '-' b = primaryExpr 
         {
            $theInfo=$b.theInfo;
            $theInfo.theVar.iValue *= -1; 
         }
	      ;
		  
primaryExpr
returns [Info theInfo]
@init {theInfo = new Info();}
           : Integer_constant
	            {
                  $theInfo.theType = Type.CONST_INT;
                  $theInfo.theVar.iValue = Integer.parseInt($Integer_constant.text);
               }
           | Floating_point_constant
           | Identifier
               {
                  if (!symtab.containsKey($Identifier.text)) {
                     /* Add codes to report and handle this error */
                     System.out.println("Error! " + $Identifier.getLine() + ": Undeclared identifier.");
                     System.exit(0);
                  } 

                  // get type information from symtab.
                  Type the_type = symtab.get($Identifier.text).theType;
                  $theInfo.theType = the_type;
                  // get variable index from symtab.
                  int vIndex = symtab.get($Identifier.text).theVar.varIndex;
				
                  switch (the_type) {
                  case INT: 
                           // get a new temporary variable and
                           // load the variable into the temporary variable.
                                 
                           // Ex: \%tx = load i32, i32* \%ty.
                           TextCode.add("\%t" + varCount + "=load i32, i32* \%t" + vIndex);
                              
                           // Now, Identifier's value is at the temporary variable \%t[varCount].
                           // Therefore, update it.
                           $theInfo.theVar.varIndex = varCount;
                           varCount ++;
                           break;
                  case FLOAT:
                           break;
                  case CHAR:
                           break;
            
                  }
              }
	   | '(' arith_expression ')'
            {
               $theInfo = $arith_expression.theInfo;
            }
      ;

		   
/* description of the tokens */
PLUS: '+';
MINUS: '-';
MUL: '*';
DIV: '/';

FLOAT:'float';
INT:'int';
CHAR: 'char';

MAIN: 'main';
VOID: 'void';
IF: 'if';
ELSE: 'else';
FOR: 'for';
WHILE: 'while';
PRINTF: 'printf';

COMMA: ',';

Identifier:('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;
Integer_constant:'0'..'9'+;
Floating_point_constant:'0'..'9'+ '.' '0'..'9'+;

STRING_LITERAL
    :  '"' ( EscapeSequence | ~('\\'|'"') )* '"'
    ;

WS:( ' ' | '\t' | '\r' | '\n' ) {$channel=HIDDEN;};
COMMENT:'/*' .* '*/' {$channel=HIDDEN;};


fragment
EscapeSequence
    :   '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')
    ;
