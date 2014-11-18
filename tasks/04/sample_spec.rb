describe 'Command Line Toolkit' do

  RSpec::Matchers.define :render_as do |expected|
    unindent     = -> text { text.gsub(/^#{text.scan(/^\s*/).min_by{|l|l.length}}/, '') }
    rstrip_lines = -> text { text.lines.map(&:rstrip).join("\n") }

    match do |actual|
      actual_text   = rstrip_lines.call(UI::TextScreen.draw(&actual).to_s)
      expected_text = rstrip_lines.call(unindent.call(expected))

      expect(actual_text).to eq expected_text
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

  it 'applies downcase to simple components' do
    expect do
      label text: 'SOME'
      label text: 'VERY', style: :downcase
    end.to render_as <<-RESULT
      SOMEvery
    RESULT
  end
end
