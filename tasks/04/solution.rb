module UI
  class Component
    attr_writer :styler

    def initialize(parent)
      @parent = parent
      @styler = -> text { text }
    end

    def stylize(text)
      text = @parent.stylize(text) if @parent
      @styler.call text
    end
  end

  class Label < Component
    def initialize(parent, text)
      super(parent)
      @text = text
    end

    def width
      @text.size
    end

    def height
      1
    end

    def row_to_string(row)
      stylize @text
    end
  end

  class BorderDecorator
    def initialize(component, border)
      @component = component
      @border = border
    end

    def width
      @component.width + 2 * @border.length
    end

    def height
      @component.height
    end

    def stylize(text)
      @component.stylize text
    end

    def row_to_string(row)
      component_string = @component.row_to_string(row)
      "#{@border}#{component_string.ljust(@component.width)}#{@border}"
    end
  end

  class Container < Component
    attr_reader :components

    def initialize(parent = nil, &block)
      super(parent)
      @components = []
      instance_eval(&block)
    end

    def vertical(border: nil, style: nil, &block)
      add decorate(VerticalGroup.new(self, &block), border, style)
    end

    def horizontal(border: nil, style: nil, &block)
      add decorate(HorizontalGroup.new(self, &block), border, style)
    end

    def label(text:, border: nil, style: nil)
      add decorate(Label.new(self, text), border, style)
    end

    private

    def add(component)
      @components << component
    end

    def decorate(component, border, style)
      component.styler = :downcase.to_proc if style == :downcase
      component.styler = :upcase.to_proc   if style == :upcase
      component = BorderDecorator.new(component, border) if border
      component
    end
  end

  class VerticalGroup < Container
    def width
      @components.map(&:width).max
    end

    def height
      @components.map(&:height).reduce(:+)
    end

    def row_to_string(row)
      components_reaches = @components.map.with_index do |component, index|
        [component, @components.first(index + 1).map(&:height).reduce(:+)]
      end.select { |_, component_reach| row < component_reach }
      component, component_reach = components_reaches.first
      component.row_to_string(row - component_reach + component.height)
    end
  end

  class HorizontalGroup < Container
    def width
      @components.map(&:width).reduce(:+)
    end

    def height
      @components.map(&:height).max
    end

    def row_to_string(row)
      @components.map { |component| component_to_s component, row }.join
    end

    private

    def component_to_s(component, row)
      if component.height > row
        component.row_to_string row
      else
        " " * component.width
      end
    end
  end

  class TextScreen < HorizontalGroup
    def self.draw(&block)
      new(&block)
    end

    def to_s
      (0...height).map { |row| "#{row_to_string(row)}\n" }.join
    end
  end
end
