describe LazyMode do
  describe LazyMode::Date do
    subject { LazyMode::Date.new('2012-08-07') }
    it { is_expected.to respond_to(:year) }
    it { is_expected.to respond_to(:month) }
    it { is_expected.to respond_to(:day) }
  end

  describe '#create_file' do
    it 'handles unnested notes' do
      file = LazyMode.create_file('work') do
        note 'sleep', :important, :wip do
          scheduled '2012-08-07'
          status :postponed
          body 'Try sleeping more at work'
        end


        note 'useless activity' do
          scheduled '2012-08-07'
        end
      end


      expect(file.notes.size).to eq 2

      first_note = file.notes.find { |note| note.header == 'sleep' }
      expect(first_note.file_name).to eq('work')
      expect(first_note.header).to eq('sleep')
      expect(first_note.tags).to eq([:important, :wip])
      expect(first_note.status).to eq(:postponed)
      expect(first_note.body).to eq('Try sleeping more at work')

      second_note = file.notes.find { |note| note.header == 'useless activity' }
      expect(second_note.file_name).to eq('work')
      expect(second_note.header).to eq('useless activity')
      expect(second_note.tags).to eq([])
      expect(second_note.status).to eq(:topostpone)
    end
  end

  describe '#daily_agenda' do
    it 'returns all notes for a given day' do
      file = LazyMode.create_file('nesting') do
        note 'task' do
          scheduled '2012-08-07'

          note 'subtask' do
            scheduled '2012-08-06 +1w'
          end
        end
      end

      daily_agenda = file.daily_agenda(LazyMode::Date.new('2012-08-13'))
      expect(daily_agenda.notes.size).to eq(1)
      expect(daily_agenda.notes.first.header).to eq('subtask')
      expect(daily_agenda.notes.first.date.to_s).to eq('2012-08-13')
    end
  end


  describe '#daily_agenda' do
    it 'returns all notes for a given week' do
      file = LazyMode.create_file('week') do
        note 'task' do
          scheduled '2012-08-07'

          note 'subtask' do
            scheduled '2012-08-06'
          end

          note 'subtask 2' do
            scheduled '2012-08-05'
          end
        end
      end

      weekly_agenda = file.weekly_agenda(LazyMode::Date.new('2012-08-06'))
      expect(weekly_agenda.notes.size).to eq(2)            #=> 2
      task_note = weekly_agenda.notes.find { |note| note.header == 'task' }
      expect(task_note.date.to_s).to eq('2012-08-07')
      subtask_note = weekly_agenda.notes.find { |note| note.header == 'subtask' }
      expect(subtask_note.date.to_s).to eq('2012-08-06')
    end

    describe '#where' do
      before(:each) do
        @file = LazyMode.create_file('week with tags') do
          note 'task', :important do
            scheduled '2012-08-07'

            note 'subtask' do
              scheduled '2012-08-06'
            end

            note 'subtask 2', :important do
              scheduled '2012-08-05'
            end
          end
        end
      end

      it 'filters by tag' do
        weekly_agenda = @file.weekly_agenda(LazyMode::Date.new('2012-08-05'))
        important_tasks = weekly_agenda.where(tag: :important)
        expect(important_tasks.notes.size).to eq(2)
        expect(important_tasks.notes.find { |note| note.header == 'task' }).not_to be_nil
        expect(important_tasks.notes.find { |note| note.header == 'subtask 2' }).not_to be_nil
      end

      it 'filters by tag and text' do
        weekly_agenda = @file.weekly_agenda(LazyMode::Date.new('2012-08-05'))
        important_subtasks = weekly_agenda.where(tag: :important, text: /sub/)
        expect(important_subtasks.notes.size).to eq(1)
        expect(important_subtasks.notes.first.header).to eq('subtask 2')
      end
    end
  end
end
