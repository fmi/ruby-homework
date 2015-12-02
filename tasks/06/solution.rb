module TurtleGraphics
  module Canvas
    class Matrix
      def draw(canvas)
        canvas
      end
    end

    class ASCII
      def initialize(symbols)
        @symbols = symbols
      end

      def draw(canvas)
        maximum_steps = canvas.map(&:max).max

        canvas.map do |row|
          row.map do |steps|
            symbol_for_step_count(steps, maximum_steps)
          end.join('')
        end.join("\n")
      end

      private

      def symbol_for_step_count(steps, maximum_steps)
        intensity = steps.to_f / maximum_steps
        symbol_index = (intensity * (@symbols.size - 1)).ceil

        @symbols[symbol_index]
      end
    end

    class HTML
      TEMPLATE = <<-TEMPLATE.freeze
        <!DOCTYPE html>
        <html>
        <head>
          <title>Turtle graphics</title>

          <style>
            table {
              border-spacing: 0;
            }

            tr {
              padding: 0;
            }

            td {
              width: %{pixel_size}px;
              height: %{pixel_size}px;

              background-color: black;
              padding: 0;
            }
          </style>
        </head>
        <body>
          <table>%{rows}</table>
        </body>
        </html>
      TEMPLATE

      def initialize(pixel_size = 3)
        @pixel_size = pixel_size
      end

      def draw(canvas)
        maximum_intensity = canvas.map(&:max).max

        TEMPLATE % {
          pixel_size: @pixel_size,
          rows: table_rows(canvas, maximum_intensity.to_f)
        }
      end

      private

      def table_rows(canvas, maximum_intensity)
        canvas.map do |row|
          columns = row.map do |intensity|
            '<td style="opacity: %.2f"></td>' % (intensity / maximum_intensity)
          end

          "<tr>#{columns.join('')}</tr>"
        end.join('')
      end
    end
  end

  class Turtle
    ORIENTATIONS = [:left, :up, :right, :down].freeze

    def initialize(rows, columns)
      @canvas = Array.new(rows) { [0] * columns }

      @rows        = rows
      @columns     = columns
      @x           = 0
      @y           = 0
      @orientation = :right
    end

    def draw(canvas = Canvas::Matrix.new, &block)
      instance_eval &block

      @canvas[@y][@x] += 1

      canvas.draw(@canvas)
    end

    private

    def spawn_at(y, x)
      @y = y
      @x = x
    end

    def look(orientation)
      @orientation = orientation
    end

    def move
      @canvas[@y][@x] += 1

      case @orientation
        when :left  then @x -= 1
        when :up    then @y -= 1
        when :right then @x += 1
        when :down  then @y += 1
      end

      @y %= @rows
      @x %= @columns
    end

    def turn_left
      @orientation = ORIENTATIONS[(ORIENTATIONS.find_index(@orientation) - 1) % 4]
    end

    def turn_right
      @orientation = ORIENTATIONS[(ORIENTATIONS.find_index(@orientation) + 1) % 4]
    end
  end
end
