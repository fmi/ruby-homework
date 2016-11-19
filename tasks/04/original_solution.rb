RSpec.describe 'Version' do
  def v(version_string)
    Version.new(version_string)
  end

  it 'validates the version string' do
    expect { v('1.5..15')    }.to raise_error ArgumentError
    expect { v('.5.1')       }.to raise_error ArgumentError
    expect { v('ios-1.5.15') }.to raise_error ArgumentError
    expect { v('1.-5.15')    }.to raise_error ArgumentError
    expect { v('1.5@.15')    }.to raise_error ArgumentError
    expect { v('1.5.')       }.to raise_error ArgumentError
    expect { v('1.5.15beta') }.to raise_error ArgumentError
  end

  it 'correctly describes the error if not valid' do
    expect { v('1.2.wat') }.to raise_error(
      ArgumentError,
      "Invalid version string '1.2.wat'"
    )
  end

  it 'allows the version to be an empty string and assumes it to be 0' do
    expect(v('')).to eq v('0')
  end

  it 'can be initialized without a string and assumes the version to be 0' do
    expect(Version.new).to eq v('0')
  end

  it 'can be initialized with another version object' do
    expect(Version.new(v('1.1.3'))).to eq v('1.1.3')
  end

  describe 'comparisons' do
    it 'can compare version to version' do
      expect(v('3.1.1')).to eq v('3.1.1')
    end

    it 'correctly compares equal versions' do
      expect(v('11.3.4')).to eq v('11.3.4')
      expect(v('3')     ).to eq v('3')
      expect(v('3.6')   ).to eq v('3.6')

      expect(v('3.5')).to_not eq v('3.6')
    end

    it 'assumes unspecified components are zero' do
      expect(v('3.0.0.0.0')).to eq v('3')
      expect(v('3.0.0.0.0')).to eq v('3.0.0')
      expect(v('3.4')      ).to eq v('3.4.0')
      expect(v('3.4')      ).to be < v('3.4.1')
      expect(v('3.43.1')   ).to be < v('3.43.1.1')
    end

    it 'compares simple inequalities' do
      expect(v('1')    ).to be > v('0')
      expect(v('0.1')  ).to be > v('0')
      expect(v('0.0.1')).to be > v('0')
      expect(v('0')    ).to_not be > v('0.0.1')

      expect(v('1')    ).to be < v('1.0.1')
      expect(v('1.1')  ).to be < v('1.1.1')
      expect(v('11.3') ).to be < v('11.3.1')
      expect(v('1.0.1')).to_not be < v('1')

      expect(v('1.23')).to be > v('1.22')
      expect(v('1.23')).to be > v('1.4')

      expect(v('1.23.3')).to be > v('1.4.8')
      expect(v('1.22.3')).to be < v('1.23.2')

      expect(v('1.22.0.3')).to be < v('1.23.0.2')
      expect(v('2.22.0.3')).to be > v('1.23.0.2')
    end

    it 'implements <= and >=' do
      expect(v('1.23')).to be >= v('1.22')
      expect(v('1.23')).to be >= v('1.23')
      expect(v('1.23')).to_not be >= v('1.24')

      expect(v('1.23')).to be <= v('1.24')
      expect(v('1.23')).to be <= v('1.23')
      expect(v('1.23')).to_not be <= v('1.21')
    end

    it 'implements <=>' do
      expect(v('1.2.3.0') <=> v('1.3.2')).to eq -1
      expect(v('1.3.2.0') <=> v('1.2.3')).to eq 1
      expect(v('1.2.3.0') <=> v('1.2.3')).to eq 0
    end
  end

  describe '#to_s' do
    it 'converts versions to string' do
      expect(v('1').to_s        ).to eq '1'
      expect(v('1.2').to_s      ).to eq '1.2'
      expect(v('1.2.3').to_s    ).to eq '1.2.3'
      expect(v('1.2.33.48').to_s).to eq '1.2.33.48'
      expect(v('1.2.3.08').to_s ).to eq '1.2.3.8'
      expect(v('1.0.3.8').to_s  ).to eq '1.0.3.8'
    end

    it 'stringifies the version without trailing zeroes' do
      expect(v('1.0.0').to_s  ).to eq '1'
      expect(v('1.2.0').to_s  ).to eq '1.2'
      expect(v('1.0.2.0').to_s).to eq '1.0.2'
      expect(v('0.1.0').to_s  ).to eq '0.1'
    end
  end

  describe '#components' do
    it 'returns a given number of components' do
      expect(v('0.1').components(5)).to eq [0, 1, 0, 0, 0]
    end

    it 'returns all components if no parameter is given' do
      expect(v('0.1.2.3.4.0').components).to eq [0, 1, 2, 3, 4]
    end

    it 'cuts the number of components if they need to be fewer' do
      expect(v('0.1.2.3.4.0').components(4)).to eq [0, 1, 2, 3]
    end

    it 'is not able to modify the internal data of the version' do
      version = Version.new('1.2.3')
      version.components << 4

      expect(version).to eq v('1.2.3')
    end
  end

  describe 'Range' do
    it 'accepts versions as strings' do
      range = Version::Range.new('1.1.1', '3.3.3')
      expect(range).to include v('1.99')
      expect(range).to_not include v('22')
    end

    describe '#include?' do
      let(:range) { Version::Range.new(v('1.1.11'), v('3.1.12')) }

      it 'can tell if a version is included in the range' do
        expect(range).to include v('1.2.1')
        expect(range).to include v('1.100')
        expect(range).to include v('1.1.15')
        expect(range).to include v('2.5.55')

        expect(range).to_not include v('3.1.15')
        expect(range).to_not include v('3.2.0')
        expect(range).to_not include v('0.1')
        expect(range).to_not include v('1.1.10')
        expect(range).to_not include v('20.1.10')
      end

      it 'includes the first version in the range' do
        expect(range).to include v('1.1.11')
      end

      it 'excludes the last version from the range' do
        expect(range).to_not include v('3.1.12')
      end

      it 'can be given a string' do
        expect(range).to include '1.1.12'
        expect(range).to_not include '3.1.15'
      end
    end

    describe '#to_a' do
      it 'can iterate simple version ranges' do
        range = Version::Range.new('1.1.2', '1.1.5')

        expect(range.to_a.map(&:to_s)).to eq ['1.1.2', '1.1.3', '1.1.4']
      end

      it 'can iterate more complex versions' do
        range = Version::Range.new('1.1.2', '1.3')

        expect(range.to_a.map(&:to_s)).to match_array [
          '1.1.2', '1.1.3', '1.1.4', '1.1.5', '1.1.6', '1.1.7', '1.1.8',
          '1.1.9',
          '1.2', '1.2.1', '1.2.2', '1.2.3', '1.2.4', '1.2.5', '1.2.6', '1.2.7',
          '1.2.8', '1.2.9'
        ]
      end
    end
  end
end
