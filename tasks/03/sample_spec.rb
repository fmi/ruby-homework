describe "Graphics" do
  describe "Canvas" do
    let(:canvas) { make_canvas 30, 20 }

    it "exposes its width and height via getters" do
      canvas = make_canvas 5, 10
      canvas.width.should eq 5
      canvas.height.should eq 10
    end

    it "allows setting a pixel at a given x and y" do
      canvas.pixel_at?(3, 5).should be_false
      canvas.set_pixel(3, 5)
      canvas.pixel_at?(3, 5).should be_true
    end

    it "responds to draw" do
      canvas.should respond_to :draw
    end

    context "drawing of shapes and rasterization" do
      context "of points" do
        it "works for a single one" do
          canvas.pixel_at?(2, 4).should be_false
          canvas.draw make_point(2, 4)
          canvas.pixel_at?(2, 4).should be_true
        end
      end

      context "of lines" do
        it "works with simple horizontal lines" do
          canvas = make_canvas 6, 3
          canvas.draw make_line(make_point(1, 1), make_point(4, 1))

          check_rendering_of canvas, '
            ------
            -@@@@-
            ------
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
      end
    end
  end

  describe "Renderers" do
    describe "Ascii" do
      let(:canvas) { make_canvas 4, 3 }

      it "renders simple canvases" do
        canvas = make_canvas 4, 3

        canvas.set_pixel 0, 0
        canvas.set_pixel 3, 2

        canvas.render_as(Graphics::Renderers::Ascii).should eq rendering('
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
        rendering.should match /<divclass="canvas">/
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
      it "allows accessing its x and y via getters" do
        point = make_point(100, 42)
        point.x.should eq 100
        point.y.should eq 42
      end
    end

    describe "Line" do
      let(:line) { make_line(make_point(1, 5), make_point(25, 2)) }

      context "initialization" do
        it "returns its from and to points via getters" do
          line.from.x.should eq 1
          line.from.y.should eq 5
          line.to.x.should eq 25
          line.to.y.should eq 2
        end
      end
    end

    describe "Rectangle" do
      context "initialization" do
        it "allows accessing its left and right points via getters" do
          rect = make_rectangle make_point(3, 4), make_point(7, 8)

          rect.left.x.should eq 3
          rect.left.y.should eq 4
          rect.right.x.should eq 7
          rect.right.y.should eq 8
        end
      end

      context "corners" do
        it "allows access to the top left one" do
          rect = make_rectangle make_point(1, 4), make_point(5, 2)
          rect.top_left.x.should eq 1
          rect.top_left.y.should eq 2
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
