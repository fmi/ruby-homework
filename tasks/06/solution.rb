module ArnoldCPM
  KEYPHRASES = {
    i_lied:                         :false_,
    no_problemo:                    :true_,
    because_im_going_to_say_please: :if_,
    bull_shit:                      :else_,
    you_have_no_respect_for_logic:  :end_if,
    get_up:                         :increment,
    get_down:                       :decrement,
    youre_fired:                    :multiply,
    he_had_to_split:                :divide,
    i_let_him_go:                   :modulo,
    you_are_not_you_you_are_me:     :equal_to,
    let_off_some_steam_bennet:      :greater_than,
    consider_that_a_divorce:        :or_,
    knock_knock:                    :and_,
    listen_to_me_very_carefully:    :declare_function,
    i_need_your_clothes_your_boots_and_your_motorcycle: :function_parameter,
    give_these_people_air:          :non_void_function,
    ill_be_back:                    :return_,
    hasta_la_vista_baby:            :end_function_declaration,
    do_it_now:                      :call_function,
    get_your_ass_to_mars:           :assign_invocation_result,
    its_showtime:                   :begin_main,
    you_have_been_terminated:       :end_main,
    talk_to_the_hand:               :print_,
    get_to_the_chopper:             :assign_variable,
    here_is_my_invitation:          :value_set,
    enough_talk:                    :end_assign_variable,
  }

  class Parser < BasicObject
    attr_reader :parsed_body

    def initialize(&program)
      @parsed_body = []
      instance_eval(&program)
    end

    def method_missing(command, *arguments)
      if (KEYPHRASES.keys - %i(i_lied no_problemo)).include? command
        @parsed_body << [command, *arguments].map { |term| KEYPHRASES[term] || term }
      end

      command
    end
  end

  class Scope
    attr_reader :parent_scope

    def initialize(parent_scope = {true_: 1, false_: 0})
      @declared_entities = {}
      @parent_scope      = parent_scope
    end

    def [](resolvee)
      if reference?(resolvee)
        @declared_entities[resolvee] || @parent_scope[resolvee]
      else
        resolvee
      end
    end

    def []=(name, value)
      @declared_entities[name] = self[value]
    end

    private

    def reference?(value)
      value.is_a? Symbol
    end
  end

  class Function
    attr_accessor :void
    alias_method :void?, :void

    def initialize(outer_scope)
      @definition_scope = Scope.new(outer_scope)
      @void             = true
      @parameters       = []
      @body             = []
    end

    def add_parameter(parameter)
      @parameters.push(parameter)
    end

    def add_line(*line)
      @body.push(line)
    end

    def invoke(*arguments)
      execution_scope = Scope.new(@definition_scope)
      @parameters.zip(arguments).each do |parameter, argument|
        execution_scope[parameter] = argument
      end

      catch(:return) do
        Executor.new(@body, execution_scope).execute
      end
    end
  end

  class Executor
    def initialize(body, scope = Scope.new)
      @body  = body
      @scope = scope
      @should_skip = []
      @nested_function_definition_balance = 0
    end

    def execute
      @body.each do |command, *arguments|
        if part_of_ongoing_function_declaration?(command)
          @nested_function_definition_balance += 1 if command == :declare_function
          @nested_function_definition_balance -= 1 if command == :end_function_declaration
          @current_function_definition.add_line(command, *arguments)
        elsif @should_skip.none? || control_flow?(command)
          send(command, *arguments)
        end
      end

      self
    end

    def if_(condition)
      @scope = Scope.new(@scope)
      @should_skip.push(!as_boolean(@scope[condition]))
    end

    def else_
      @should_skip[-1] = !@should_skip.last
    end

    def end_if
      @scope = @scope.parent_scope
      @should_skip.pop
    end

    def increment(amount)
      @entity_value += @scope[amount]
    end

    def decrement(amount)
      @entity_value -= @scope[amount]
    end

    def multiply(multiplicand)
      @entity_value *= @scope[multiplicand]
    end

    def divide(divisor)
      @entity_value /= @scope[divisor]
    end

    def modulo(modulus)
      @entity_value %= @scope[modulus]
    end

    def equal_to(other)
      @entity_value = as_integer(@entity_value == @scope[other])
    end

    def greater_than(other)
      @entity_value = as_integer(@entity_value > @scope[other])
    end

    def or_(other)
      @entity_value = as_boolean(@entity_value) ? @entity_value : @scope[other]
    end

    def and_(other)
      @entity_value = as_boolean(@entity_value) ? @scope[other] : @entity_value
    end

    def assign_variable(name)
      @entity_name = name
    end
    alias_method :assign_invocation_result, :assign_variable

    def value_set(value)
      @entity_value = @scope[value]
    end

    def end_assign_variable
      @scope[@entity_name] = @entity_value
    end

    def end_function_declaration
      @scope[@entity_name] = @current_function_definition
      @current_function_definition = nil
    end
    alias_method :end_main, :end_function_declaration

    def declare_function(name)
      @entity_name = name
      @current_function_definition = Function.new(@scope)
    end

    def function_parameter(name)
      @current_function_definition.add_parameter(name)
    end

    def non_void_function
      @current_function_definition.void = false
    end

    def return_(value = 0)
      throw :return, @scope[value]
    end

    def begin_main
      declare_function :main
    end

    def call_function(name, *arguments)
      function = @scope[name]
      resolved_arguments = arguments.map { |argument| @scope[argument] }
      invocation_result  = function.invoke(*resolved_arguments)

      @scope[@entity_name] = invocation_result unless function.void?
    end

    def print_(value)
      ArnoldCPM.printer.print(@scope[value])
    end

    private

    def as_integer(boolean)
      boolean ? 1 : 0
    end

    def as_boolean(entity)
      entity != 0
    end

    def part_of_ongoing_function_declaration?(command)
      @current_function_definition &&
        (!function_meta?(command) || belongs_to_nested_function?)
    end

    def function_meta?(command)
      [
        :function_parameter,
        :non_void_function,
        :end_function_declaration,
        :end_main,
      ].include?(command)
    end

    def belongs_to_nested_function?
      @nested_function_definition_balance.nonzero?
    end

    def control_flow?(command)
      [:if_, :else_, :end_if].include?(command)
    end
  end

  class << self
    attr_accessor :printer

    def totally_recall(&program)
      parser = Parser.new(&program)

      Executor.new(parser.parsed_body).execute.call_function(:main)
    end
  end
end
