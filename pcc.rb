cwd = File.dirname(__FILE__)
$:.unshift cwd, cwd + '/RubyWrite/lib'

require 'rubywrite'
require 'optparse'
require 'PCParse/pcparser'
require 'shadow_boxing'

def parsed_output()
    parser = PCParser.new
    tt = parser.parse_file
    tt.prettyprint STDOUT
    puts
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
end

opts.parse!(ARGV)

class UnparsePidginC
  def unparse (node)
    boxer = ShadowBoxing.new  do
      rule :Program  do | body|
        v({:is => 2},
          h({},
            body)
       )
      end
      rule :Function do |retvals, name, args, body|
        v({:is => 2},
          h({},
                "function ",
            "(", h_star({}, ", ", retvals), ") = ",
                name,
            "(", h_star({}, ", ", args), ")"),
            body)
      end
      rule :Block do |stmts| v({}, *stmts.children)
      end
      rule :Assignment do |lhs, op, rhs|
        h({:hs => 1}, lhs, op, rhs)
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
      rule :ArrayRef do |type|
        h({}, type)
      end
      rule :FunctionCall do |func, args|
        h({}, func, "(", args, ")")
      end
      rule :Formals do |args|
        h({}, *args.children)
      end
      rule :ConstInt do |num|
        h({}, num)
      end
      rule :ConstReal do |num|
        h({}, num)
      end
      rule :ConstString do |num|
        h({}, num)
      end
      rule :Identifier do |i|
        h({}, i)
      end
    end

    box = boxer.unparse_node node
    return box.to_s
  end
end
  


def unparse
    parser = PCParser.new
    tt = parser.parse_file
    a = UnparsePidginC.new
    result = a.unparse(tt)
    puts result
end

unparse()
   

       

