class P < BasicObject
  class << self
    instance_methods.each do |instance_method|
      undef_method instance_method
    end

    def method_missing(method, *args, &block)
      ::Proc.new { |object| object.send method, *args, &block }
    end

    def to_proc
      ::Proc.new { |object| object }
    end
  end
end
