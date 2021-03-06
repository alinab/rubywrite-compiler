# RACC specifications for PidginC parser

class PCParser

  prechigh
  nonassoc UMINUS UPLUS PREFIXOP
  left '*' '/'
  left '+' '-'
  left BOOL_OP
  left REL_OP
  preclow

rule

target:
   program { result = :Program[val[0]] }
| header_decls  program { result = [:Header[val[0]], :Program[val[1]]] }
  ;


/* Added rules for a program having:
   1.type declarations and function declarations 
   2.type declarations only 
   3.empty - No declarations of any type */
 program:
    function_defs  { result = val[0] }
  | type_decls function_defs { result = val[0] + val[1]  } /*Remove type_decls from this and below line */
  | type_decls { result = val[0] }
  | { result = [] }
  ;

  header_decls:
   header_decls header { result = val[0] + [val[1]] }
  | header { result = [val[0]] }
  ;

  header:
  '#' INCLUDE REL_OP STDIO '.' H REL_OP { result = val[0] + val[1] + val[2] + val[3] + val[4] + val[5] +val[6] }
  | '#' INCLUDE REL_OP OMP  '.' H REL_OP { result = val[0] + val[1] + val[2] + val[3] + val[4] + val[5] +val[6] }
  | '#' INCLUDE REL_OP PTHREAD  '.' H REL_OP { result = val[0] + val[1] + val[2] + val[3] + val[4] + val[5] +val[6] }
  | '#' INCLUDE REL_OP STDLIB   '.' H REL_OP { result = val[0] + val[1] + val[2] + val[3] + val[4] + val[5] +val[6] } 
  | '#' DEFINE NUM_THREADS INT_NUM  { result = val[0] + val[1] + ' ' + val[2] + ' ' + val[3] }
  ;

function_defs:
    function_defs  function_def  { result = val[0] + [val[1]] }
  | function_def { result = [val[0]] } 
  ;

  
/*Added function definition with return type a pointer to a value */
function_def:
    typename IDENTIFIER '(' formal_params ')' block  { result = :Function[val[0],val[1],val[3],val[5]] }
   | typename '*' IDENTIFIER '(' formal_params ')' block  { result = :Function[val[0],val[1],val[2],val[4],val[6]] } 
/* | typename IDENTIFIER '(' ')' block  { result = :Function[val[0],val[1],,val[4]] } */
  ;

  formal_params:
    formal_params ',' formal_param  { result = val[0] + [val[2]] }
  | formal_param  { result = [val[0]] }
  ;

  formal_param:
    typename  { result = val[0] }
  | typename IDENTIFIER  { result = val[0] + ' ' + val[1] }
  | typename '&' IDENTIFIER  { result = val[0] , val[2] }
  | typename array_formal  { result = val[0] , val[1] }
  | typename pointer_decl  { result = val[0] + val[1] }
  | { result =  ' '  } /*empty formal params */
  ;
 
   typename:
    CHAR
  | INT
  | DOUBLE
  | VOID
  | PTHREAD_T
  ;
 
  /*Rule defining a declaration with a type and a list of one or more variables/functions */
    type_decl:
   typename decl_list ';'{ result = :TypeDecls[val[0],val[1]] }
    ;
 
  /* Rule defining single declaration or a list of declarations */
    decl_list:
   decl_list ',' lval { result = val[0] ,val[2] }
/*  { result = val[0] + val[1] + val[2]   }*/
 /*| expr     Putting decl here gives rise to reduce/reduce conflicts */ 
/*| '*' IDENTIFIER { result = val[1] }*/
   | lval
   ;


/*Adding a new rule for parsing pointer declarations */
  pointer_decl:
   '*' IDENTIFIER { result =  val[0] + ' ' + val[1] } 
  ;


/* Rule defining a function declaration */
   fn_decl:
    IDENTIFIER '(' ')'  { result = [val[0],:Formals[[]]] }
| IDENTIFIER '(' formal_params ')' { result = [val[0] ,:Formals[val[2]]] }
  ;

  array_formal:
    IDENTIFIER array_formal_subs  { result = val[0] + val[1] }
  ;

  array_formal_subs:
    array_formal_subs array_formal_sub  { result = val[0] + [val[1]] }
  | array_formal_sub  { result = val[0] }
  ;

  array_formal_sub:
    '[' expr ']'  { result = val[1] }
  | '[' ']'  { result = :EmptySubscript[] }
  ;

  block:
   '{' stmt_list '}'  { result = :Block[val[1]] }
  ;

  block:
    { result = [] }
    ;
 
  /*Updated rule for statement list to include a single simple/compound statement */
    stmt_list:
    stmt_list stmt  { result = val[0] + [val[1]] } 
  | stmt { result = [val[0]] }
  ;

  stmt:
    simple_stmt ';' { result  = val[0] }
  | compound_stmt { result  = val[0] }
  | type_decl { result = val[0] }
  | pointer_decl {result = val[0] }
  | fn_decl
  | '#' PRAGMA OMP PARALLEL '{' stmt_list '}' { result = :ParallelPragmaBlock[val[5]] }
  | '#' PRAGMA OMP CRITICAL '{' stmt_list '}' { result = :CriticalPragmaBlock[val[5]] } 
/*  | '#' PRAGMA OMP SECTIONS  '{' stmt_list '}' { result = :SectionsPragmaBlock[val[5]] } 
    | '#' PRAGMA OMP SECTION   '{' stmt_list '}' { result = :SectionBlock[val[5]] } */
  | '#' PRAGMA OMP FOR   '{' stmt_list '}' { result = :ForPragmaBlock[val[5]] } 
| '#' PRAGMA OMP FOR SCHEDULE '(' STATIC ',' chunk ')' '{' stmt_list '}' { result = :StaticForPragmaBlock[val[8],val[11]] } 
| '#' PRAGMA OMP FOR SCHEDULE '(' DYNAMIC ',' chunk ')' '{' stmt_list '}' { result = :DynamicForPragmaBlock[val[8],val[11]] } 
  ;


  chunk:
  INT_NUM { result = :ConstInt[val[0]] }
  ;


/*Added rule for statements with pointer assignments */
    simple_stmt:
    lval '=' expr  { result = :Assignment[val[0] ,val[2]] }
  | BREAK  { result = :BreakStmt[] }
  | CONTINUE  { result = :ContinueStmt[] }
  | RETURN  { result = :ReturnStmt[] }
  | RETURN expr  { result = :ReturnStmt[val[1]] }
  | function_call
  | expr { result = val[0] }
  | pointer_decl '=' expr { result = :PointerVal[val[0] ,val[2]] }
  | lval '=' '&' expr { result = :PointerRef[val[0],val[3]] }
  ;
  
 /* Rules for compound statements */
  compound_stmt:
    FOR '(' simple_stmt  ';' expr ';' simple_stmt  ')' '{' stmt_list '}' { result = :For[val[0],val[2],val[4],val[6],val[9]] }
  | WHILE '(' simple_stmt ')' block  { result = [val[0],val[2],val[4]] }
  | IF '(' simple_stmt ')' block  optional_else  { result = :IfStmt[val[2] ,val[4] ,val[5]] }
  ;

/*end_of_for:   
  lval  '=' expr  { result = :End_of_for[val[0] ,val[2]] }
  ;*/

 /*Rules for optional else */
   optional_else:
    { result = [] }
  | ELSE  { result = [] }
  | ELSE '{' stmt_list '}'  { result = :ElseStmt[val[2]] }
  ;
  
  lval:
    IDENTIFIER { result = val[0]}
  | array_def  
  | pointer_decl  
  ;


expr:
    IDENTIFIER { result = :Variable[val[0]] }
  | INT_NUM  { result = :ConstInt[val[0]] }
  | REAL_NUM  { result = :ConstReal[val[0]] }
  | STRING  { result = :ConstString[val[0]] }
  | function_call 
  | array_def
  | '&' array_def { result = val[0] + val[1] } 
  | expr '+' expr  { result = :BinaryOp[val[0], '+', val[2]]}
  | expr '-' expr  { result = :BinaryOp[val[0], '-', val[2]] }
  | expr '*' expr  { result = :BinaryOp[val[0], '*', val[2]] }
  | expr '/' expr  { result = :BinaryOp[val[0], '/', val[2]] }
  | expr BOOL_OP expr  { result = :BinaryOp[val[0], val[1], val[2]] }
  | expr REL_OP expr  { result = :BinaryOp[val[0], val[1], val[2]] }
  | '-' expr  = UMINUS  { result = :UnaryOp['=', val[1]] }
  | '+' expr  = UPLUS  { result = :UnaryOp['+', val[1]] } /*changed :UnaryOp from UnaryOp0*/
  | PREFIX_OP expr = PREFIXOP  { result = :UnaryOp[val[0], val[1]] }
  | '(' expr ')'  { result = val[1] }
  | pointer_decl { result = val[0] }/* Added to let pointers be assigned expressions*/
  ;


  array_def:
  IDENTIFIER '[' array_index_list ']'  { result = :ArrayDef[val[0] ,val[2]] }
  ;

  array_index_list:
   array_index_list ']' '[' expr  { result = [val[0],val[3]] }
  | expr  { result = val[0] }
  ;

 
  function_call:
IDENTIFIER '(' actual_params ')'{ result = :FunctionCall[val[0],val[2]] }
  | IDENTIFIER '(' ')'  { result =   val[0]+val[1]+val[2] }
  ;
 
  actual_params:
     actual_params ',' expr { result = val[0] + [val[2]] } 
   | expr { result = [val[0]] } 
   | {  } /*For empty params*/
   ;

end


---- header ----

# pcparser.rb: generated by racc

---- inner ----

  def initialize
    @scanner = Scanner.new
  end

  def parse_array tokens
    yyparse tokens, :each
  end

  def parse_file
    do_parse
  end

  def next_token
    @scanner.next_token
  end

  # override the default error reporting function to report line number
  def on_error err_token_id, err_value, value_stack
    puts "Error at or near line #{@scanner.lineno}, while parsing '#{err_value}' (#{token_to_str(err_token_id)})"
    puts "Current parse stack:"
    (value_stack.length-1).downto(0) {|i| puts "\t#{value_stack[i].to_string}"}
  end

---- footer ----

# I suggest not using the footer, unless you want to execute some code once when the parser is included
require 'rubywrite'
require 'PCParse/scanner'
