# Lazy Mode

[Org-mode](http://orgmode.org/) е plugin за [emacs](https://www.gnu.org/software/emacs/) (да, все още има хора които го използват и не са пробвали [vim](http://www.vim.org/) :confused:), позволяващ водене на бележки, правене на TODO списъци, планиране на проекти и още редица други странни употреби и всичко това в изцяло текстов формат.

## Вашата задача

Задачата ви е да имплементирате своя опростена версия, която ще наричаме Lazy-mode. Тя служи за проследяване на задачи, които искаме да отложим или вече сме отложили. Преди да навлезем в детайли, следва кратко отклонение.

## Времето

Няма как да следим изоставането си по дадена задача, без да имаме удобен начин за представяне на времето. За жалост, времето е сложно. Имаме високосни години, месеци с по-малко от 30 дни, различни часови зони и още ужаси, с които да се справяме. Дори [Matz](https://en.wikipedia.org/wiki/Yukihiro_Matsumoto) [мрази времето](https://github.com/ruby/ruby/blob/trunk/doc/ChangeLog-1.8.0#L13873). За да не се занимаваме с несъвършенствата на времето, ще направим собствен вариант (така и така точността не е толкова важна за нашата система). Ще дефинираме класа `LazyMode::Date`, който ще използваме по следния начин:

    date = LazyMode::Date.new('2012-10-03')
    date.year  # => 2012
    date.month # => 10
    date.day   # => 3

`LazyMode::Date` се инициализира от стринг със следния формат: `'yyyy-mm-dd'`. Това ще рече, че имаме годината, месеца и деня от месеца, разделени с тире. В случай, че:

* годината има по-малко от 4 цифри, тя се префиксва с нули (например `0987`)
* месецът има по-малко от 2 цифри, той се префиксва с нули (например `09`)
* денят от месеца има по-малко от 2 цифри, той се префиксва с нули (например `07`)

`LazyMode::Date` трябва да има четири метода:

* `#year` - връща годината като число
* `#month` - връща месеца като число
* `#day` - връща деня от месеца като число
* `#to_s` - връща текстовото представяне на датата като низ

От тук нататък, когато искаме нещо да работи с време, ще работим само с този обект. За удобство ще приемем, че в годината има 12 месеца и 30 дни във всеки месец.

## Note

Основното нещо, с което ще работим в lazy-mode, е note, както е и в org-mode. Ще дефинираме класа `LazyMode::Note` по следния начин:

* `#header` - връща низ - заглавие на бележката ни
* `#file_name` - връща низ - име на файла, в който пазим бележката
* `#body` - връща низ - текстово съдържание на нашата бележка
* `#status` - връща един от следните два символа - `:topostpone`, `:postponed`
* `#tags` - връща масив с всички тагове за бележката, а в случай че няма такива - връща празен масив

## File

Създаването на файл ще правим посредством наш специален DSL, който изглежда по следния начин:

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

    file.name                  # => 'work'
    file.notes.size            # => 2
    file.notes.first.file_name # => 'work'
    file.notes.first.header    # => 'sleep'
    file.notes.first.tags      # => [:important, :wip]
    file.notes.first.status    # => :postponed
    file.notes.first.body      # => 'Try sleeping more at work'
    file.notes.last.file_name  # => 'work'
    file.notes.last.header     # => 'useless activity'
    file.notes.last.tags       # => []
    file.notes.last.status     # => :topostpone

`create_file` приема името на файла като аргумент и блок (***няма да се извиква без блок***). В блока трябва да имаме достъп до метода `#note`, който създава нова бележка. Резултатът от `#create_file` е инстанция на `LazyMode::File`, който има дефинирани методите `#name` - името на файла и `#notes` - списък с бележките, които трябва да са инстанции на клас `LazyMode::Note`. Списъкът може да е инстанция на класа `Array`, или еквивалент. Редът на бележките, върнати от `#notes` в списъка`, e без значение.

### `#note`

Методът `#note`, достъпен в блока на `#create_file`, създава нова бележка с `#header`, подаден като първи аргумент и приема след това произволен брой (нула или повече) тагове. Редът на таговете се пази както е подаден. Самият метод приема блок, в който трябва да имаме достъп до следните методи:

* `#status` - приема един от двата символа `:postponed` или `:topostpone`. Няма да се подават невалидни стойности. Ако `#status` не бъде извикан, се приема, че стойността му е `:topostpone`.
* `#body` - приема произволен текст, който отговаря на съдържанието на бележката. Стойноста по подразбиране на `#body` е празен низ.
* `#scheduled` - текстов низ, съдържащ дата във формата, който е описан в `LazyMode::Date`. Наличието му е задължително за създаване на бележки. Приемаме, че винаги имаме подаден такъв, тоест, че в блока, подаден на `#note`, винаги ще бъде извикван методът `#scheduled`.

### `#scheduled`

    file = LazyMode.create_file('hobby') do
      note 'swim' do
        scheduled '2012-08-07 +2w'
        status :postponed
      end
    end

`#scheduled` може да създава бележка, която се повтаря периодично, започвайки от посочената дата. Това става като към датата добавим повторител във формата `+{n}{m,d,w}`, където `n` е число и означава всеки n-пъти, `m` - всеки месец, `d` - всеки ден, `w` - всяка седмица. В примера по-горе това означава, че сме насрочили плуване на всеки две седмици, започвайки от `2012-08-07`.

### Влагане на бележки

Можем да влагаме бележките една в друга. Например:

    file = LazyMode.create_file('nesting') do
      note 'task' do
        scheduled '2012-08-07'

        note 'subtask' do
          scheduled '2012-08-06'
        end
      end
    end

Влагането става като дефинирането на нови бележки. За да дефинираме влагане, просто извикваме отново `#note` в блока на бележката, за която искаме да направим подбележка.

## Agenda

`LazyMode::File` трябва да дефинира и метода `#daily_agenda`. `#daily_agenda` приема като аргумент дата (като инстанция на `LazyMode::Date`) и ни връща обект, който има дефиниран метод `#notes`. Методът `#notes` трябва да ни върне спъсък от всички бележки, които са `schedule`-нати за `date`. Редът на бележките в списъка е без значение. Пример:

    file = LazyMode.create_file('nesting') do
      note 'task' do
        scheduled '2012-08-07'

        note 'subtask' do
          scheduled '2012-08-06 +1w'
        end
      end
    end

    daily_agenda = file.daily_agenda(LazyMode::Date.new('2012-08-13'))
    daily_agenda.notes.size            # => 1
    daily_agenda.notes.first.header    # => 'subtask'
    daily_agenda.notes.first.date.to_s # => '2012-08-13'

Всяка бележка от `notes` трябва да има всички методи на `LazyMode::Note` и допълнителен метод `#date` - датата, за която е насрочено събитието. В случая на `daily_agenda`, това винаги ще е датата, подадена като аргумент на `#daily_agenda`.

Аналогично дефинираме и метода `LazyMode::File#weekly_agenda(date)`. Трябва да върнем обект, който имплементира метод `#notes`, връщащ всички бележки за следващите седем дни, считано от `date`. Редът на бележките в списъка отново е без значение. Пример:

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
    weekly_agenda.notes.size            # => 2
    weekly_agenda.notes.first.header    # => 'task'
    weekly_agenda.notes.first.date.to_s # => '2012-08-07'
    weekly_agenda.notes.last.header     # => 'subtask'
    weekly_agenda.notes.last.date.to_s  # => '2012-08-06'

## `#where`

Обектите, връщани от `#daily_agenda` и `#weekly_agenda` трябва да имплементират и метода `#where`. `#where` позволява филтриране по `status`, `tag` и `text`. `#where` приема следните keyword аргументи - `:tag`, `:text` или `:status` и връща нов обект, поддържащ същите методи като обектите, върнати от `#daily_agenda` и `#weekly_agenda`. Редът на бележките в резултата от филтрацията е без значение. Пример:

    file = LazyMode.create_file('week with tags') do
      note 'task', :important do
        scheduled '2012-08-07'

        note 'subtask', do
          scheduled '2012-08-06'
        end

        note 'subtask 2', :important do
          scheduled '2012-08-05'
        end
      end
    end

    weekly_agenda = file.weekly_agenda(LazyMode::Date.new('2012-08-05'))
    important_tasks = weekly_agenda.where(tag: :important)
    important_tasks.notes.size             # => 2
    important_tasks.notes.first.header     # => 'task'
    important_tasks.notes.last.header      # => 'subtask 2'

    important_subtasks = weekly_agenda.where(tag: :important, text: /sub/)
    important_subtasks.notes.size          # => 1
    important_subtasks.notes.first.header  # => 'subtask 2'


* `:tag` - приема произволен таг, по който се филтрира. Бележките, които се връщат, трябва да имат този таг. ***Забележка:*** таговете не се наследяват, т.е. влагането няма значение. Гледат се само таговете, подадени директно при създаване на бележката, а таговете на нейните родители - не.
* `:text` - приема регулярен израз и филтрира бележките спрямо това дали регулярният израз "хваща" `#header` или `#body` на бележката.
* `:status` - приема един от възможните статуси (`:postponed` или `:topostpone`) и филтрира бележките спрямо това дали `#status`-ът им съвпада с подадения на филтъра.

От примера виждаме, че когато се подадат повече от един от филтрите, трябва всичките да са изпълнени за дадена бележка.

## Примерен тест

Примерните тестове се намират в [GitHub хранилището с домашните](https://github.com/fmi/ruby-homework/blob/master/tasks/07/sample_spec.rb). За информация как да ги изпълните, погледнете [README-то на хранилището](https://github.com/fmi/ruby-homework#readme).
