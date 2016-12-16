class DrunkProxy < BasicObject
  def initialize(targets)
    @targets = targets
  end

  def method_missing(method, *args, &block)
    compatible_targets = @targets.select { |target| target.respond_to? method }

    if compatible_targets.count > 0
      compatible_targets.map { |target| target.public_send method, *args, &block }
    else
      super
    end
  end
end
