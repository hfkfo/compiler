lexer grammar mylexer;

options {
  language = Java;
}
/*keyword*/
INCLUDE : 'include';
FILENAME: FILE1;
fragment FILE1: '<'(LETTER)(LETTER | DIGIT)* '.h>';
DEFINE : 'define';
RETURN: 'return';
Sentence: '"'(options{greedy=false;}: .)* '"';
/*----------------------*/
/*   Reserved Keywords  */
/*----------------------*/
INT_TYPE  : 'int';
CHAR_TYPE : 'char';
VOID_TYPE : 'void';
LONG_TYPE : 'long';
FLOAT_TYPE: 'float';
DOUBLE_TYPE: 'double';
CONST_TYPE: 'const';
FOR_: 'for';
WHILE_    : 'WHILE';
IF_: 'if';
ELSE_: 'else';

/* Comments */
COMMENT1 : '//'(.)*'\n';
COMMENT2 : '/*' (options{greedy=false;}: .)* '*/';

/*----------------------*/
/*  Compound Operators  */
/*----------------------*/

RSHIFT_OP : '<<';
LSHIFT_OP : '>>';
EQ_OP : '==';
LE_OP : '<=';
GE_OP : '>=';
LT_OP : '<';
GT_OP : '>';
NE_OP : '!=';
PP_OP : '++';
MM_OP : '--'; 
LOGIC_AND_OP: '&&';
LOGIC_OR_OP: '||';
Arithmetic_AND_OP: '&';
Arithmetic_OR_OP : '|';
MOD_OP: '%';
DIV_OP: '/';
MUL_OP: '*';
ADD_OP: '+';
SUB_OP: '-';
Arithmetic_NOT_OP: '~';
LOGIC_NOT_OP: '!';
Arithmetic_EQU_OP: '=';

/* punctuation */
Semicolon: ';';
BRACKET: '[' | ']';
Parentheses: ')' | '(';
BIG_Parentheses: '}' | '{';
Octothorpe: '#';
Double_colon: '::';
COLON: ':';
Space: ' ';
Comma: ',';
Dot: '.';
Underscore: '_';


/*function*/
MAIN_FUNCTION: 'main';
PRINTF_FUNC: 'printf';
SCANF_FUNC: 'scanf';

TAB: '\t';

DEC_NUM : ('0' | ('1'..'9')(DIGIT)*);

ID : (LETTER)(LETTER | DIGIT)*;

FLOAT_NUM: FLOAT_NUM1 | FLOAT_NUM2 | FLOAT_NUM3;
fragment FLOAT_NUM1: (DIGIT)+'.'(DIGIT)*;
fragment FLOAT_NUM2: '.'(DIGIT)+;
fragment FLOAT_NUM3: (DIGIT)+;



NEW_LINE: '\n';

fragment LETTER : 'a'..'z' | 'A'..'Z' | '_';
fragment DIGIT : '0'..'9';
