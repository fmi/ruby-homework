class CommandParser
  class BooleanOption
    def initialize(short, long, description, handler)
      @short = short
      @long = long
      @description = description
      @handler = handler
    end

    def can_handle?(option_arg)
      option_arg == "-#{@short}" || option_arg == "--#{@long}"
    end

    def handle(runner, _)
      @handler.call(runner, true)
    end

    def help
      "-#{@short}, --#{@long} #{@description}"
    end
  end

  class OptionWithParameter
    def initialize(short, long, description, parameter, handler)
      @short = short
      @long = long
      @description = description
      @parameter = parameter
      @handler = handler
    end

    def can_handle?(argument)
      argument.start_with?(short_prefix) || argument.start_with?(long_prefix)
    end

    def handle(runner, argument)
      @handler.call(runner, value(argument))
    end

    def help
      "#{short_prefix}, #{long_prefix}#{@parameter} #{@description}"
    end

    private

    def short_prefix
      "-#{@short}"
    end

    def long_prefix
      "--#{@long}="
    end

    def value(argument)
      if argument.start_with?(short_prefix)
        argument[short_prefix.size..-1]
      elsif argument.start_with?(long_prefix)
        argument[long_prefix.size..-1]
      end
    end
  end

  def initialize(command_name)
    @command_name = command_name
    @argument_names = []
    @argument_handlers = []
    @options = []
  end

  def argument(name, &block)
    @argument_names << name
    @argument_handlers << block
  end

  def option(short, long, description, &block)
    @options << BooleanOption.new(short, long, description, block)
  end

  def option_with_parameter(short, long, description, parameter, &block)
    @options << OptionWithParameter.new(
      short, long, description, parameter, block
    )
  end

  def parse(runner, argv)
    option_arguments = argv.select { |argument| argument.start_with?('-') }
    arguments = argv - option_arguments

    option_arguments.each do |argument|
      option_for_argument(argument).handle(runner, argument)
    end

    @argument_handlers.zip(arguments).each do |handler, option|
      handler.call(runner, option)
    end
  end

  def help
    help_message = "Usage: #{@command_name}"
    help_message << " #{arguments_help}" unless @argument_names.empty?
    help_message << "\n#{options_help}" unless @options.empty?

    help_message
  end

  private

  def option_for_argument(argument)
    @options.find { |option| option.can_handle?(argument) }
  end

  def arguments_help
    @argument_names.map { |name| "[#{name}]" }.join(' ')
  end

  def options_help
    @options.map { |option| "    #{option.help}" }.join("\n")
  end
end
