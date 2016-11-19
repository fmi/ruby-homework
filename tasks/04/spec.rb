require 'tmpdir'

# Make all examples bleeding from the solution spec fail
Version = nil

class RSpec::Core::World
  # Silence the `Run options: include {:actual_spec=>true}` output.
  # It messes up with the JSON parsing in Evans
  def announce_filters
  end
end

# Actually run only examples in this file
RSpec.configure do |c|
  c.filter_manager.include_only actual_spec: true
end

class SpecTester
  def initialize(user_spec)
    @user_spec = user_spec
  end

  def test_solution(code)
    Dir.mktmpdir do |temp_dir|
      Dir.chdir(temp_dir) do
        File.write 'solution.rb', code
        File.write 'solution_spec.rb', @user_spec

        execute('rspec -r ./solution.rb solution_spec.rb')
      end
    end
  end

  def execute(command)
    output = `#{command}`

    return [$?.exitstatus == 0, output]
  end
end

class String
  def indent(levels = 1, indent_spaces = 2)
    lines.map { |line| "#{' ' * indent_spaces * levels}#{line}" }.join('')
  end

  def indent_level(indent_spaces = 2)
    chars.take_while { |c| c =~ /\s/ }.count / indent_spaces
  end
end

class Object
  def call_first_defined(methods, *args, &block)
    method = methods.find { |method| respond_to? method }
    method ||= methods.last

    public_send method, *args, &block
  end
end

user_spec_path = File.join(__dir__, 'solution.rb')
user_spec = File.read(user_spec_path)

RSpec::Matchers.define :pass_tests do
  match do |solution|
    success, @output = SpecTester.new(user_spec).test_solution(solution)

    success
  end

  call_first_defined [:failure_message, :failure_message_for_should] do |actual|
    "expected this solution to pass the tests:\n\n#{actual.indent}\n\n" \
    "RSpec log:\n\n#{@output.indent}"
  end

  call_first_defined [:failure_message_when_negated, :failure_message_for_should_not] do |actual|
    "expected this solution to not pass the tests:\n\n#{actual.indent}"
  end
end

SOLUTION = <<~'RUBY'
  class Version
    VALID_VERSION_REGEXP = /\A\z|\A[0-9]+(\.[0-9]+)*\z/

    include Comparable

    def initialize(version = '')
      unless VALID_VERSION_REGEXP.match(version.to_s)
        raise ArgumentError, "Invalid version string '#{version}'"
      end

      @components = version.to_s
        .split('.')
        .map(&:to_i)
        .reverse
        .drop_while(&:zero?)
        .reverse
    end

    def <=>(other)
      @components <=> Version.new(other).internal_components
    end

    def internal_components(positions = 0)
      padding_size = positions - @components.size

      if padding_size > 0
        @components + [0] * padding_size
      elsif positions != 0
        @components.take(positions)
      else
        @components.dup
      end
    end

    def components(positions = 0)
      padding_size = positions - @components.size

      if padding_size > 0
        @components + [0] * padding_size
      elsif positions != 0
        @components.take(positions)
      else
        @components.dup
      end
    end

    def to_s
      @components.join('.')
    end

    class Range
      include Enumerable

      def initialize(start_version, end_version)
        @start_version = Version.new(start_version)
        @end_version   = Version.new(end_version)
      end

      def include?(version)
        (@start_version <=> version) < 1 && (@end_version <=> version) == 1
      end

      def each
        current_version = @start_version

        while (current_version <=> @end_version) == -1
          yield current_version

          current_version = increment_version(current_version)
        end
      end

      private

      def increment_version(version)
        components = version.internal_components(3)

        components[2] += 1

        components.to_enum.with_index.reverse_each do |_, index|
          component = components[index]

          if component >= 10 && components[index - 1]
            components[index]      = 0
            components[index - 1] += 1
          end
        end

        Version.new(components.join('.'))
      end
    end
  end
RUBY

PASSES_FOR_THE_CORRECT_SOLUTION, _ = SpecTester.new(user_spec).test_solution(SOLUTION)

if !PASSES_FOR_THE_CORRECT_SOLUTION
  RSpec.describe 'spec', actual_spec: true do
    it 'passes for the correct solution' do
      expect(SOLUTION).to pass_tests
    end
  end
else

  RSpec.describe 'spec', actual_spec: true do
    def replace(pattern, code)
      solution        = @solution.lines
      method_def_line = nil
      method_end_line = nil
      method_indent   = nil

      solution.each_with_index do |source_line, line_index|
        if source_line.include? pattern
          method_def_line = line_index
          method_indent   = source_line.indent_level
        elsif method_def_line && !method_end_line &&
              source_line.indent_level == method_indent && source_line.strip == 'end'
          method_end_line = line_index
        end
      end

      raise "Could not find pattern '#{pattern}'" unless method_def_line && method_end_line

      solution[method_def_line..method_end_line] = code.indent(method_indent).lines
      @solution = solution.join('')
    end

    def remove_line(pattern)
      @solution = @solution.lines.reject { |line| line.include? pattern }.join('')
    end

    def insert(className, code)
      solution       = @solution.lines
      class_def_line = nil
      class_indent   = nil

      solution.each_with_index do |source_line, line_index|
        if source_line.include? "class #{className}"
          class_def_line = line_index
          class_indent   = source_line.indent_level
        end
      end

      raise "Could not find pattern '#{pattern}'" unless class_def_line

      solution.insert(class_def_line + 1, *code.indent(class_indent).lines)
      @solution = solution.join('')
    end

    def reset_solution
      @solution = SOLUTION.dup
    end

    before { reset_solution }

    describe 'Version' do
      it 'passes for the correct solution', timeout: 5 do
        expect(@solution).to pass_tests
      end

      it 'checks for ArgumentError with the correct message', timeout: 5 do
        replace 'def initialize(version', <<~'RUBY'
          def initialize(version = '')
            unless VALID_VERSION_REGEXP.match(version.to_s)
              raise ArgumentError, "Invalid version string"
            end

            @components = version.to_s
              .split('.')
              .map(&:to_i)
              .reverse
              .drop_while(&:zero?)
              .reverse
          end
        RUBY

        expect(@solution).to_not pass_tests
      end

      it 'checks for the type of ArgumentError', timeout: 5 do
        replace 'def initialize(version', <<~'RUBY'
          def initialize(version = '')
            unless VALID_VERSION_REGEXP.match(version.to_s)
              raise RuntimeError, "Invalid version string '#{version}'"
            end

            @components = version.to_s
              .split('.')
              .map(&:to_i)
              .reverse
              .drop_while(&:zero?)
              .reverse
          end
        RUBY

        expect(@solution).to_not pass_tests
      end

      it 'checks that initialize can be given an empty string', timeout: 5 do
        replace 'def initialize(version', <<~'RUBY'
          def initialize(version = '')
            unless /\A[0-9]+(\.[0-9]+)*\z/.match(version.to_s)
              raise ArgumentError, "Invalid version string '#{version}'"
            end

            @components = version.to_s
              .split('.')
              .map(&:to_i)
              .reverse
              .drop_while(&:zero?)
              .reverse
          end
        RUBY

        expect(@solution).to_not pass_tests
      end

      it 'checks that initialize can be given no arguments', timeout: 5 do
        replace 'def initialize(version', <<~'RUBY'
          def initialize(version)
            unless VALID_VERSION_REGEXP.match(version.to_s)
              raise ArgumentError, "Invalid version string '#{version}'"
            end

            @components = version.to_s
              .split('.')
              .map(&:to_i)
              .reverse
              .drop_while(&:zero?)
              .reverse
          end
        RUBY

        expect(@solution).to_not pass_tests
      end

      it 'checks for comparison operators positively', timeout: 10 do
        insert 'Version', <<~'RUBY'
          def >(other)
            false
          end
        RUBY
        expect(@solution).to_not pass_tests

        reset_solution

        insert 'Version', <<~'RUBY'
          def <(other)
            false
          end
        RUBY
        expect(@solution).to_not pass_tests

        reset_solution

        insert 'Version', <<~'RUBY'
          def <=(other)
            false
          end
        RUBY
        expect(@solution).to_not pass_tests

        reset_solution

        insert 'Version', <<~'RUBY'
          def >=(other)
            false
          end
        RUBY
        expect(@solution).to_not pass_tests
      end

      it 'checks for comparison operators negatively', timeout: 10 do
        insert 'Version', <<~'RUBY'
          def >(other)
            true
          end
        RUBY
        expect(@solution).to_not pass_tests

        reset_solution

        insert 'Version', <<~'RUBY'
          def <(other)
            true
          end
        RUBY
        expect(@solution).to_not pass_tests

        reset_solution

        insert 'Version', <<~'RUBY'
          def <=(other)
            true
          end
        RUBY
        expect(@solution).to_not pass_tests

        reset_solution

        insert 'Version', <<~'RUBY'
          def >=(other)
            true
          end
        RUBY
        expect(@solution).to_not pass_tests
      end

      it 'tests #components without arguments', timeout: 5 do
        replace 'def components', <<~'RUBY'
          def components(positions)
            padding_size = positions - @components.size

            if padding_size > 0
              @components + [0] * padding_size
            else
              @components.take(positions)
            end
          end
        RUBY

        expect(@solution).to_not pass_tests
      end

      it 'tests #components with less components than present', timeout: 5 do
        replace 'def components', <<~'RUBY'
          def components(positions = 0)
            padding_size = positions - @components.size

            if padding_size > 0
              @components + [0] * padding_size
            elsif positions != 0
              [42, 42, 42, 42, 42]
            else
              @components.dup
            end
          end
        RUBY

        expect(@solution).to_not pass_tests
      end

      it 'tests #components with more components than present', timeout: 5 do
        replace 'def components', <<~'RUBY'
          def components(positions = 0)
            padding_size = positions - @components.size

            if padding_size > 0
              [42, 42, 42, 42, 42]
            elsif positions != 0
              @components.take(positions)
            else
              @components.dup
            end
          end
        RUBY

        expect(@solution).to_not pass_tests
      end

      it 'tests that #components cannot be used to modify the version', timeout: 5 do
        replace 'def components', <<~'RUBY'
          def components(positions = 0)
            padding_size = positions - @components.size

            if padding_size > 0
              @components + [0] * padding_size
            elsif positions != 0
              @components.take(positions)
            else
              @components
            end
          end
        RUBY

        expect(@solution).to_not pass_tests
      end

      it 'does not ignore the order of #components', timeout: 5 do
        replace 'def components', <<~'RUBY'
          def components(positions = 0)
            padding_size = positions - @components.size

            if padding_size > 0
              (@components + [0] * padding_size).reverse
            elsif positions != 0
              @components.take(positions).reverse
            else
              @components.dup.reverse
            end
          end
        RUBY

        expect(@solution).to_not pass_tests
      end

      it 'tests #to_s', timeout: 5 do
        replace 'def to_s', <<~'RUBY'
          def to_s
            '1.2.3'
          end
        RUBY

        expect(@solution).to_not pass_tests
      end
    end

    describe 'Version::Range' do
      it 'tests constructing ranges with strings', timeout: 5 do
        replace 'def initialize(start_version', <<~'RUBY'
          def initialize(start_version, end_version)
            @start_version = start_version
            @end_version   = end_version
          end
        RUBY

        expect(@solution).to_not pass_tests
      end

      it 'tests constructing ranges with versions', timeout: 5 do
        replace 'def initialize(start_version', <<~'RUBY'
          def initialize(start_version, end_version)
            raise 'error' if start_version.is_a?(Version) || end_version.is_a?(Version)

            @start_version = Version.new(start_version)
            @end_version   = Version.new(end_version)
          end
        RUBY

        expect(@solution).to_not pass_tests
      end

      it 'smoke-tests include?', timeout: 5 do
        replace 'def include?', <<~'RUBY'
          def include?(version)
            true
          end
        RUBY

        expect(@solution).to_not pass_tests
      end

      it 'tests include? with versions greater than the start one', timeout: 5 do
        replace 'def include?', <<~'RUBY'
          def include?(version)
            @start_version <= version
          end
        RUBY

        expect(@solution).to_not pass_tests
      end

      it 'tests include? with versions lower than the start one', timeout: 5 do
        replace 'def include?', <<~'RUBY'
          def include?(version)
            @end_version > version
          end
        RUBY

        expect(@solution).to_not pass_tests
      end

      it 'smoke-tests #to_a', timeout: 5 do
        insert 'Range', <<~'RUBY'
          def to_a
            []
          end
        RUBY

        expect(@solution).to_not pass_tests
      end

      it 'tests each #to_a element', timeout: 5 do
        insert 'Range', <<~'RUBY'
          def to_a
            versions = enum_for(:each).to_a
            versions[1..-2] = [42] * (versions.size - 2)
            versions
          end
        RUBY

        expect(@solution).to_not pass_tests
      end
    end
  end

end
