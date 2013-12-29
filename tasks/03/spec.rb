describe "Graphics" do
  it "is defined as a top-level constant" do
    Object.const_defined?(:Graphics).should be_true
  end

  describe "Canvas" do
    let(:canvas) { make_canvas 30, 20 }
    it "can be created with a width and height" do
      make_canvas 10, 20
    end

    it "can't be constructed with no arguments" do
      expect { Graphics::Canvas.new }.to raise_error(ArgumentError)
    end

    it "exposes its width and height via getters" do
      canvas = make_canvas 5, 10
      canvas.width.should eq 5
      canvas.height.should eq 10
    end

    it "does not expose setters for the width or height" do
      canvas.should_not respond_to :width=
      canvas.should_not respond_to :height=
      expect { canvas.width = 100 }.to raise_error(NoMethodError)
    end

    it "allows checking if a pixel at a given x and y is set" do
      canvas.pixel_at?(0, 0).should be_false
      canvas.pixel_at?(4, 6).should be_false
    end

    it "responds to calls to set_pixel with two arguments" do
      canvas.set_pixel 1, 2
    end

    it "allows setting a pixel at a given x and y" do
      canvas.pixel_at?(3, 5).should be_false
      canvas.set_pixel(3, 5)
      canvas.pixel_at?(3, 5).should be_true
    end

    context "drawing of shapes and rasterization" do
      context "of points" do
        it "works for a single one" do
          canvas.pixel_at?(2, 4).should be_false
          canvas.draw make_point(2, 4)
          canvas.pixel_at?(2, 4).should be_true
        end

        it "works for multiple ones" do
          canvas = make_canvas 4, 4
          canvas.set_pixel 0, 0
          canvas.set_pixel 0, 1
          canvas.set_pixel 1, 2
          canvas.set_pixel 2, 2
          canvas.set_pixel 4, 4

          check_rendering_of canvas, '
            @---
            @---
            -@@-
            ----
          '
        end
      end

      context "of lines" do
        it "works with simple horizontal lines" do
          canvas = make_canvas 8, 3
          canvas.draw make_line(make_point(3, 1), make_point(6, 1))

          check_rendering_of canvas, '
            --------
            ---@@@@-
            --------
          '
        end

        it "works with vertical lines" do
          canvas = make_canvas 8, 8
          canvas.draw make_line(make_point(1, 0), make_point(1, 6))

          check_rendering_of canvas, '
            -@------
            -@------
            -@------
            -@------
            -@------
            -@------
            -@------
            --------
          '
        end

        it "works with lines with a small slope" do
          canvas = make_canvas 10, 5
          canvas.draw make_line(make_point(1, 1), make_point(8, 3))

          check_rendering_of canvas, '
            ----------
            -@@-------
            ---@@@@---
            -------@@-
            ----------
          '
        end

        it "works with lines with a significant slope, with swapped ends" do
          canvas = make_canvas 10, 10
          canvas.draw make_line(make_point(3, 8), make_point(1, 1))

          check_rendering_of canvas, '
            ----------
            -@--------
            -@--------
            --@-------
            --@-------
            --@-------
            --@-------
            ---@------
            ---@------
            ----------
          '
        end

        it "works with multiple lines" do
          canvas = make_canvas 10, 5
          canvas.draw make_line(make_point(1, 1), make_point(8, 3))
          canvas.draw make_line(make_point(1, 0), make_point(1, 3))

          check_rendering_of canvas, '
            -@--------
            -@@-------
            -@-@@@@---
            -@-----@@-
            ----------
          '
        end

        it "draws lines with two equal ends as points" do
          canvas = make_canvas 3, 3
          canvas.draw make_line(make_point(1, 1), make_point(1, 1))

          check_rendering_of canvas, '
            ---
            -@-
            ---
          '
        end
      end

      context "of rectangles" do
        it "works with simple rects" do
          canvas = make_canvas 10, 5
          canvas.draw make_rectangle(make_point(1, 1), make_point(8, 3))

          check_rendering_of canvas, '
            ----------
            -@@@@@@@@-
            -@------@-
            -@@@@@@@@-
            ----------
          '
        end

        it "works with rects defined with their bottom left and top right points" do
          canvas = make_canvas 10, 5
          canvas.draw make_rectangle(make_point(1, 3), make_point(8, 1))

          check_rendering_of canvas, '
            ----------
            -@@@@@@@@-
            -@------@-
            -@@@@@@@@-
            ----------
          '
        end

        it "works with rects with a zero height as a line" do
          canvas = make_canvas 10, 3
          canvas.draw make_rectangle(make_point(1, 1), make_point(8, 1))

          check_rendering_of canvas, '
            ----------
            -@@@@@@@@-
            ----------
          '
        end

        it "works with rects with a zero width and height as a single point" do
          canvas = make_canvas 3, 3
          canvas.draw make_rectangle(make_point(1, 1), make_point(1, 1))

          check_rendering_of canvas, '
            ---
            -@-
            ---
          '
        end
      end

      it "renders multiple drawn shapes" do
        canvas = make_canvas 15, 15
        canvas.draw make_rectangle(make_point(2, 2), make_point(12, 12))
        canvas.draw make_rectangle(make_point(0, 0), make_point(14, 14))
        canvas.draw make_line(make_point(4, 8), make_point(7, 8))
        canvas.draw make_line(make_point(4, 6), make_point(10, 4))
        canvas.draw make_point(4, 9)

        check_rendering_of canvas, '
          @@@@@@@@@@@@@@@
          @-------------@
          @-@@@@@@@@@@@-@
          @-@---------@-@
          @-@------@@-@-@
          @-@---@@@---@-@
          @-@-@@------@-@
          @-@---------@-@
          @-@-@@@@----@-@
          @-@-@-------@-@
          @-@---------@-@
          @-@---------@-@
          @-@@@@@@@@@@@-@
          @-------------@
          @@@@@@@@@@@@@@@
        '
      end
    end
  end

  describe "Renderers" do
    describe "Ascii" do
      let(:ascii) { Graphics::Renderers::Ascii }
      let(:canvas) { make_canvas 4, 3 }

      it "renders a grid of the size of the canvas" do
        lines = canvas.render_as(ascii).split("\n")

        lines.size.should eq 3
        lines.first.size.should eq 4
      end

      it "renders blank canvases" do
        canvas.render_as(ascii).should eq rendering('
          ----
          ----
          ----
        ')
      end

      it "renders simple canvases" do
        canvas.set_pixel 0, 0
        canvas.set_pixel 3, 2

        canvas.render_as(ascii).should eq rendering('
          @---
          ----
          ---@
        ')
      end
    end

    describe "Html" do
      let(:html)        { Graphics::Renderers::Html }
      let(:canvas)      { make_canvas 4, 3 }
      let(:blank_pixel) { '<i></i>' }
      let(:full_pixel)  { '<b></b>' }
      let(:line_break)  { '<br>' }

      it "returns html" do
        rendering = normalize_html canvas.render_as(html)
        rendering.should include '<!doctypehtml>'
        rendering.should include '<html>'
        rendering.should include '<body>'
        rendering.should include '<style'
        rendering.should match /<divclass="canvas">/
      end

      it "renders a grid of the size of the canvas" do
        lines = html_rendering_of(canvas).split(line_break)

        lines.size.should eq 3
        lines.first.size.should eq 4 * blank_pixel.size
      end

      it "renders simple canvases" do
        canvas.set_pixel 1, 1
        canvas.set_pixel 1, 2

        html_rendering_of(canvas).should eq [
          blank_pixel, blank_pixel, blank_pixel, blank_pixel, line_break,
          blank_pixel, full_pixel,  blank_pixel, blank_pixel, line_break,
          blank_pixel, full_pixel,  blank_pixel, blank_pixel,
        ].join('')
      end

      it "returns the same rendering when called twice" do
        canvas.set_pixel 1, 1
        canvas.set_pixel 1, 2

        first_rendering  = normalize_html canvas.render_as(html)
        second_rendering = normalize_html canvas.render_as(html)

        second_rendering.should eq first_rendering
      end

      def html_rendering_of(canvas)
        rendering = normalize_html canvas.render_as(html)
        rendering.match(/<divclass="canvas">(.*?)<\/div>/)[1]
      end

      def normalize_html(html)
        html.gsub(/\s+/, '').downcase
      end
    end
  end

  context "shapes" do
    describe "Point" do
      it "can be created with two coordinates" do
        make_point(3, 4)
      end

      it "can't be constructed with no arguments" do
        expect { Graphics::Point.new }.to raise_error(ArgumentError)
      end

      it "allows accessing its x and y via getters" do
        point = make_point(100, 42)
        point.x.should eq 100
        point.y.should eq 42
      end

      it "does not allow setting its x and y" do
        point = make_point(1, 2)
        point.should_not respond_to :x=
        expect { point.x = 5 }.to raise_error(NoMethodError)
        expect { point.y = 5 }.to raise_error(NoMethodError)
      end

      context "comparison for equality" do
        let(:a1) { make_point(4, 5) }
        let(:a2) { make_point(4, 5) }
        let(:b)  { make_point(4, 4) }

        it "is true if coordinates are the same" do
          (a1 == a2).should be_true
        end

        it "is false if coordinates differ" do
          (a1 == b).should be_false
        end

        it "works for eql? as well" do
          a1.should eql a2
          a1.should_not eql b
        end

        it "returns the same hash for the same points" do
          a1.hash.should eq a2.hash
        end

        it "returns different hash for different points" do
          a1.hash.should_not eq b.hash
        end
      end
    end

    describe "Line" do
      let(:line) { make_line(make_point(1, 5), make_point(25, 2)) }

      context "initialization" do
        it "requires arguments" do
          expect { Graphics::Line.new }.to raise_error(ArgumentError)
        end

        it "works with two points" do
          make_line make_point(0, 0), make_point(2, 2)
        end

        it "returns its from and to points via getters" do
          line.from.x.should eq 1
          line.from.y.should eq 5
          line.to.x.should eq 25
          line.to.y.should eq 2
        end

        it "does not allow setting its from and to" do
          line.should_not respond_to :from=
          expect { line.from = 42 }.to raise_error(NoMethodError)
          expect { line.to   = 42 }.to raise_error(NoMethodError)
        end

        context "with swapped points" do
          let(:rightmost_point) { make_point 25, 2 }
          let(:leftmost_point)  { make_point 1, 5 }
          let(:inverted_line)   { make_line rightmost_point, leftmost_point }
          let(:vertical_line)   { make_line make_point(1, 8), make_point(1, 1) }

          it "puts the leftmost point in the from field" do
            inverted_line.from.x.should eq 1
            inverted_line.from.y.should eq 5
          end

          it "puts the rightmost point in the to field" do
            inverted_line.to.x.should eq 25
            inverted_line.to.y.should eq 2
          end

          it "puts the top point of vertical lines in the from field" do
            vertical_line.from.x.should eq 1
            vertical_line.from.y.should eq 1
          end

          it "puts the bottom point of vertical lines in the to field" do
            vertical_line.to.x.should eq 1
            vertical_line.to.y.should eq 8
          end
        end
      end

      context "comparison for equality" do
        it "is false if any of the points differ" do
          a = make_line(make_point(1, 1), make_point(10, 14))
          b = make_line(make_point(1, 1), make_point(10, 13))

          (a == b).should be_false
        end

        it "is true if line ends are the same" do
          a = make_line(make_point(1, 1), make_point(10, 14))
          b = make_line(make_point(1, 1), make_point(10, 14))

          (a == b).should be_true
        end

        it "is true if line ends are the same, even if swapped" do
          a = make_line(make_point(1, 1), make_point(10, 14))
          b = make_line(make_point(10, 14), make_point(1, 1))

          (a == b).should be_true
        end

        it "is true if line is vertical and the bottom is given first" do
          a = make_line(make_point(1, 1), make_point(1, 8))
          b = make_line(make_point(1, 8), make_point(1, 1))

          (a == b).should be_true
        end

        it "works with eql? as well" do
          a = make_line(make_point(1, 1), make_point(10, 14))
          b = make_line(make_point(1, 1), make_point(10, 14))
          c = make_line(make_point(3, 1), make_point(10, 14))

          a.should eql b
          a.should_not eql c
        end

        it "returns the same hash if the lines are the same" do
          a = make_line(make_point(1, 1), make_point(10, 14))
          b = make_line(make_point(10, 14), make_point(1, 1))

          a.hash.should eq b.hash
        end

        it "returns a different hash if the lines differ" do
          a = make_line(make_point(1, 1), make_point(10, 14))
          b = make_line(make_point(1, 1), make_point(10, 11))

          a.hash.should_not eq b.hash
        end
      end
    end

    describe "Rectangle" do
      context "initialization" do
        it "requires arguments" do
          expect { Graphics::Rectangle.new }.to raise_error(ArgumentError)
        end

        it "can be created from two points" do
          make_rectangle make_point(0, 0), make_point(10, 10)
        end

        it "allows accessing its left and right points via getters" do
          rect = make_rectangle make_point(3, 4), make_point(7, 8)

          rect.left.x.should eq 3
          rect.left.y.should eq 4
          rect.right.x.should eq 7
          rect.right.y.should eq 8
        end

        it "does not allow setting its x and y" do
          rect = make_rectangle make_point(3, 4), make_point(7, 8)

          rect.should_not respond_to :left=
          expect { rect.left = :foo }.to raise_error(NoMethodError)
          expect { rect.right = make_point(0, 0) }.to raise_error(NoMethodError)
        end

        it "puts the leftmost point in its left field" do
          rect = make_rectangle make_point(7, 0), make_point(4, 1)

          rect.left.x.should eq 4
          rect.left.y.should eq 1
          rect.right.x.should eq 7
          rect.right.y.should eq 0
        end
      end

      context "comparison for equality" do
        it "is false if any of the points differ" do
          a = make_rectangle make_point(1, 1), make_point(10, 14)
          b = make_rectangle make_point(1, 1), make_point(10, 13)

          (a == b).should be_false
        end

        it "is true if rectangle points are the same" do
          a = make_rectangle make_point(1, 1), make_point(10, 14)
          b = make_rectangle make_point(1, 1), make_point(10, 14)

          (a == b).should be_true
        end

        it "is true if rectangle points are the same, even if swapped" do
          a = make_rectangle make_point(1, 1), make_point(10, 14)
          b = make_rectangle make_point(10, 14), make_point(1, 1)

          (a == b).should be_true
        end

        it "is true for rectangles defined with different diagonal corners" do
          a = make_rectangle make_point(1, 1), make_point(10, 5)
          b = make_rectangle make_point(10, 1), make_point(1, 5)

          (a == b).should be_true
        end

        it "works with eql? as well" do
          a = make_rectangle make_point(1, 1), make_point(10, 14)
          b = make_rectangle make_point(1, 1), make_point(10, 14)
          c = make_rectangle make_point(3, 1), make_point(10, 14)

          a.should eql b
          a.should_not eql c
        end

        it "returns the same hash if the rectangles are the same" do
          a = make_rectangle make_point(1, 1), make_point(10, 14)
          b = make_rectangle make_point(10, 14), make_point(1, 1)

          a.hash.should eq b.hash
        end

        it "returns the same hash for rectangles defined with different diagonal corners" do
          a = make_rectangle make_point(1, 1), make_point(10, 5)
          b = make_rectangle make_point(10, 1), make_point(1, 5)

          a.hash.should eq b.hash
        end

        it "returns a different hash if the rectangles differ" do
          a = make_rectangle make_point(1, 1), make_point(10, 14)
          b = make_rectangle make_point(1, 1), make_point(10, 11)

          a.hash.should_not eq b.hash
        end
      end

      context "corners" do
        it "top left" do
          rect = make_rectangle make_point(1, 4), make_point(5, 2)
          rect.top_left.x.should eq 1
          rect.top_left.y.should eq 2
        end

        it "top right" do
          rect = make_rectangle make_point(1, 4), make_point(5, 6)
          rect.top_right.x.should eq 5
          rect.top_right.y.should eq 4
        end

        it "bottom right" do
          rect = make_rectangle make_point(5, 2), make_point(1, 4)
          rect.bottom_right.x.should eq 5
          rect.bottom_right.y.should eq 4
        end

        it "bottom left" do
          rect = make_rectangle make_point(5, 8), make_point(1, 4)
          rect.bottom_left.x.should eq 1
          rect.bottom_left.y.should eq 8
        end
      end
    end
  end

  def make_canvas(*args)
    Graphics::Canvas.new(*args)
  end

  def make_point(*args)
    Graphics::Point.new(*args)
  end

  def make_line(*args)
    Graphics::Line.new(*args)
  end

  def make_rectangle(*args)
    Graphics::Rectangle.new(*args)
  end

  def rendering(text)
    text.strip.gsub(/^\s+/, '')
  end

  def check_rendering_of(canvas, expected)
    ascii = canvas.render_as(Graphics::Renderers::Ascii)
    ascii.should eq rendering(expected)
  end
end
