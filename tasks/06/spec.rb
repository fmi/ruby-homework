describe 'TurtleGraphics' do
  describe 'Turtle' do
    def create_canvas(&block)
      TurtleGraphics::Turtle.new(2, 2).draw(&block)
    end

    describe '#draw' do
      describe '#move' do
        it 'marks where the turtle has moved' do
          canvas = create_canvas { move }
          expect(canvas).to eq [[1, 1], [0, 0]]
        end

        it 'moves the turtle to the start of row when we are at its end' do
          canvas = create_canvas do
            3.times { move }
          end

          expect(canvas[0]).to eq [2, 2]
          expect(canvas[1]).to eq [0, 0]
        end

        it 'moves the turtle to the start of column when we are at its end' do
          canvas = create_canvas do
            turn_right
            2.times { move }
          end

          expect(canvas[0][0]).to be > 0
          expect(canvas[1][0]).to be > 0
          expect(canvas[0][1]).to eq 0
          expect(canvas[1][1]).to eq 0
        end

        it 'keeps the orientation when we get out of column' do
          canvas = create_canvas do
            turn_right
            4.times { move }
          end

          expect(canvas[0][0]).to be > 0
          expect(canvas[1][0]).to be > 0
          expect(canvas[0][1]).to eq 0
          expect(canvas[1][1]).to eq 0
        end


        it 'counts the times we have passed through every cell' do
          canvas = create_canvas do
            2.times { move }
          end

          expect(canvas).to eq [[2, 1], [0, 0]]
        end
      end

      describe '#turn_right' do
        it 'turns the orienation of the turtle right of where we stand' do
          canvas = create_canvas do
            turn_right
            move
          end

          expect(canvas).to eq [[1, 0], [1, 0]]
        end

        it 'rotates the turtle to its initial position after four turns' do
          canvas = create_canvas do
            4.times { turn_right }
            move
          end

          expect(canvas).to eq [[1, 1], [0, 0]]
        end
      end

      describe '#turn_left' do
        it 'turns the orienation of the turtle left of where we stand' do
          canvas = create_canvas do
            turn_left
            move
          end

          expect(canvas).to eq [[1, 0], [1, 0]]
        end

        it 'rotates the turtle to its initial position after four turns' do
          canvas = create_canvas do
            4.times { turn_left }
            move
          end

          expect(canvas).to eq [[1, 1], [0, 0]]
        end
      end

      describe '#spawn_at' do
        it 'moves the turtle to an exact location in the start' do
          canvas = create_canvas { spawn_at(1, 0) }
          expect(canvas).to eq [[0, 0], [1, 0]]
        end
      end

      describe '#look' do
        it 'turns the turtle based on where it should look' do
          canvas = create_canvas do
            turn_left
            look :down
            move
          end

          expect(canvas).to eq [[1, 0], [1, 0]]
        end
      end
    end
  end

  describe 'Canvas::ASCII' do
    it 'renders the proper symbols depending on the intensity' do
      ascii_canvas = TurtleGraphics::Canvas::ASCII.new(['0', '1', '2', '3'])
      ascii = TurtleGraphics::Turtle.new(3, 3).draw(ascii_canvas) do
        move
        turn_right
        move
        2.times { turn_right }
        move
        turn_left
        move
        turn_left
        move
        2.times { turn_right }
        move
      end

      expect(ascii.sub(/\n\z/, '')).to eq [
        '320',
        '110',
        '000'
      ].join("\n")
    end
  end

  describe 'Canvas::HTML' do
    def create_html_canvas(pixel_size=5, &block)
      html_canvas = TurtleGraphics::Canvas::HTML.new(pixel_size)
      TurtleGraphics::Turtle.new(3, 3).draw(html_canvas, &block)
    end

    it 'renders the proper template' do
      canvas = create_html_canvas do
        move
        move
      end

      expect(canvas.gsub(/\s+/, '')).to eq <<-HTML.gsub(/\s+/, '')
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
      width: 5px;
      height: 5px;

      background-color: black;
      padding: 0;
    }
  </style>
</head>
<body>
  <table>
    <tr>
      <td style="opacity: 1.00"></td>
      <td style="opacity: 1.00"></td>
      <td style="opacity: 1.00"></td>
    </tr>
    <tr>
      <td style="opacity: 0.00"></td>
      <td style="opacity: 0.00"></td>
      <td style="opacity: 0.00"></td>
    </tr>
    <tr>
      <td style="opacity: 0.00"></td>
      <td style="opacity: 0.00"></td>
      <td style="opacity: 0.00"></td>
    </tr>
  </table>
</body>
</html>
      HTML
    end

    it 'sets the pixel size of the table' do
      canvas = create_html_canvas(3) { move }
      expect(canvas.gsub(/\s+/, '')).to include <<-HTML.gsub(/\s+/, '')
td {
  width: 3px;
  height: 3px;
      HTML
    end

    it 'changes the opacity of a cell based on the times we have passed' do
      canvas = create_html_canvas do
        move
        turn_right
        move
        2.times { turn_right }
        move
        turn_left
        move
        turn_left
        move
        2.times { turn_right }
        move
      end

      expect(canvas.gsub(/\s+/, '')).to include <<-HTML.gsub(/\s+/, '')
  <table>
    <tr>
      <td style="opacity: 1.00"></td>
      <td style="opacity: 0.67"></td>
      <td style="opacity: 0.00"></td>
    </tr>
    <tr>
      <td style="opacity: 0.33"></td>
      <td style="opacity: 0.33"></td>
      <td style="opacity: 0.00"></td>
    </tr>
    <tr>
      <td style="opacity: 0.00"></td>
      <td style="opacity: 0.00"></td>
      <td style="opacity: 0.00"></td>
    </tr>
  </table>
      HTML
    end
  end

  it 'renders a complex shape' do
    canvas = TurtleGraphics::Turtle.new(20, 20).draw do
      spawn_at 10, 10

      step = 0

      20.times do
        is_left = (((step & -step) << 1) & step) != 0

        if is_left
          turn_left
        else
          turn_right
        end
        step += 1

        move
      end
    end

    expect(canvas).to eq [
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 1, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    ]
  end
end
