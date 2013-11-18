class Object
  def thread(*operations)
    operations.reduce(self) do |current_value, operation|
      operation.to_proc.call(current_value)
    end
  end
end
