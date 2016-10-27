describe '#ordinalize' do
  def expect_transformations(transformations)
    transformations.each do |number, ordinalized|
      expect(ordinalize(number)).to eq ordinalized
    end
  end

  it "adds 'th' to the cardinal number in the common case" do
    expect_transformations 4    => '4th',
                           5    => '5th',
                           6    => '6th',
                           7    => '7th',
                           8    => '8th',
                           9    => '9th',
                           10   => '10th',
                           11   => '11th',
                           12   => '12th',
                           13   => '13th',
                           14   => '14th',
                           20   => '20th',
                           24   => '24th',
                           100  => '100th',
                           104  => '104th',
                           110  => '110th',
                           111  => '111th',
                           112  => '112th',
                           113  => '113th',
                           1000 => '1000th'
  end

  it "adds 'th' to zero" do
    expect_transformations 0 => '0th'
  end

  it "handles 'first, second, third' special cases" do
    expect_transformations 1    => '1st',
                           2    => '2nd',
                           3    => '3rd',
                           21   => '21st',
                           22   => '22nd',
                           23   => '23rd',
                           42   => '42nd',
                           51   => '51st',
                           93   => '93rd',
                           101  => '101st',
                           102  => '102nd',
                           103  => '103rd',
                           1001 => '1001st',
                           1002 => '1002nd',
                           1003 => '1003rd'
  end

  it 'works with negative numbers' do
    expect_transformations -1    => '-1st',
                           -2    => '-2nd',
                           -3    => '-3rd',
                           -4    => '-4th',
                           -5    => '-5th',
                           -6    => '-6th',
                           -7    => '-7th',
                           -8    => '-8th',
                           -9    => '-9th',
                           -10   => '-10th',
                           -11   => '-11th',
                           -12   => '-12th',
                           -13   => '-13th',
                           -14   => '-14th',
                           -20   => '-20th',
                           -21   => '-21st',
                           -22   => '-22nd',
                           -23   => '-23rd',
                           -24   => '-24th',
                           -100  => '-100th',
                           -101  => '-101st',
                           -102  => '-102nd',
                           -103  => '-103rd',
                           -104  => '-104th',
                           -110  => '-110th',
                           -111  => '-111th',
                           -112  => '-112th',
                           -113  => '-113th',
                           -1000 => '-1000th',
                           -1001 => '-1001st'
  end

  it 'works with big numbers' do
    expect_transformations -1_000_000_000 => '-1000000000th',
                           -1_000_000_001 => '-1000000001st',
                           -1_000_000_002 => '-1000000002nd',
                           -1_000_000_003 => '-1000000003rd',
                           -1_000_000     => '-1000000th',
                           -1_000_001     => '-1000001st',
                           -1_000_002     => '-1000002nd',
                           -1_000_003     => '-1000003rd',
                           1_000_000      => '1000000th',
                           1_000_001      => '1000001st',
                           1_000_002      => '1000002nd',
                           1_000_003      => '1000003rd',
                           1_000_000_000  => '1000000000th',
                           1_000_000_001  => '1000000001st',
                           1_000_000_002  => '1000000002nd',
                           1_000_000_003  => '1000000003rd'
  end
end
