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
    @components <=> Version.new(other).components
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
      @start_version <= version && @end_version > version
    end

    def each
      current_version = @start_version

      while current_version < @end_version
        yield current_version

        current_version = increment_version(current_version)
      end
    end

    private

    def increment_version(version)
      components = version.components(3)

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
