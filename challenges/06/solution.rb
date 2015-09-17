class Class
  def attr_initializer(*labels)
    define_method(:initialize) do |*args|
      if args.length != labels.length
        raise ArgumentError.new("wrong number of arguments (#{args.length} for #{labels.length})")
      else
        labels.zip(args).each do |label, arg|
          instance_variable_set("@#{label}", arg)
        end
      end
    end
  end
end
