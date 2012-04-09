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


def parsed_output()
    parser = PCParser.new
    tt = parser.parse_file
    tt.prettyprint STDOUT
    puts
end

def unparse()
    parser = PCParser.new
    tt = parser.parse_file
    a = UnparsePidginC.new
    result = a.unparse(tt)
    puts result
end


LLVM.init_x86
$symbol_table = Hash.new 
$testMod = LLVM::Module.new("myMod")
$builder = LLVM::Builder.new()
$engine = LLVM::JITCompiler.new($testMod)
$pass_mgr = LLVM::FunctionPassManager.new($engine,$testMod)
#hash to check type
$LLVM_types_hash = {'int' => LLVM::Int,  'double' => LLVM::Double }



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
          create_function(astNode)
      #when :ConstInt
       #  codegen_num(astNode)      #  return 1,astNode
      when :BinaryOp
         #print nodeVal
          val = codegen_binary_expr(astNode)
     # when :Variable
      #   return codegen_expr_var(astNode)
      when :Assignment
        val = codegen_assign(astNode)
      when :IfStmt
        res = codegen_if_else(astNode)
        return res    
      end       
end

    

def programN(node)
  node.child(0).each  do |i| 
    walkNode(i)
  end
  $testMod.verify
  print $testMod.dump
  value = $engine.run_function($testMod.functions["test"],2 ,10)

end

def create_function(funcNode)
  type_hash = {'int' => 'int',  'double' => 'double' , 'char' => 'char'} 
  
  ret_type = funcNode.child(0)
  name = funcNode.child(1)
  formals = funcNode.child(2)
  block = funcNode.child(3)

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
       val = LLVM::Int
    elsif v == "Double"
       val == LLVM::Double
    end
    $symbol_table[e] = val
    j = j + 1
  end

 
  #we need to create a function type so that we can add it to the module
  point_func,func = codegen_func_proto(name,arg_types,ret_type) #This should return a function type

  create_args_allocas(func,arg_types,arg_names)
  #print func.params,"\n"
  #return 
  entry = func.basic_blocks.append("entry")
  $builder.position_at_end(entry);

  block_code =  codegen_block(block)
  #pos = $builder.insert_block.parent
  #print value.to_f
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
  return fpoint,fn
end 


def codegen_block(funcBody)
  funcBody.child(0).each do |i|
   len = $symbol_table.length
   if i.instance_of? Array #declaration
     d = i[0]
     c = i[1]
     len = len+1
     if d == "int"
       val = LLVM::Int
     elsif d == "Double"
       val == LLVM::Double
     end
 
     $symbol_table[c] = val
     val = $LLVM_types_hash[d]
     $builder.alloca(val,i[1])
     next
   end
    #print $symbol_table,"\n"
    nodeval = walkNode(i)
    #print nodeval,"->nval\n"
  end

end


def  codegen_num(node)
  v = node.value
  l = node.child(0)
  n = l.to_i
  c = LLVM::Int(n)
  v_alloc = $builder.alloca(c)
  $builder.store(c,v_alloc)
  return c
end



def another_walk_node(node)
  nval = node.value
  child = node.children
  case nval
  when :ConstInt
   a =  codegen_num(node)   
   return a
  when :Variable
    a =  codegen_expr_var(node)
    return a
  end 
end

def codegen_binary_expr(binode)
  lhs = binode.child(0)
  op = binode.child(1)
  rhs = binode.child(2)

  lhs_ret = codegen_child_expr(lhs)
  #print lhs_ret 
  rhs_ret = codegen_child_expr(rhs)

  case op
  when '+'
     val =  $builder.add(lhs_ret,rhs_ret,"addtmp")
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
  alloc = $builder.alloca(val)
  # $builder.store(alloc,val)
end   

def codegen_child_expr(node)
  e = node.value
  case e
  when  :BinaryOp
    codegen_binary_expr(node)
  else
    a = another_walk_node(node)
    vret = a
  end
  return vret
end
    
def codegen_assign(node)
  var_name = node.child(0)
  flag = check_init_var(var_name)
  vval =  node.child(1)

  if flag == 1
    if vval.value == :ConstInt
      var_val = codegen_num(vval)   
    elsif :BinaryOp
      var_val = codegen_binary_expr(vval)
    elsif :Variable
       var_val = codegen_var_load(var_name,vval)
    else 
      var_val = codegen_func_call(vval)
    end
  end
 var_val = $builder.alloca(var_val)
 return var_val
end

#codegen_var_load(var_name,vval)

def check_init_var(name)
   if $symbol_table.has_key?(name)
     return 1
   else
   raise RuntimeError ("Uninitialized variable\n")
   end
end

 
#More work to be done
def codegen_expr_var (varnode)
  if $symbol_table.has_value?(v)
      return v
  else
     raise "Uninitialized variable"
  end 
end


def  codegen_if_else(node)
  cond =  node.child(0)
  if_true_block = node.child(1)
  else_stmt_block = node.child(2)
  cond_expr_val = codegen_assign(cond)
  
  zero_val = LLVM::Int(0)

  cond_val = $builder.icmp(:ne,zero_val,cond_expr_val,"if_cond")
 
  start_bb = $builder.insert_block
  paren_func = start_bb.parent
  curr_bb = paren_func.basic_blocks.append("if_branch")

  $builder.position_at_end(curr_bb)

  then_val = codegen_block(if_true_block)
  then_bb = $builder.insert_block

  else_bb = paren_func.basic_blocks.append("else_branch")
  $builder.position_at_end(else_bb)
 
  else_val = codegen_block(else_stmt_block)
  new_else_bb = $builder.insert_block
 
  merge_bb = paren_func.basic_blocks.append("if_else_branch")
  $builder.position_at_end(merge_bb)
 
  incoming = Hash.new["then_val" => LLVM::Int(1) ,"new_else_bb" => LLVM::Int(2)]
  phi = $builder.phi(LLVM::Int,incoming)
  $builder.position_at_end(start_bb)
 
  $builder.position_at_end(then_bb)
  $builder.position_at_end(new_else_bb)
  $builder.position_at_end(merge_bb)

end

 
=begin
    if_branch_bb = builder.insert_block
    builder.position_at_end( else_branch_bb)
    builder.br(merge_bb)
    else_branch_bb = builder.insert_block

    
    builder.position_at_end(merge_bb)
    #hashmap holding the branches
    incoming = Hash.new["if_branch_bb",1 ,"else_branch_bb",2]
    phi = builder.phi(LLVM::Double, incoming ,"")
    return phi;
=end


def  create_alloca_ar (function, var)
  bt = LLVM::Builder.new()      
  bb = LLVM::BasicBlock.new(function)
  r  = LLVM::Value.new()


  bt.position(bb, bb.instructions[0]);
  r = bt.alloca(LLVM::Double.new.type,var)
  bt.dispose
  return r;
end


def create_args_allocas(llvm_func,arg_types,arg_names)
    arg_names.each do |i|
    alloc = $builder.alloca(LLVM::Double(1),"")
    # $builder.store(LLVM::Double(1),alloc)
    end 
end

=begin
    alloca = create_alloca(fname, arg)
    param = LLVMGetParam (fname)
    builder.store(param, alloca)

    if (symbol_table.has_key(arg_name))
      return "duplicate symbol '%s' found", arg
    end
  i=i+1
  end
            
  return NULL;
      
=end

=begin

=end

=begin 
def codegen_prototype (funcnode)
  fn = LLVM::Value.new()
  args_store = LLVM::Value.new()
  args_tys =  LLVM::Value.new()  

  name = funcnode.value
  n = funcnode.children - 1
  i= 0
  while(i < n)
    argument_str  = funcnode.children(i).value
    i = i+1
  end
  #j = 1
  #while(j < n)
  #  names  = funcnode.children(i)
  #  j = j+1
  #end


  if fn.GetNamedFunction(name)
            if fn.basic_blocks
              return "redefinition of function"
            end
            if n != fn.params
              return  "number of arguments different"
            end
          
  else 
    arg_tys = length(argument_types)
    for i in n
      arg_tys[i] = LLVM::Double()
    end
    fn.add(name,arg_types)
    
    args = fn.params
           for i in n
             args_store[i].name=args_str[i]
           end
  end

  return fn;
=end

=begin
def codegen_func(node)
  #node.prettyprint STDOUT
  
  fn = LLVM::Value.new()
  res = LLVM::Value.new()
  bb = LLVM::BasicBlock.new()
          
  symbol_table.clear

  fn = codegen_prototype(node)
  create_argument_allocas(fn,node)
  position_at_end(bb);
  builder.ret(res)
  pass_mgr.run(fn)
  return  fn;

=end



=begin  
  old_scope = Hash.new
  function = LLVM::Value.new()
  alloca = LLVM::Value.new()
  init = LLVM::Value.new()

  
  function = (builder.insert_block).parent
       
  init = varnode.value
          
  alloca = create_alloca_ar(function,init);
  builder.store(init, alloca)
          
  if a = symbol_table[init]
    old_scope[init] = a
  end
    symbol_table.store(init,alloca)

 
  return init

=end

#-----------------------------------------------------------------------#
class UnparsePidginC
  def unparse (node)
    boxer = ShadowBoxing.new  do

     rule :Program  do | body|
        v({:is => 2},
          v({},
            *body.children)
       )
      end
      rule :Function do |retvals, name, args, body|
        v({:is => 0},
          h({:hs => 1},
           h_star({}, " , ", retvals), 
                name,
            "(", h_star({}, ", ", args), ")"),
            body)
      end
      rule :Block do |block| 
      v({  },'{' ,*block.children ,'}') end
      rule :Assignment do |lhs,rhs|
        h({:hs => 2}, lhs,'=', rhs,';')
      end
      rule :BinaryOp do |rand1, op, rand2|
        h({:hs => 1}, rand1, op, rand2)
      end
      rule :UnaryOp do |op, rand|
        h({}, op, rand)
      end
      rule :ForStmt do |stmt ,expr, stmts|
        v({},
          v({:is => 2}, h({:hs => 1}, "for",stmt,expr), stmts),
            "end")
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
      rule :PointerDecl do |pointer_var|
        h({},'*', pointer_var)
      end
      rule :ArrayRef do |name,args|
        h({},name,'[',*args.children,']')
      end
      rule :FunctionCall do |func, args|
        h({}, func, "(", args, ")")
      end
      rule :Formals do |args|
        v({}, *args.children)
      end
      rule :ConstInt do |num|
        h({}, num)
      end
      rule :ConstReal do |num|
        h({}, num)
      end
      rule :ConstString do |str|
        h({}, str)
      end
      rule :Identifier do |i|
        h({}, i)
      end
      rule :PointerAssignment do |p_var|
        v({}, p_var)
      end
      rule :TypeDecl do |t_var|
        h({}, t_var)
      end
      rule :FunctionCall do |func_call|
        h({}, func_call)
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
  opts.on("-ll","--llvm-code-gen", "LLVM Code generation") do |llvm_codegen|
    options[:ll] = llvm_codegen()
  end
end

opts.parse!(ARGV)

   

       

