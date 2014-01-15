module Asm
  class Register
    attr_reader :value

    def initialize
      @value = 0
    end

    def mov(source)
      @value = get_value(source)
    end

    def inc(source)
      @value += get_value(source || 1)
    end

    def dec(source)
      @value -= get_value(source || 1)
    end

    def cmp(source)
      self.class.flag_register_value = @value <=> get_value(source)
    end

    private

    def get_value(source)
      source.is_a?(self.class) ? source.value : source
    end

    class << self
      attr_accessor :flag_register_value
    end
  end

  class Asm
    REGISTERS = [:ax, :bx, :cx, :dx]

    REGISTER_ACTIONS = [:mov, :inc, :dec, :cmp]

    JUMPS = {
      jmp: -> { true },
      je:  -> { Register.flag_register_value == 0 },
      jne: -> { Register.flag_register_value != 0 },
      jl:  -> { Register.flag_register_value < 0 },
      jle: -> { Register.flag_register_value <= 0 },
      jg:  -> { Register.flag_register_value > 0 },
      jge: -> { Register.flag_register_value >= 0 },
    }

    REGISTER_ACTIONS.each do |register_action|
      define_method register_action do |target, value = nil|
        queue_operation target, register_action, value
      end
    end

    JUMPS.each do |jump_name, check|
      define_method jump_name do |target|
        queue_jump target, check
      end
    end

    def initialize
      @commands = []
      @labels = Hash.new { |_, key| key }
      @instruction_pointer = 0
      @registers = Hash.new { |hash, key| hash[key] = Register.new }
    end

    def label(destination)
      @labels[destination] = @commands.length
    end

    def method_missing(name, *args, &block)
      REGISTERS.member?(name) ? @registers[name] : name
    end

    def run
      while @instruction_pointer < @commands.length
        @instruction_pointer = @commands[@instruction_pointer].call
      end

      self
    end

    def dump_registers
      REGISTERS.map { |register_name| @registers[register_name].value }
    end

    def self.compile(&block)
      new.tap { |environment| environment.instance_eval(&block) }
    end

    private

    def queue_jump(target, check)
      @commands << -> do
        check.call ? @labels[target] : @instruction_pointer + 1
      end
    end

    def queue_operation(target, register_action, value)
      @commands << -> do
        target.send register_action, value

        @instruction_pointer + 1
      end
    end
  end

  def self.asm(&block)
    Asm.compile(&block).run.dump_registers
  end
end
