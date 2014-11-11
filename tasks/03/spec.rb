describe RBFS do
  describe 'Directory' do
    subject(:directory) { RBFS::Directory.new }

    context 'without files' do
      it 'returns empty hash for the files' do
        expect(directory.files).to eq({})
      end

      it 'can be serialized' do
        expect(directory.serialize).to eq '0:0:'
      end
    end

    context 'without directories' do
      it 'returns empty hash for the directories' do
        expect(directory.directories).to eq({})
      end
    end

    context 'with files and directories' do
      let(:readme) { RBFS::File.new('Hello world!')  }
      let(:spec)   { RBFS::File.new('describe RBFS') }
      let(:rbfs)   { RBFS::Directory.new             }

      before(:each) do
        directory.add_file('README',  readme)
        directory.add_file('spec.rb', spec)

        directory.add_directory 'rbfs', rbfs
      end

      it 'returns correct file hash' do
        expect(directory.files).to eq({'README' => readme, 'spec.rb' => spec})
      end

      it 'returns correct directory hash' do
        expect(directory.directories).to eq({'rbfs' => rbfs})
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

      let(:recursive_serialized_string) do
        [
          '2:',
            'README:19:string:Hello world!',
            'spec.rb:20:string:describe RBFS',
          '2:',
            'rbfs:64:',
              '1:',
                'solution.rb:13:symbol:hidden',
              '1:',
                'spec:24:',
                  '1:',
                    'test:12:boolean:true',
                  '0:',
            'sample:4:',
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

        it 'can serialize multiple directories recursively' do
          directory.add_file 'README',  RBFS::File.new('Hello world!')
          directory.add_file 'spec.rb', RBFS::File.new('describe RBFS')

          directory.add_directory 'rbfs'
          directory.add_directory 'sample'

          directory['rbfs'].add_file         'solution.rb', RBFS::File.new(:hidden)
          directory['rbfs'].add_directory    'spec'
          directory['rbfs']['spec'].add_file 'test',        RBFS::File.new(true)

          expect(directory.serialize).to eq recursive_serialized_string
        end
      end

      describe '::parse' do
        it 'can parse empty directories' do
          parsed_directory = RBFS::Directory.parse('0:0:')

          expect(parsed_directory.files      ).to eq({})
          expect(parsed_directory.directories).to eq({})
        end

        it 'can parse directories with files' do
          parsed_directory = RBFS::Directory.parse(simple_serialized_string)

          expect(parsed_directory.files.size     ).to eq    2
          expect(parsed_directory['README'].data ).to eq    'Hello world!'
          expect(parsed_directory['spec.rb'].data).to eq    'describe RBFS'
          expect(parsed_directory['rbfs']        ).to be_an RBFS::Directory
        end

        it 'can parse directory trees without files' do
          parsed_directory = RBFS::Directory.parse('0:2:dir1:15:0:1:dir2:4:0:0:dir3:4:0:0:')

          expect(parsed_directory['dir1']        ).to be_an RBFS::Directory
          expect(parsed_directory['dir1']['dir2']).to be_an RBFS::Directory
          expect(parsed_directory['dir3']        ).to be_an RBFS::Directory
        end

        it 'can parse directories recursively' do
          parsed_directory = RBFS::Directory.parse(recursive_serialized_string)

          expect(parsed_directory.files.size     ).to eq 2
          expect(parsed_directory['README'].data ).to eq 'Hello world!'
          expect(parsed_directory['spec.rb'].data).to eq 'describe RBFS'

          rbfs_directory = parsed_directory['rbfs']

          expect(rbfs_directory['solution.rb'].data ).to eq :hidden
          expect(rbfs_directory['spec']['test'].data).to eq true

          expect(parsed_directory['sample']).to be_an RBFS::Directory
        end
      end
    end

    it 'can add a file' do
      file = RBFS::File.new('Hey there!')

      directory.add_file 'README', file

      expect(directory.files).to eq({'README' => file})
    end

    it 'can create empty directory' do
      directory.add_directory 'home'

      expect(directory.directories.keys   ).to eq    ['home']
      expect(directory.directories['home']).to be_an RBFS::Directory
    end

    it 'can add a directory' do
      subdirectory = RBFS::Directory.new

      directory.add_directory 'home', subdirectory

      expect(directory.directories).to eq({'home' => subdirectory})
    end

    describe '#[]' do
      let(:home) { RBFS::Directory.new }
      let(:user) { RBFS::Directory.new }
      let(:ruby) { RBFS::Directory.new }
      let(:file) { RBFS::File.new 'hi' }

      before(:each) do
        directory.add_directory 'home', home
        home.add_directory      'user', user
        user.add_directory      'ruby', ruby
        ruby.add_file           'file', file
      end

      it 'can walk a single directory' do
        expect(directory['home']).to eq home
      end

      it 'can walk multiple directories' do
        expect(directory['home']['user']['ruby']).to eq ruby
      end

      it 'can get files' do
        expect(directory['home']['user']['ruby']['file']).to eq file
      end

      it 'returns nil if directory or file doesnt exist' do
        expect(directory['home']['another_user']).to be_nil
      end

      it 'is case-sensitive' do
        expect(directory['HOME']).to be_nil
      end
    end
  end

  describe 'File' do
    subject(:file) { RBFS::File.new }

    it 'has nil as initial data' do
      expect(file.data).to eq nil
    end

    it 'can store data' do
      file.data = 'hello world'
      expect(file.data).to eq 'hello world'
    end

    it 'can accept data in the initializer' do
      file = RBFS::File.new('Hay :)')

      expect(file.data).to eq 'Hay :)'
    end

    context 'data type' do
      context 'nil' do
        before(:each) { file.data = nil }

        it 'can be detected' do
          expect(file.data_type).to eq :nil
        end

        it 'can be serialized' do
          expect(file.serialize).to eq 'nil:'
        end

        it 'can be parsed' do
          file = RBFS::File.parse('nil:')
          expect(file.data     ).to eq nil
          expect(file.data_type).to eq :nil
        end
      end

      context 'string' do
        before(:each) { file.data = 'Hi' }

        it 'can be detected' do
          expect(file.data_type).to eq :string
        end

        it 'can be serialized' do
          expect(file.serialize).to eq 'string:Hi'
        end

        it 'can be parsed' do
          file = RBFS::File.parse('string:Hey there')

          expect(file.data     ).to eq 'Hey there'
          expect(file.data_type).to eq :string
        end

        it 'can parse a string with colons' do
          file = RBFS::File.parse('string:Hay :)')

          expect(file.data     ).to eq 'Hay :)'
          expect(file.data_type).to eq :string
        end
      end

      context 'symbol' do
        before(:each) { file.data = :yo }

        it 'can be detected' do
          expect(file.data_type).to eq :symbol
        end

        it 'can be serialized' do
          expect(file.serialize).to eq 'symbol:yo'
        end

        it 'can be parsed' do
          file = RBFS::File.parse('symbol:hello')

          expect(file.data     ).to eq :hello
          expect(file.data_type).to eq :symbol
        end
      end

      context 'number' do
        before(:each) { file.data = 666 }

        it 'can be detected' do
          expect(file.data_type).to eq :number
        end

        it 'can be serialized' do
          expect(file.serialize).to eq 'number:666'
        end

        it 'can be parsed' do
          file = RBFS::File.parse('number:1234')

          expect(file.data     ).to eq 1234
          expect(file.data_type).to eq :number
        end
      end

      context 'float number' do
        before(:each) { file.data = 666.6 }

        it 'can be detected' do
          expect(file.data_type).to eq :number
        end

        it 'can be serialized' do
          expect(file.serialize).to eq 'number:666.6'
        end

        it 'can be parsed' do
          file = RBFS::File.parse('number:3.14')

          expect(file.data     ).to eq 3.14
          expect(file.data_type).to eq :number
        end
      end

      context 'boolean' do
        context 'true' do
          it 'can be detected' do
            file.data = true
            expect(file.data_type).to eq :boolean
          end

          it 'can be serialized' do
            file.data = true
            expect(file.serialize).to eq 'boolean:true'
          end

          it 'can be parsed' do
            file = RBFS::File.parse('boolean:true')

            expect(file.data     ).to eq true
            expect(file.data_type).to eq :boolean
          end
        end

        context 'false' do
          it 'can be detected' do
            file.data = false
            expect(file.data_type).to eq :boolean
          end

          it 'can be serialized' do
            file.data = false
            expect(file.serialize).to eq 'boolean:false'
          end

          it 'can be parsed' do
            file = RBFS::File.parse('boolean:false')

            expect(file.data     ).to eq false
            expect(file.data_type).to eq :boolean
          end
        end
      end
    end
  end
end
