$:.unshift "#{File.dirname(__FILE__)}", "#{File.dirname(__FILE__)}/../RubyWrite/"
cwd = File.dirname(__FILE__)
$:.unshift cwd, cwd + '/RubyWrite/lib'

require 'PCParse/pcparser'


# We need to first create a parser object
parser = PCParser.new

# The parser can parse from an array consisting of [token, value] pairs
t = parser.parse_array [[:INT, 'int'],
			[:IDENTIFIER, 'main'],
                        ['(', '('],
                        [')', ')'],
                        ['{', '{'],
                        [:IDENTIFIER, 'x'],
                        ['=',' ='],
                        [:INT_NUM, 10],
                        [';',' ;'],
                        ['}', '}'],
                        [false, false]]
			
#puts ":#{t.prettyprint}["
#"#:'{t.prettyprint"

# The parser can also parse from a file (stdin, actually).
tt = parser.parse_file
tt.prettyprint STDOUT

# prettyprint doesn't print a newline at the end; so, call puts once more
puts
