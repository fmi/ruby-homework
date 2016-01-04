describe Spreadsheet do
  describe '#new' do
    it 'creates a non-empty sheet from a string' do
      expect(Spreadsheet.new('foo')).not_to be_empty
    end
  end

  describe '#to_s' do
    it 'returns tables as a string' do
      expect(Spreadsheet.new("foo\tbar\nbaz\tlarodi").to_s).to eq "foo\tbar\nbaz\tlarodi"
    end

    it 'returns the evaluated spreadsheet as a table' do
      sheet = Spreadsheet.new <<-TABLE
        1  2  =ADD(1, B1)
        4  5  6
      TABLE

      expect(sheet.to_s).to eq \
        "1\t2\t3\n" \
        "4\t5\t6"
    end
  end

  describe '#[]' do
    it 'raises an exception for non-existant cells' do
      expect { Spreadsheet.new('foo')['C42'] }.to raise_error(Spreadsheet::Error, /Cell 'C42' does not exist/)
    end

    it 'returns the value of existing cells' do
      sheet = Spreadsheet.new <<-TABLE
        foo  bar
        baz  larodi
      TABLE

      expect(sheet['A2']).to eq 'baz'
    end

    it 'returns the evaluated expression' do
      sheet = Spreadsheet.new("=ADD(2, 2)")

      expect(sheet['A1']).to eq('4')
    end
  end
end
