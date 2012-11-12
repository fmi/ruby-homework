require 'treetop'
require_relative 'solution'

Treetop.load 'parser'

class ParseError < StandardError; end

class InteractiveShell
  def initialize
    @env = {}
  end

  def execute(line)
    case line
      when /^(\w+)\s*=\s*(.*)$/ then set $1.to_sym, parse($2)
      when /^derive\s+(\w+):\s+(.*)$/ then derive $1.to_sym, parse($2)
      when 'help' then help
      when 'exit' then raise StopIteration
      else evaluate_and_show_value parse(line)
    end
  rescue StopIteration
    raise
  rescue => e
    puts "ERROR: #{e.class} => #{e.message}"
    puts e.backtrace.join("\n")
  end

  def run
    loop do
      print '>> '
      execute gets.chomp
    end
  end

  def parse(string)
    result = ArithmeticParser.new.parse(string)
    raise ParseError if result.nil?
    Expr.build result.to_sexp
  end

  def set(variable, expr)
    @env[variable] = expr.evaluate(@env)
  end

  def derive(variable, expr)
    puts "-> #{expr.derive(variable)}"
  end

  def help
    puts <<END
Ruby Course, Assignment 3 - Expressions Interpreter

- type an expression to evaluate it:
  2 + cos(1) * 7
- you can assign values to variables:
  y = 3 + 5
- you can derive expressions:
  derive x: x * y + x * x + cos(x)

END
  end

  def evaluate_and_show_value(expr)
    value = expr.evaluate(@env)
    puts "-> #{value}"
  end
end

InteractiveShell.new.run
