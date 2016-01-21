describe Spreadsheet do
  describe '#new' do
    it 'can be called with no arguments or with a single string argument' do
      Spreadsheet.new
      Spreadsheet.new('')
      Spreadsheet.new('foobar')
    end

    it 'creates a blank sheet when no arguments are passed' do
      expect(Spreadsheet.new).to be_empty
    end

    it 'creates a blank sheet when a blank string is passed' do
      expect(Spreadsheet.new('')).to be_empty
    end

    it 'creates a non-empty sheet when a non-blank string is passed' do
      expect(Spreadsheet.new('foo')).not_to be_empty
    end
  end

  describe '#to_s' do
    it 'returns blank tables as blank strings' do
      expect(Spreadsheet.new.to_s).to eq ''
    end

    it 'returns one-cell tables as a string' do
      expect(Spreadsheet.new('foo').to_s).to eq 'foo'
    end

    it 'returns multi-cell, oneline tables as a string' do
      expect(Spreadsheet.new("foo\tbar\tbaz").to_s).to eq "foo\tbar\tbaz"
    end

    it 'returns multi-cell, multiline tables as a string' do
      expect(Spreadsheet.new("foo\tbar\nbaz\tlarodi").to_s).to eq "foo\tbar\nbaz\tlarodi"
    end

    it 'splits cells by two or more spaces' do
      expect(Spreadsheet.new("foo  bar   42\nbaz    larodi  100").to_s).to eq "foo\tbar\t42\nbaz\tlarodi\t100"
    end

    it 'returns the evaluated spreadsheet as a table' do
      sheet = Spreadsheet.new <<-TABLE
        foo   10  2.1   =ADD(B1, C1, 2.9)
        bar   11  2.2   =DIVIDE(B2, C2)
        baz   12  2.3   =MULTIPLY(C3, B3)
      TABLE

      expect(sheet.to_s).to eq \
        "foo\t10\t2.1\t15\n" \
        "bar\t11\t2.2\t5\n" \
        "baz\t12\t2.3\t27.60"
    end
  end

  describe '#cell_at' do
    it 'raises and exception for non-existant cells' do
      expect { Spreadsheet.new('foo')['B10'] }.to raise_error(Spreadsheet::Error, /Cell 'B10' does not exist/)
    end

    it 'returns the raw value of existing cells' do
      sheet = Spreadsheet.new <<-TABLE
        foo  =ADD(2, 2)
        baz  larodi
      TABLE

      expect(sheet.cell_at('A1')).to eq 'foo'
      expect(sheet.cell_at('B1')).to eq '=ADD(2, 2)'
    end
  end

  describe '#[]' do
    it 'raises an exception for non-existant cells' do
      expect { Spreadsheet.new()['A1'] }.to raise_error(Spreadsheet::Error, /Cell 'A1' does not exist/)
    end

    it 'returns the value of existing cells for simple cell indexes' do
      sheet = Spreadsheet.new <<-TABLE
        foo  bar
        baz  larodi
      TABLE

      expect(sheet['A1']).to eq 'foo'
      expect(sheet['B1']).to eq 'bar'
      expect(sheet['A2']).to eq 'baz'
      expect(sheet['B2']).to eq 'larodi'
    end

    it 'returns the value of existing cells for complex cell indexes' do
      sheet = Spreadsheet.new (["a#{"\tb" * 30}c"] * 20).join("\n")

      expect(sheet['AD1']).to eq 'b'
      expect(sheet['AE1']).to eq 'bc'
      expect(sheet['AE19']).to eq 'bc'
    end

    it 'returns the calculated value of formulae cells' do
      sheet = Spreadsheet.new "foo\tADD(2, 2)\t=ADD(2, 2)"

      expect(sheet['A1']).to eq 'foo'
      expect(sheet['B1']).to eq 'ADD(2, 2)'
      expect(sheet['C1']).to eq '4'
    end

    it 'adds two numbers with ADD' do
      sheet = Spreadsheet.new("=ADD(2, 2)")

      expect(sheet['A1']).to eq('4')
    end

    it 'adds five numbers with ADD' do
      sheet = Spreadsheet.new("=ADD(1, 2, 3, 4, 5)")

      expect(sheet['A1']).to eq('15')
    end

    it 'raises an exception for less than two arguments passed to ADD' do
      expect { Spreadsheet.new('=ADD(1)')['A1'] }.to raise_error(
        Spreadsheet::Error, /Wrong number of arguments for 'ADD': expected at least 2, got 1/
      )

      expect { Spreadsheet.new('=ADD()')['A1'] }.to raise_error(
        Spreadsheet::Error, /Wrong number of arguments for 'ADD': expected at least 2, got 0/
      )
    end

    it 'adds numbers from cell references and as immediate arguments with ADD' do
      sheet = Spreadsheet.new("42  =ADD(1, A1, 2, C1)  10")

      expect(sheet['B1']).to eq('55')
    end

    it 'adds numbers only from cell references with ADD' do
      sheet = Spreadsheet.new("2  3  5  =ADD(B1, A1, C1)  20")

      expect(sheet['D1']).to eq('10')
    end

    it 'multiplies numbers with MULTIPLY' do
      sheet1 = Spreadsheet.new("=MULTIPLY(1, 2, 3, 4, 5)")
      sheet2 = Spreadsheet.new("1  2  3  4  =MULTIPLY(A1, B1, C1, D1, 5)")

      expect(sheet1['A1']).to eq('120')
      expect(sheet2['E1']).to eq('120')
    end

    it 'raises an exception for less than two arguments to MULTIPLY' do
      expect { Spreadsheet.new('=MULTIPLY(1)')['A1'] }.to raise_error(
        Spreadsheet::Error, /Wrong number of arguments for 'MULTIPLY': expected at least 2, got 1/
      )

      expect { Spreadsheet.new('=MULTIPLY()')['A1'] }.to raise_error(
        Spreadsheet::Error, /Wrong number of arguments for 'MULTIPLY': expected at least 2, got 0/
      )
    end

    it 'subtracts two numbers with SUBTRACT' do
      sheet = Spreadsheet.new("=SUBTRACT(5, 3)  10")

      expect(sheet['A1']).to eq('2')
    end

    it 'subtracts numbers via cell references' do
      sheet = Spreadsheet.new("2  3  5  =SUBTRACT(C1, 1)  20")

      expect(sheet['D1']).to eq('4')
    end

    it 'raises an exception when SUBTRACT is called with a wrong number of arguments' do
      expect { Spreadsheet.new('=SUBTRACT(1)')['A1'] }.to raise_error(
        Spreadsheet::Error, /Wrong number of arguments for 'SUBTRACT': expected 2, got 1/
      )

      expect { Spreadsheet.new('=SUBTRACT(1, 2, 3)')['A1'] }.to raise_error(
        Spreadsheet::Error, /Wrong number of arguments for 'SUBTRACT': expected 2, got 3/
      )
    end

    it 'divides two numbers with DIVIDE' do
      sheet = Spreadsheet.new("=DIVIDE(84, 2)  10")

      expect(sheet['A1']).to eq('42')
    end

    it 'divides numbers via cell references' do
      sheet1 = Spreadsheet.new("2  84  =DIVIDE(B1, A1)  20")
      sheet2 = Spreadsheet.new("2  84  =DIVIDE(B1, 84)  20")

      expect(sheet1['C1']).to eq('42')
      expect(sheet2['C1']).to eq('1')
    end

    it 'raises an exception when DIVIDE is called with a wrong number of arguments' do
      expect { Spreadsheet.new('=DIVIDE(1)')['A1'] }.to raise_error(
        Spreadsheet::Error, /Wrong number of arguments for 'DIVIDE': expected 2, got 1/
      )

      expect { Spreadsheet.new('=DIVIDE(1, 2, 3)')['A1'] }.to raise_error(
        Spreadsheet::Error, /Wrong number of arguments for 'DIVIDE': expected 2, got 3/
      )
    end

    it 'calculates the modulo of two numbers with MOD' do
      expect(Spreadsheet.new('=MOD(42, 5)')['A1']).to eq('2')
      expect(Spreadsheet.new('=MOD(5, 5)')['A1']).to eq('0')
      expect(Spreadsheet.new('=MOD(13, 1)')['A1']).to eq('0')
    end

    it 'calculates the modulo of two numbers with MOD via cell references' do
      sheet1 = Spreadsheet.new("10  84  =MOD(B1, A1)  20")
      sheet2 = Spreadsheet.new("5   83  =MOD(B1, 2)  20")

      expect(sheet1['C1']).to eq('4')
      expect(sheet2['C1']).to eq('1')
    end

    it 'raises an exception when MOD is called with a wrong number of arguments' do
      expect { Spreadsheet.new('=MOD(1)')['A1'] }.to raise_error(
        Spreadsheet::Error, /Wrong number of arguments for 'MOD': expected 2, got 1/
      )

      expect { Spreadsheet.new('=MOD(1, 2, 3)')['A1'] }.to raise_error(
        Spreadsheet::Error, /Wrong number of arguments for 'MOD': expected 2, got 3/
      )
    end

    it 'adds floating point numbers with ADD' do
      expect(Spreadsheet.new('10  =ADD(A1, 1.1)')['B1']).to eq '11.10'
      expect(Spreadsheet.new('10  1.1  =ADD(A1, B1)')['C1']).to eq '11.10'
    end

    it 'subtracts floating point numbers with SUBTRACT' do
      expect(Spreadsheet.new('10  =SUBTRACT(A1, 1.1)')['B1']).to eq '8.90'
      expect(Spreadsheet.new('10  1.1  =SUBTRACT(A1, B1)')['C1']).to eq '8.90'
    end

    it 'multiplies floating point numbers with MULTIPLY' do
      expect(Spreadsheet.new('10  =MULTIPLY(A1, 1.1)')['B1']).to eq '11'
      expect(Spreadsheet.new('10  1.1  =MULTIPLY(A1, B1)')['C1']).to eq '11'
    end

    it 'divides floating point numbers with DIVIDE' do
      expect(Spreadsheet.new('10  =DIVIDE(A1, 4)')['B1']).to eq '2.50'
      expect(Spreadsheet.new('10  =DIVIDE(A1, 4.0)')['B1']).to eq '2.50'
      expect(Spreadsheet.new('10  2.5  =DIVIDE(A1, B1)')['C1']).to eq '4'
    end

    it 'evaluates deeply-nested cell references' do
      expect(Spreadsheet.new('10  =ADD(5, A1)  3  =DIVIDE(B1, C1)  =MOD(D1, 4)')['E1']).to eq '1'
    end

    it 'raises an exception for unknown functions' do
      expect { Spreadsheet.new('=FOO(42)  100')['A1'] }.to raise_error(
        Spreadsheet::Error, /Unknown function 'FOO'/
      )
    end

    it 'raises an exception for missing cells passed as function arguments' do
      expect { Spreadsheet.new('=ADD(1, B4)  100')['A1'] }.to raise_error(
        Spreadsheet::Error, /Cell 'B4' does not exist/
      )
    end

    it 'raises an exception for invalid expressions' do
      expect { Spreadsheet.new('=FOO  100')['A1'] }.to raise_error(
        Spreadsheet::Error, /Invalid expression 'FOO'/
      )

      expect { Spreadsheet.new('=FOO(A1  100')['A1'] }.to raise_error(
        Spreadsheet::Error, /Invalid expression 'FOO\(A1'/
      )

      expect { Spreadsheet.new('=FOO A1  100')['A1'] }.to raise_error(
        Spreadsheet::Error, /Invalid expression 'FOO A1'/
      )
    end
  end
end
