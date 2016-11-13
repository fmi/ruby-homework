describe CommandParser do
  def add_argument(parser, name, help_name)
    parser.argument(help_name) { |runner, value| runner[name] = value }
  end

  def add_option(parser, name, short, long, description)
    parser.option(short, long, description) do |runner, value|
      runner[name] = value
    end
  end

  def add_option_with_parameter(parser, name, short, long, parameter, description)
    parser.option_with_parameter(short, long, description, parameter) do |runner, value|
      runner[name] = value
    end
  end

  def options_help_messages(parser)
    parser.help.lines.map(&:chomp).drop(1)
  end

  let(:parser) { CommandParser.new('ls') }
  let(:command_runner) { Hash.new(:default) }

  describe '#argument' do
    it 'parses a single argument' do
      parser = CommandParser.new('ls')
      parser.argument('FILE') { |runner, value| runner[:file_name] = value }
      parser.argument('FILE 2') { |runner, value| puts value }

      command_runner = {}
      parser.parse(command_runner, %w(Programming/ruby))

      expect(command_runner[:file_name]).to eq 'Programming/ruby'
    end

    it 'parses multiple arguments' do
      add_argument(parser, :first_file, 'FIRST FILE')
      add_argument(parser, :second_file, 'SECOND FILE')
      add_argument(parser, :third_file, 'THIRD FILE' )

      parser.parse(command_runner, %w(first.rb second.rb other/third.rb))

      expect(command_runner[:first_file]).to eq 'first.rb'
      expect(command_runner[:second_file]).to eq 'second.rb'
      expect(command_runner[:third_file]).to eq 'other/third.rb'
    end
  end

  describe '#option' do
    it 'parses a single option in short form' do
      add_option(parser, :all, 'a', 'all',
                 'do not ignore entries starting with .')

      parser.parse(command_runner, %w(-a))

      expect(command_runner[:all]).to be true
    end

    it 'parses a single option in long form' do
      add_option(parser, :all, 'a', 'all',
                 'do not ignore entries starting with .')

      parser.parse(command_runner, %w(--all))

      expect(command_runner[:all]).to be true
    end

    it 'parses multiple options' do
      add_option(parser, :all, 'a', 'all',
                 'do not ignore entries starting with .')
      add_option(parser, :dir, 'd', 'directory',
                 'list directories themselves, not their contents')

      parser.parse(command_runner, %w(--directory -a))

      expect(command_runner[:dir]).to be true
      expect(command_runner[:all]).to be true
    end
  end

  describe '#option_with_parameter' do
    it 'parses a option with parameter in short format' do
      add_option_with_parameter(parser, :sort, 's', 'sort', 'WORD',
                               'sort by WORD instead of name')

      parser.parse(command_runner, %w(-stime))

      expect(command_runner[:sort]).to eq 'time'
    end

    it 'parses a option with parameter in long format' do
      add_option_with_parameter(parser, :sort, 's', 'sort', 'WORD',
                               'sort by WORD instead of name')

      parser.parse(command_runner, %w(--sort=time))

      expect(command_runner[:sort]).to eq 'time'
    end
  end

  describe '#help' do
    it 'shows basic usage message' do
      expect(parser.help).to eq 'Usage: ls'
    end

    it 'shows single argument' do
      add_argument(parser, :file_name, 'FILE')

      expect(parser.help).to eq 'Usage: ls [FILE]'
    end

    it 'shows multiple arguments' do
      add_argument(parser, :first_file, 'FIRST FILE')
      add_argument(parser, :second_file, 'SECOND FILE')
      add_argument(parser, :third_file, 'THIRD FILE')

      expect(parser.help).to eq 'Usage: ls [FIRST FILE] [SECOND FILE] [THIRD FILE]'
    end

    it 'shows single option help' do
      add_option(parser, :all, 'a', 'all',
                 'do not ignore entries starting with .')

      expect(options_help_messages(parser)).to match_array([
        '    -a, --all do not ignore entries starting with .'
      ])
    end

    it 'shows multiple options help' do
      parser = CommandParser.new('ls')
      add_option(parser, :all, 'a', 'all',
                 'do not ignore entries starting with .')
      add_option(parser, :dir, 'd', 'directory',
                 'list directories themselves, not their contents')

      expect(options_help_messages(parser)).to match_array([
        '    -a, --all do not ignore entries starting with .',
        '    -d, --directory list directories themselves, not their contents'
      ])
    end

    it 'shows options with parameter' do
      parser = CommandParser.new('ls')
      add_option_with_parameter(parser, :sort, 's', 'sort', 'WORD',
                               'sort by WORD instead of name')

      expect(options_help_messages(parser)).to match_array([
        '    -s, --sort=WORD sort by WORD instead of name'
      ])
    end
  end

  describe 'when having options with and without values and parameters' do
    before(:each) do
      add_option(parser, :all, 'a', 'all',
                 'do not ignore entries starting with .')
      add_option(parser, :dir, 'd', 'directory',
                 'list directories themselves, not their contents')

      add_option_with_parameter(parser, :sort, 's', 'sort', 'WORD',
                               'sort by WORD instead of name')

      add_argument(parser, :first_file, 'FIRST FILE')
      add_argument(parser, :second_file, 'SECOND FILE')
    end

    it 'parses all the options and arguments correctly' do
      parser.parse(command_runner, %w(--all -d -ssize first.rb second.rb))

      expect(command_runner[:first_file]).to eq 'first.rb'
      expect(command_runner[:second_file]).to eq 'second.rb'

      expect(command_runner[:all]).to be true
      expect(command_runner[:dir]).to be true

      expect(command_runner[:sort]).to eq 'size'
    end

    it 'generates a correct help usage' do
      header = parser.help.lines.first.chomp
      expect(header).to eq 'Usage: ls [FIRST FILE] [SECOND FILE]'

      expect(options_help_messages(parser)).to match_array([
        '    -a, --all do not ignore entries starting with .',
        '    -d, --directory list directories themselves, not their contents',
        '    -s, --sort=WORD sort by WORD instead of name'
      ])
    end
  end
end
