describe CommandParser do
  describe '#argument' do
    it 'adds an argument' do
      parser = CommandParser.new('rspec')
      parser.argument('FILE') do |runner, value|
        runner[:file] = value
      end

      command_runner = {}
      parser.parse(command_runner, ['spec.rb'])

      expect(command_runner).to eq({file: 'spec.rb'})
    end
  end

  describe '#option' do
    it 'adds an option' do
      parser = CommandParser.new('rspec')
      parser.option('v', 'version', 'show version number') do |runner, value|
        runner[:version] = value
      end

      command_runner = {}
      parser.parse(command_runner, ['--version'])

      expect(command_runner).to eq({version: true})
    end
  end

  describe '#option_with_parameter' do
    it 'adds an option with argument' do
      parser = CommandParser.new('rspec')
      parser.option_with_parameter('r', 'require', 'require FILE in spec', 'FILE') do |runner, value|
        runner[:username] = value
      end

      command_runner = {}
      parser.parse(command_runner, ['--require=solution.rb'])
      expect(command_runner).to eq({username: 'solution.rb'})
    end
  end

  describe '#help' do
    it 'returns a properly formatted help message' do
      parser = CommandParser.new('rspec')
      parser.argument('SPEC FILE') { |_, _| }
      parser.option('v', 'verbose', 'Verbose mode') { |_, _| }
      parser.option_with_parameter('r', 'require', 'require FILE in spec', 'FILE') { |_, _| }

      header, *options_help_messages = parser.help.lines.map(&:chomp)

      expect(header).to eq 'Usage: rspec [SPEC FILE]'
      expect(options_help_messages).to match_array([
        '    -v, --verbose Verbose mode',
        '    -r, --require=FILE require FILE in spec',
      ])
    end
  end
end
