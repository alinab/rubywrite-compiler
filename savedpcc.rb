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
symbol_table = Hash.new{|k,v| k[v] = 0}
testMod = LLVM::Module.new("myMod")
builder = LLVM::Builder.new()
engine = LLVM::JITCompiler.new(testMod)
pass_mgr = LLVM::FunctionPassManager.new(engine,testMod)


#---Starting with the code genertion for LLVm using AST nodes#
def llvm_codegen()
  parser = PCParser.new
  tt = parser.parse_file 
  walkNode(tt)  
end

def walkNode(astNode)

    if  astNode.instance_of? RubyWrite::Node
    nodeVal = astNode.value
    children = astNode.children

    #puts astNode
      case nodeVal
      when  :Program
         programN(astNode)       
       when  :Function
           codegen_func(astNode)
      when :Binop
        codegen_expr_bin(astNode)
      when :If
         codegen_expr_if_cond(astNode)
      when :Variable
        codegen_var(astNode)
       when :ConsInt
        codegen_expr_num(astNode)
    end       
   end
end

    

def programN(node)
  node.each_child  do |i| 
    walkNode(i)
  end
end

def create_function(basicblock)
    funcBuild = LLVM::Builder.new()
    funcBasicBlock = LLVM::BasicBlock.new(basicblock)
    refVal = LLVM::Value.new.to_ptr   
    allocVal = funcBuild.alloca(LLVM::Int)
    return refVal
end

def  codegen_expr_num (node)
  v = node.value
  return LLVM::ConstantReal.node.parse(LLVM::Double(v),v)
end



def codegen_expr_bin(binexpr)
  lhs = binexpr.child(0)
  op = binexpr.child(1)
  # i = binexpr.child(2)
  rhs = binexpr.child(0)
  
  if op == '='
    name = lhs     
    if !(symbol_table.has_key(name))
      return "unknown var %s", name
    end
    builder.store(var,rhs)
    return lhs
  end

  
  case op
  when  '+'
    return builder.fadd(lhs, rhs, "")
  when '-' 
    return builder.fsub(lhs, rhs, "")
  when  '*'
    return builder.fmul(lhs, rhs, "")
  when  '<'
        tmp = builder.fcmp(:ord, lhs, rhs, "")
    return builder.(uitofp, tmp, LLVM::Double(tmp), "")
  end

end   



#Have to get hold of the If node
def  codegen_expr_if_cond(node)
    cond =  LLVM::Value.new()
    function =   LLVM::Value.new()
    if_br  =  LLVM::Value.new()
    else_br =  LLVM::Value.new()
    phi_func =  LLVM::Value.new()

    if_branch_bb     = LLVM::BasicBlock.new()
    else_branch_bb     = LLVM::BasicBlock.new()
    merge_bb = LLVM::BasicBlock.new()


    n = node.value
    cond = n.child(1)#the condition is at the second position in the AST
 
    function = parent(builder.insert_block)
    if_branch_bb = function.basic_blocks.append("")
    else_branch_bb = function.basic_blocks.append("")
    merge_bb = function.basic_blocks.append("")

    builder.cond(cond,if_branch_bb, else_branch_bb)
    builder.position_at_end(if_branch_bb)
    if_branch_bb = builder.insert_block
    builder.position_at_end( else_branch_bb)
    builder.br(merge_bb)
    else_branch_bb = builder.insert_block

    
    builder.position_at_end(merge_bb)
    #hashmap holding the branches
    incoming = Hash.new["if_branch_bb",1 ,"else_branch_bb",2]
    phi = builder.phi(LLVM::Double, incoming ,"")
    return phi;
end


def  create_alloca_ar (function, var)
  bt = LLVM::Builder.new()      
  bb = LLVM::BasicBlock.new(function)
  r  = LLVM::Value.new()


  bt.position(bb, bb.instructions[0]);
  r = bt.alloca(LLVM::Double.new.type,var)
  bt.dispose
  return r;
end

def create_argument_allocas (fname,function)
    
  param = LLVM::Value.new()
  alloca = LLVM::Value.new()
  arg_name = function.children

  np = fname.params
  i = 0
  while(i < np)
    arg = arg_name(i)
    alloca = create_alloca(fname, arg)
    param = LLVMGetParam (fname)
    builder.store(param, alloca)

    if (symbol_table.has_key(arg_name))
      return "duplicate symbol '%s' found", arg
    end
  i=i+1
  end
            
  return NULL;
      
end
 
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
end


def codegen_func (node)
  fn = LLVM::Value.new()
  res = LLVM::Value.new()
  bb = LLVM::BasicBlock.new(fn)
          
  c = node.children
    
  symbol_table.clear

  fn = codegen_prototype(node)
  create_argument_allocas(fn,node)
  position_at_end(bb);
  builder.ret(res)
  pass_mgr.run(fn)
  return  fn;

end


def codegen_expr_var (varnode)
  
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
    symbol_table.store(init,alloca          

 
  return init

end

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

   

       
