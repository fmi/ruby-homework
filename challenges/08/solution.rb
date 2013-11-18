class Spy < BasicObject
  class Error < ::NoMethodError
  end

  attr_reader :calls

  def initialize(target)
    @target = target
    @calls = []
  end

  def method_missing(method, *args, &block)
    if @target.respond_to? method
      @calls << method
      @target.public_send method, *args, &block
    else
      ::Kernel.raise Error
    end
  end
end
