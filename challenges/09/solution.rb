class Memoizer < BasicObject
  def initialize(target)
    @target = target
    @cache  = {}
  end

  def method_missing(name, *args, &block)
    super unless @target.respond_to? name
    return @target.public_send name, *args, &block if block

    cache_key = [name, args]

    if @cache.key? cache_key
      @cache[cache_key]
    else
      @cache[cache_key] = @target.public_send name, *args
    end
  end
end
