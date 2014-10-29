describe RBFS do
  describe 'Directory' do
    subject(:directory) { RBFS::Directory.new }

    context 'with files and directories' do
      let(:readme) { RBFS::File.new('Hello world!')  }
      let(:spec)   { RBFS::File.new('describe RBFS') }

      before(:each) do
        directory.add_file('README',  readme)
        directory.add_file('spec.rb', spec)
      end

      it 'returns correct file hash' do
        expect(directory.files).to eq({'README' => readme, 'spec.rb' => spec})
      end
    end

    context 'serialization' do
      let(:simple_serialized_string) do
        [
          '2:',
            'README:19:string:Hello world!',
            'spec.rb:20:string:describe RBFS',
          '1:',
            'rbfs:4:',
              '0:',
              '0:',
        ].join ''
      end

      describe '#serialize' do
        it 'can serialize' do
          directory.add_file 'README',  RBFS::File.new('Hello world!')
          directory.add_file 'spec.rb', RBFS::File.new('describe RBFS')
          directory.add_directory 'rbfs'

          expect(directory.serialize).to eq simple_serialized_string
        end
      end

      describe '::parse' do
        it 'can parse' do
          parsed_directory = RBFS::Directory.parse(simple_serialized_string)

          expect(parsed_directory.files.size     ).to eq    2
          expect(parsed_directory['README'].data ).to eq    'Hello world!'
          expect(parsed_directory['spec.rb'].data).to eq    'describe RBFS'
          expect(parsed_directory['rbfs']        ).to be_an RBFS::Directory
        end
      end
    end

    it 'can add a file' do
      file = RBFS::File.new('Hey there!')

      directory.add_file 'README', file

      expect(directory.files).to eq({'README' => file})
    end

    it 'can add a directory' do
      subdirectory = RBFS::Directory.new

      directory.add_directory 'home', subdirectory

      expect(directory.directories).to eq({'home' => subdirectory})
    end

    describe '#[]' do
      let(:home) { RBFS::Directory.new }

      before(:each) do
        directory.add_directory 'home', home
      end

      it 'can walk a directory' do
        expect(directory['home']).to eq home
      end
    end
  end

  describe 'File' do
    subject(:file) { RBFS::File.new }

    it 'can store data' do
      file.data = 'hello world'
      expect(file.data).to eq 'hello world'
    end

    it 'can accept data in the initializer' do
      file = RBFS::File.new('Hay :)')

      expect(file.data).to eq 'Hay :)'
    end
  end

  context 'data type' do
    context 'number' do
      it 'can be detected' do
        expect(RBFS::File.new(42).data_type).to eq :number
      end
    end
  end
end
