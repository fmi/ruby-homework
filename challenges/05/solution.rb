module Enumerable
  def split_up(length:, step: length, pad: [], &block)
    each_slice(step).map { |slice| (slice + pad).take length }.tap do |slices|
      slices.each(&block) if block
    end
  end
end
