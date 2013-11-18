class Bitmap
  def initialize(bytes, row_count = bytes.length)
    @bytes = bytes
    @row_count = row_count
  end

  def render(palette = ['.', '#'])
    @bytes.each_slice(@row_count).map do |row|
      row.map { |byte| render_byte(byte, palette) }.join('')
    end.join("\n")
  end

  private

  def render_byte(byte, palette)
    mask = palette.size - 1

    (0..7).step(Math.log2(palette.size)).map do |part|
      palette[((byte & (mask << part)) >> part)]
    end.reverse
  end
end
