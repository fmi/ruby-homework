describe 'Command Line Toolkit' do

  RSpec::Matchers.define :render_as do |expected|
    unindent     = -> text { text.gsub(/^#{text.scan(/^\s*/).min_by{|l|l.length}}/, '') }
    rstrip_lines = -> text { text.lines.map(&:rstrip).join("\n") }

    match do |actual|
      actual_text   = rstrip_lines.call(UI::TextScreen.draw(&actual).to_s)
      expected_text = rstrip_lines.call(unindent.call(expected))

      expect(actual_text).to eq expected_text
    end

    failure_message do |actual|
      "expected:\n#{rstrip_lines.call(unindent.call(expected))}\n" +
      "actual:\n#{rstrip_lines.call(UI::TextScreen.draw(&actual).to_s)}"
    end

    def supports_block_expectations?
      true
    end
  end

  it 'arranges components horizontally by default' do
    expect do
      label text: '1'
      label text: '2'
      label text: '3'
    end.to render_as <<-RESULT
      123
    RESULT
  end

  it 'adding horizontal group does not change the behavior' do
    expect do
      horizontal do
        label text: '1'
        label text: '2'
        label text: '3'
      end
    end.to render_as <<-RESULT
      123
    RESULT
  end

  it 'verical group orders elements vertically' do
    expect do
      vertical do
        label text: '1'
        label text: '2'
        label text: '3'
      end
    end.to render_as <<-RESULT
      1
      2
      3
    RESULT
  end

  it 'handles complex group nestings' do
    expect do
      vertical do
        horizontal do
          label text: '1'
          label text: '2'

          vertical do
            label text: '3'
            horizontal do
              label text: '4'
              vertical do
                label text: '5'
                label text: '6'
              end
            end
          end
        end

        label text: '7'
      end
    end.to render_as <<-RESULT
      123
        45
         6
      7
    RESULT
  end

  it 'wraps vertically-aligned components correctly in border' do
    expect do
      vertical border: '|' do
        label text: 'something'
        label text: 'some'
        label text: 'soommee'
      end
    end.to render_as <<-RESULT
      |something|
      |some     |
      |soommee  |
    RESULT
  end

  it 'handles borders correctly in complex group nestings' do
    expect do
      vertical border: '|' do
        horizontal border: '|' do
          label text: '1', border: '|'
          label text: '2', border: '|'

          vertical border: '|' do
            label text: '3', border: '|'
            horizontal border: '|' do
              label text: '4', border: '|'
              vertical border: '|' do
                label text: '5', border: '|'
                label text: '6', border: '|'
              end
            end
          end
        end

        label text: '7', border: '|'
      end
    end.to render_as <<-RESULT
      |||1||2|||3|       |||
      ||      |||4|||5||||||
      ||      ||   ||6||||||
      ||7|                 |
    RESULT
  end

  it 'applies upcase to simple components' do
    expect do
      label text: 'some', style: :upcase
      label text: 'very'
    end.to render_as <<-RESULT
      SOMEvery
    RESULT
  end

  it 'propagates upcase to child components' do
    expect do
      horizontal do
        label text: 'some'
        label text: 'very'

        vertical style: :upcase do
          label text: 'interesting'
          horizontal do
            label text: 'text'
            vertical do
              label text: 'goes'
              label text: 'here'
            end
          end
        end
      end

      label text: 'get it?'
    end.to render_as <<-RESULT
      someveryINTERESTINGget it?
              TEXTGOES
                  HERE
    RESULT
  end

  it 'applies downcase to simple components' do
    expect do
      label text: 'SOME'
      label text: 'VERY', style: :downcase
    end.to render_as <<-RESULT
      SOMEvery
    RESULT
  end

  it 'propagates downcase to child components' do
    expect do
      horizontal do
        label text: 'SOME'
        label text: 'VERY'

        vertical style: :downcase do
          label text: 'INTERESTING'
          horizontal do
            label text: 'TEXT'
            vertical do
              label text: 'GOES'
              label text: 'HERE'
            end
          end
        end
      end

      label text: 'GET IT?'
    end.to render_as <<-RESULT
      SOMEVERYinterestingGET IT?
              textgoes
                  here
    RESULT
  end

  it 'does not add methods to Object' do
    expect { label text: 'text' }.to raise_error(NoMethodError)
    expect { horizontal { }     }.to raise_error(NoMethodError)
    expect { vertical   { }     }.to raise_error(NoMethodError)
  end

  it 'uses the most specific style for styling' do
    expect do
      horizontal style: :upcase do
        label text: 'aAa'
        horizontal style: :downcase do
          label text: 'bBb'
          label text: 'aAa', style: :upcase
        end
      end

      label text: '!'
    end.to render_as <<-RESULT
      AAAbbbAAA!
    RESULT
  end

  it 'does not conflict outer style with inner border' do
    expect do
      horizontal style: :upcase do
        label text: 'aAa'
        horizontal style: :downcase, border: '|' do
          label text: 'bBb'
          label text: 'aAa', style: :upcase
        end
      end

      label text: '!'
    end.to render_as <<-RESULT
      AAA|bbbAAA|!
    RESULT
  end
end
