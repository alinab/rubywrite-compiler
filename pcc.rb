cwd = File.dirname(__FILE__)
$:.unshift cwd, cwd + '/RubyWrite/lib'
$:.unshift cwd, cwd + '/ruby-llvm/lib'

require 'rubywrite'
require 'optparse'
require 'PCParse/pcparser'
require 'shadow_boxing'
require 'llvm/core'
require 'llvm/execution_engine'
require 'llvm/transforms/scalar'

STDOUT.sync = true

def parsed_output()
    parser = PCParser.new
    tt = parser.parse_file
    tt.prettyprint STDOUT
    puts
end

def unparse()
  parser = PCParser.new
  s = parser.parse_file
  a = UnparsePidginC.new
  result = a.unparse(s)
  print result 
end

def new_unparse()
  parser = PCParser.new
  s = parser.parse_file
  main_array = s
  l = main_array.length
  headers = s[0]
  par_nodes_after = s.index(headers) + 1
  pnode = s[1]
  #tt_array holds the entire program AST with pos 0 having the headers
  # pos 1 having the omp parallel block 
  # and pos 2 having the node for "main" in Pidgin C"
  tt_array = pragma_codegen(pnode,par_nodes_after,main_array)
  a = UnparsePidginC.new
  tt_array.each do |i|
  result = a.unparse(i)
  print result 
  end
end

def pragma_codegen(s,p_index,pg_array)
  program_node = s
  node = return_node(program_node)
  block_name = return_node(node)
  block_child = return_node(block_name)

  var_names = Array.new
  var_types = Array.new
  block_child.each do |j|
    t_dcl_n,v_name=  return_node(j)
    if (t_dcl_n.to_s).empty?
       next
    end
    var_types.push(t_dcl_n.to_s)
    var_names.push(v_name.to_s)
  
  end
  len =  var_types.length

  c_struct_node  = :Struct
  c_struct_main =  Array.new #:Struct_name #["st_data"
  c_struct_elem = ["typedef"," ","struct"," " ,"{"] ##
  c_struct_name = :Struct_name[c_struct_elem] #["st_data"
 
  c_struct_main.push(c_struct_name)
 
 struct_each = :Struct_assign 
 for k in (0..len-1) do 
   struct_mem = Array.new
   struct_mem.push(var_types[k]) 
   #v = :Variable[var_names[k]]
   struct_mem.push(' ')
   struct_mem.push(var_names[k])
   struct_sentence =  :Struct_assign[struct_mem]
   c_struct_main.push(struct_sentence)
  end


  struct_name_for_typ = "data_struct"
  
  c_struct_end  = :Struct_end
  c_struct_end_array = ["}",struct_name_for_typ]
  c_struct_node_end = c_struct_end[c_struct_end_array]
  c_struct_main.push(c_struct_node_end)
  #c_struct_main.push
  #c_struct_main.push(
  ds_struct = c_struct_node[c_struct_main]

  #c_struct_elem.push(c_struct_name)

  
    block_child.each do |i|
      DataCreate.run (i)
    end
  #print $var_vals
  #ds_struct.prettyprint STDOUT 
  #exit
  pg_array.insert(1,ds_struct) #was unshift earlier 

  num_funcs = 0
  stmt_0 = :TypeDecls["pthread_t",:ArrayDef["threads",:Variable["NUM_THREADS"]]]
  stmt_2 =  :TypeDecls["int","rc ,i"]
  stmt_1 =  :TypeDecls["int",:ArrayDef["thread_args",:Variable["NUM_THREADS"]]]


  block_child.insert(0,stmt_0)
  block_child.insert(0,stmt_1)
  block_child.insert(0,stmt_2)


  block_child.each do |i|
  g = i.value
  if g.eql?(:ParallelPragmaBlock)
    
    num_funcs = num_funcs + 1
    stmts = generate_block_to_insert_in_main(num_funcs,struct_name_for_typ,var_names)
    index = block_child.index(i)
    #print "index = ",index,"\n"
    pragma_block = block_child.delete(i)
       
    transf_pragma_block = build_pragma_block(pragma_block,num_funcs,c_struct_name,var_names)
    pg_array.insert(p_index+1,transf_pragma_block)

    
    point = index
   
    stmts.each do |i|
    block_child.insert(point,i)
    point = point + 1
    end
   end
   #exit_stmt = :FunctionCall \
   #            ["pthread_exit" \
   #            ,[:ConstString["NULL"]]]
   #block_child.push(exit_stmt)
  end 
return pg_array
end



class DataCreate
  include RubyWrite
# values = Array.new
  define_rw_method :main do  |node|
    alltd!  node  do |n|
      if match? :ConstInt[:_],n
        num = n.child(0)
        #print "num",num,"\n" 
        #values.push(num)
      else
        false
      end
    end  
  end
# @retval = var_vals
# def output
#  return @retval
# end
end


class DataVarChange
  include RubyWrite
  define_rw_method :main do  |node|
    alltd?  node  do |n|
      if match? :FunctionCall[:_],n
        v = n.child(0)
        print v,">---\n"
        if v.instance_of? :Variable 
        print "----------------"
        print v,"<-here\n" 
        end
      else
        false
      end
    end  
  end
end



def build_pragma_block(pragma,num_f,c_struct_name,var_names)
  pg_n = :Program
  pg_child = Array.new

  func_child = Array.new
  func_n = :Function
  
  func_ret_type = "void"
  func_pthread_name = "*Test"+num_f.to_s
  func_child.push(func_ret_type)
  func_child.push(func_pthread_name)
  func = func_n[func_child]

  for_ret_type = "void * args"
  #for_arg_name = "*args"

  p_arg_n = :PointerDecl
  p_arg_array = Array.new  
  p_arg_array.push(for_ret_type)


  formals = Array.new
  formals.push(for_ret_type)
  #formals.push(for_arg_name)
  func_child.push(formals)
 
  b_n = :Block
  
  block_child = Array.new
 

 
  var_arg_stmt = Array.new
  var_type_n = :TypeDecls

 
  var_ret_type = "int"
 # var_names.each do |i|
  var_ret_name = var_names[0].to_s
  var_arg_stmt.push(var_ret_type)
  var_arg_stmt.push(var_ret_name)
  var_type_decl = var_type_n[var_arg_stmt]
  block_child.push(var_type_decl)

  pt_to_struct = "*((st_data *) args)"

  #var_names.each do |i|
  pt_var = pt_to_struct + '.'+var_names[0].to_s
  pt_var_stmt = :Assignment[var_ret_name,pt_var]
  #print pt_var_stmt,"\n"
  
  block_child.push(pt_var_stmt)

  pthread_arg_stmt = Array.new
  pthread_type_n = :TypeDecls


  pthread_ret_type = "int"
  pthread_ret_name = "tid"
  pthread_arg_stmt.push(pthread_ret_type)
  pthread_arg_stmt.push(pthread_ret_name)

  pth_type_decl = pthread_type_n[pthread_arg_stmt]
  block_child.push(pth_type_decl)
  block = b_n[block_child]
  func_child.push(block) 

  block_child.push(pragma)

  
  exit_stmt = :FunctionCall \
               ["pthread_exit" \
               ,[:ConstString["NULL"]]]
  block_child.push(exit_stmt)
  pg_child.push(func)
  res = pg_n[pg_child]
  #DataVarChange.run res
  #res.prettyprint STDOUT
  #exit
  return res
  
  
end



def  generate_block_to_insert_in_main(num_f,struct_name_for_typ,var_names)
  stmt_list = Array.new

  main_struct_name = "arg_struct"
  stmt_3 = :TypeDecls[struct_name_for_typ,main_struct_name]
  stmt_list.push(stmt_3)      


  struct_decl_num = 0
  struct_var_decl = main_struct_name+"." 
  
  n = 0
  var_names.each do |i|
  struct_var_decl_with_var = struct_var_decl+i.to_s
  struct_assign_stmt= :Assignment[struct_var_decl_with_var ,:ConstInt["3"]]
  stmt_list.push(struct_assign_stmt) 
  n = n + 1
  end
#  exit
  
  for_array_first_stmts = Array.new
  for_stmt = :For["for" ,:Assignment["i"  ,:ConstInt[ "0" ]]\
                  ,:BinaryOp[:Variable[ "i" ]  ,"<" ,\
                :Variable["NUM_THREADS"  ] ]  \
              ,:Assignment["i" \
           ,:BinaryOp[  :Variable[  "i"  ] ,"+" \
             ,:ConstInt[  "1"  ] ]],for_array_first_stmts ]


  for_stmt_1 = :Assignment[ :ArrayDef[\
               "thread_args" ,:Variable[ "i"  ] ] \
            , :Variable[ "i"  ] ]
   for_stmt_2 = :FunctionCall[ \
             "printf"  ,[:ConstString[ "\"Inside main:creating thread %d\\n\""  ] \
             ,:Variable[   "i"  ] ]]

  for_stmt_3 = :Assignment["rc" ,:FunctionCall \
               ["pthread_create" \
               ,[:UnaryOp["&",:ArrayDef[\
                               "threads", \
                                :Variable["i"]]] \
                  , :ConstString [ \
                       "NULL"] \
                  ,:ConstString [ \
                    "Test"+num_f.to_s] \
                  ,"(void *)"+" &" +main_struct_name.to_s  ]]]
                  
    
  for_array_first_stmts.push(for_stmt_1)
  for_array_first_stmts.push(for_stmt_2)
  for_array_first_stmts.push(for_stmt_3)         

  for_array_join_stmts = Array.new
  for_j_stmt = :For["for" ,:Assignment["i"  ,:ConstInt[ "0" ]           ]    ,:BinaryOp[:Variable[ "i" ]  ,"<" ,\
                :Variable["NUM_THREADS"  ] ]  \
              ,:Assignment["i" \
           ,:BinaryOp[  :Variable[  "i"  ] ,"+" \
             ,:ConstInt[  "1"  ] ]],for_array_join_stmts ]

 #for_j_stmt.prettyprint STDOUT 
 #exit
 for_join_th_stmt_1 = :Assignment["rc" ,:FunctionCall \
               ["pthread_join" \
               ,[:ArrayDef[\
                     "threads", \
                     :Variable["i"]] \
                  , :ConstString [ \
                       "NULL"] ]]]
   
  #for_join_th_stmt_1.prettyprint STDOUT
  
  for_array_join_stmts.push(for_join_th_stmt_1)
  #for_array_join_stmts.prettyprint STDOUT
  #exit       

  stmt_list.push(for_stmt)
  stmt_list.push(for_j_stmt)
  return stmt_list
end
 
  

def return_node(n)
  nodeName = n.value
  nodeChildren = n.children
  
  case nodeName
  when  :Program 
    n.child(0).each do |i|
      return i
    end
  when :Function
    e = n.child(3)
    return e
  when  :Block
    i = n.child(0) 
    return i
  when  :TypeDecls
    t = n.child(0)
    n = n.child(1)
    return t,n
   end
end


   

LLVM.init_x86
$symbol_table = Hash.new 
$testMod = LLVM::Module.new("myMod")
$builder = LLVM::Builder.new()
$engine = LLVM::JITCompiler.new($testMod)
$pass_mgr = LLVM::FunctionPassManager.new($engine,$testMod)
#hash to check type
$LLVM_types_hash = {'int' => LLVM::Int,  'double' => LLVM::Double }
$vars = Hash.new #Var=>values hash table
$func_no #number of functions

#---Starting with the code genertion for LLVm using AST nodes#
def llvm_codegen()
  parser = PCParser.new
  tt = parser.parse_file 
  walkNode(tt)  
end

def walkNode(astNode)
#    if  astNode.instance_of? RubyWrite::Node
     nodeVal = astNode.value
     children = astNode.children

    #puts astNode
      case nodeVal
      when  :Program
        programN(astNode)       
      when  :Function
          return create_function(astNode)
      when :BinaryOp
          val = codegen_binary_expr(astNode)
           return val
     # when :Variable
       #  return codegen_expr_var(astNode)
      when :Assignment
        val = codegen_assign(astNode)
        return val
      when :IfStmt
        res = codegen_if_else(astNode)
        return res    
      when :FunctionCall
        res = codegen_func_call(astNode)
      end       
end

    

def programN(node)
  $func_no = 0
  node.child(0).each  do |i| 
   $func_no = $func_no + 1
    walkNode(i)
  end
  $testMod.verify
  $testMod.dump
  value = $engine.run_function($testMod.functions["test"],20,10)
  $testMod.dispose
  $builder.dispose
  print "done\n"
end

def create_function(funcNode)
  type_hash = {'int' => 'int',  'double' => 'double' , 'char' => 'char'} 
  
  ret_type = funcNode.child(0)
  name = funcNode.child(1)
  formals = funcNode.child(2)
  block = funcNode.child(3)

  #Error checking for duplicate named functions remaining
  $vars.clear
  $symbol_table.clear  
  j = 0 
  arg_types = Array.new
  arg_names = Array.new
  formals.each  do |i|
    t = i[0]
    e = i[1]
    arg_types.insert(j,t)
    arg_names.insert(j,e)
    v = type_hash[t]
    if v == "int"
       val = LLVM::Int(1)
    elsif v == "double"
       val == LLVM::Double(1)
    end
    $symbol_table[e] = val
    j = j + 1
    create_args_allocas(v,e)   
  end
 
  #we need to create a function type so that we can add it to the module
  point_func,func = codegen_func_proto(name,arg_types,ret_type) #This should return a function type
  entry = func.basic_blocks.append("entry")
  $builder.position_at_end(entry);   
  block_code =  codegen_block(block)
  $builder.ret(func)
  return func

end


def  codegen_func_proto(name,arg_types,ret_type) 
  new_arg_types = Array.new
  e =0
  arg_types.each do |i| 
    if $LLVM_types_hash.assoc(i)
      new_arg_types[e] = $LLVM_types_hash[i]
      e=e+1
     end
  end

  if ret_type == 'int' 
    new_ret_type = LLVM::Int
  else
    new_ret_type = LLVM::Double
  end
  test = LLVM::Function(new_arg_types,new_ret_type)
  #print test ,"--->params\n"
  fpoint = LLVM::Pointer(test)
  fn =  $testMod.functions.add("test",new_arg_types,new_ret_type) 
  #fn.dump
  return fpoint,fn
end 


def codegen_block(funcBody)
  funcBody.child(0).each do |i|
   #len = $symbol_table.length
   if i.instance_of? Array #declaration
     d = i[0]
     c = i[1]
    # len = len+1
     if d == "int"
       val = LLVM::Int
     elsif d == "Double"
       val == LLVM::Double
     end
     $symbol_table[c] = val
     val = $LLVM_types_hash[d]
     $builder.alloca(val,c)
     next
   end
     nodeval = walkNode(i)
  end
end


def codegen_num(node,varname)
  v = node.value
  l = node.child(0)
  n = l.to_i
  c = LLVM::Int(n)
  v_alloc = $builder.alloca(c,varname)
  $builder.store(c,v_alloc)
  $vars[varname] = c
  return c
end



def another_walk_node(node)
  nval = node.value
  child = node.children
  case nval
  when :ConstInt
    l = node.child(0)
    n = l.to_i
    c = LLVM::Int(n)
    $builder.alloca(c)
    return c
  when :Variable
    v_name = node.child(0)
    var = codegen_expr_var(node)        
    alloc = $builder.alloca(var)
    $builder.load(alloc,v_name)
    return var
  end 
end

def codegen_binary_expr(binode)
  lhs = binode.child(0)
  op = binode.child(1)
  rhs = binode.child(2)

  if op ==  "=="
    var_lhs = codegen_expr_var(lhs)
    r_val  = another_walk_node(rhs)
    if var_lhs == r_val 
         return LLVM::Int(0)
    else 
         return LLVM::Int(1)
    end
  end

  lhs_ret = codegen_child_expr(lhs)

  rhs_ret = codegen_child_expr(rhs)
  #print lhs_ret.dump

  case op
  when '+'
    val =  $builder.add(lhs_ret, rhs_ret,"addtmp")
  when '-'     
      val =  $builder.sub(lhs_ret, rhs_ret,"subtmp")
  when  '*'
    val = $builder.mul(lhs_ret, rhs_ret,"multmp")
  when  '/'
      val =  $builder.div(lhs_ret ,rhs_ret,"divtmp")
  when  '<'
    tmp = $builder.fcmp(:ule, lhs, rhs)
    val =  $builder.(uitofp, tmp, LLVM::Double)
  end
  #alloc = $builder.alloca(val)
  # $builder.load(alloc,")
  return val 
end   

def codegen_child_expr(node)
  e = node.value
  case e
  when  :BinaryOp
    a =  codegen_binary_expr(node)
    return a
  else
    a = another_walk_node(node)
    return  a
  end

end
    
def codegen_assign(node)
  var_name = node.child(0)
  flag = check_init_var(var_name)
  vval =  node.child(1)


  #print vval.value
  if flag == 1
    if vval.value == :ConstInt
      var_val= codegen_num(vval,var_name)   
    elsif vval.value == :BinaryOp
      var_val = codegen_binary_expr(vval)
      alloc = $builder.alloca(var_val)
      $builder.load(alloc,var_name)
    elsif   :Variable
      var_val = codegen_expr_var(vval)
      alloc = $builder.alloca(var_val)
      $builder.load(alloc,var_name)
      return var_val
    else 
      var_val = codegen_func_call(vval)
    end
  end

end

#codegen_var_load(var_name,vval)
#Used to check if a variable being assigned to has been declared
def check_init_var(name)
   if $symbol_table.has_key?(name)
     return 1
   else
   raise RuntimeError ("Uninitialized variable\n")
   end
end

 
#More work to be done
def codegen_expr_var(varnode)
  r = varnode.child(0)
  if $vars.assoc(r)
    var_val =  $vars[r]
    #print val,"val\n" 
    return var_val 
  else
     raise "No such var(Uninitialized variable)"
  end 
end

def codegen_stmt_block(blocknode)
    a = blocknode.child(0)
    b = a.at(0)
    #print b,"---->"
    nodeval = codegen_assign(b)
    return nodeval 
end


def codegen_func_call(node)
   name = node.child(0)
#  func_list =  $testMod.functions 
   print name
  return 
end  

def  codegen_if_else(node)
  cond =  node.child(0)
  if_true_block = node.child(1)
  else_stmt_block = node.child(2)
  cond_expr_val = codegen_binary_expr(cond)

  zero_val = LLVM::Int(0)
  cond_val = $builder.icmp(:eq,zero_val,cond_expr_val,"testcond")

  start_bb = $builder.insert_block
  paren_func = start_bb.parent
  #print start_bb


  then_bb = paren_func.basic_blocks.append("ifthen_branch")
  $builder.position_at_end(then_bb)  
  then_val = codegen_stmt_block(if_true_block)
  new_then_bb = $builder.insert_block

  else_bb = paren_func.basic_blocks.append("else_branch")
  $builder.position_at_end(else_bb)  
  else_val = codegen_stmt_block(else_stmt_block)
  new_else_bb = $builder.insert_block
 
  merge_bb = paren_func.basic_blocks.append("ifthen_branch")
  $builder.position_at_end(merge_bb)  

  
  phi = $builder.phi(LLVM::Int, {  then_bb => then_val ,  else_bb => else_val } ,"res")
  $builder.position_at_end(start_bb) 
  $builder.cond(cond_val,then_bb,else_bb)
  $builder.position_at_end(then_bb)   
  $builder.position_at_end(merge_bb) 
  $builder.position_at_end(else_bb)   
  return phi                                   
  
end

 
def create_args_allocas(vtype,name)
  valtype = $LLVM_types_hash[vtype]
  alloc = $builder.alloca(valtype,name)
end



#-----------------------------------------------------------------------#
#-----------------------------------------------------------------------#
class UnparsePidginC
  def unparse (node)
    boxer = ShadowBoxing.new  do

     rule :Program  do | body|
        v({:is => 0},
          v({},
            *body.children)
       )
      end
      rule :Function do |retvals, name, args, body|
        v({:is => 0},
          h({:hs => 1},
           v({},' ',  retvals),  name,
            "(", h_star({},',',*args),")"),
            body)
      end
      rule :Block do |block| 
      v({  },'{' ,*block.children ,'}') 
      end
      rule :TypeDecls do |type ,vars|
        h({:hs => 0}, type, ' ' , vars , ';')
      end
      rule :Assignment do |lhs,rhs|
        h({:hs => 1}, lhs,'=', rhs,';')
      end
      rule :BinaryOp do |rand1, op, rand2|
        h({:hs => 1}, rand1, op, rand2)
      end
      rule :UnaryOp do |op, rand|
        h({}, op, rand)
      end
      rule :For do |init ,cond1,cond2,cond3, stmts|
        v({},
          v({:is => 2}, h({:hs => 1},init,'(',cond1,cond2,';',cond3 ,')'),'{',
            v({} ,*stmts),'}'))
      end
      rule :WhileStmt do |expr, stmts|
        v({},
          v({:is => 2}, h({}, "while ", expr), stmts),
          "end")
      end
      rule :IfStmt do |test, body|
        v({:is => 2}, h({:hs => 1}, "if", test), body)
      end
      rule :ElseStmt do |body|
        v({:is => 2}, "else", body)
      end
      rule :WhileStmt do |test, body|
        v({},
          v({:is => 2}, h({:hs => 1}, "while", test), body),
            "end")
      end
      rule :BreakStmt do ||
          h({}, "break")
      end
      rule :ContinueStmt do ||
        h({}, "continue")
      end
      rule :ReturnStmt do ||
        h({}, "return")
      end
      rule :PointerVal do |pointer_var|
        h({},'*', pointer_var)
      end
      rule :ArrayDef do |name,args|
        h({},name,'[',*args,']')
      end
      #rule :FunctionCall do |func, args|
      #  h({}, func, "(", args, ")")
      #end
      rule :Formals do |args|
        v({},' ' , *args.children)
      end
      rule :ConstInt do |num|
        h({}, num)
      end
      rule :ConstReal do |num|
        h({}, num)
      end
      rule :ConstString do |str|
        h({}, *str)
      end
      rule :Identifier do |i|
        h({}, i)
      end
      rule :PointerAssignment do |p_var|
        v({}, p_var)
      end
      rule :TypeDecl do |t_var |
        h({},' ' , *t_var)
      end
      rule :FunctionCall do |func_call ,args|
        h({}, *func_call ,"(" ,
          h_star({:hs => 1},',' ,*args.children ) ,")",';')
      end
      rule :Variable  do |var|
        h({}, var)
      end
     rule :Header  do |header|
        v({}, *header)
      end
      rule :Struct  do |s |
        v({},*s.children)
      end
      rule :Struct_name  do |s_a |
        h({},"\n",*s_a.children,)
      end

      rule :Struct_assign do |d |
        h({},' ' ,*d.children,';')
      end
      rule :Struct_end  do |s_e|
        h({},*s_e,';')
      end

      rule :ParallelPragmaBlock do |  pblock| 
         v({ },
            v({ }, *pblock.children) ,)
      end
    end

    box = boxer.unparse_node node
    return box.to_s
  end
end

=begin
Example from http://ruby-doc.org/stdlib-1.9.3/libdoc/optparse/rdoc/OptionParser.html
=end
options={}
opts = OptionParser.new do |opts|
  opts.banner = "ruby pcc.rb -p inpput_file"

  opts.on("-p","--parse", "Parsed output") do |parse|
     options[:p] = parsed_output() 
  end
  opts.on("-u","--unparse", "Unparsed original input") do |unparse|
    options[:u] = unparse()
  end
  opts.on("-llvm","--llvm-code-gen", "LLVM Code generation") do |llvm_codegen|
    options[:ll] = llvm_codegen()
  end
   opts.on("-o","--progam-codegen", "Pragma Code Generation") do |prag|
    options[:o] = new_unparse()
  end
end

opts.parse!(ARGV)

   

       

