describe 'TurtleGraphics' do
  describe 'Turtle' do
    describe '#draw' do
      describe '#move' do
        it 'marks where the turtle has moved' do
          canvas = TurtleGraphics::Turtle.new(2, 2).draw { move }
          expect(canvas).to eq [[1, 1], [0, 0]]
        end
      end

      describe '#turn_right' do
        it 'turns the orienation of the turtle right of where we stand' do
          canvas = TurtleGraphics::Turtle.new(2, 2).draw do
            turn_right
            move
          end

          expect(canvas).to eq [[1, 0], [1, 0]]
        end
      end
    end
  end

  describe 'Canvas::HTML' do
    it 'sets the pixel size of the table' do
      html_canvas = TurtleGraphics::Canvas::HTML.new(3)
      canvas = TurtleGraphics::Turtle.new(2, 2).draw(html_canvas) { move }
      expect(canvas.gsub(/\s+/, '')).to include <<-HTML.gsub(/\s+/, '')
td {
  width: 3px;
  height: 3px;
      HTML
    end
  end
end
