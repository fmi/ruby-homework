# to_proc ALL THE THINGS! (първа част)

Може би вече сте се убедили, че `Symbol#to_proc` е нещо полезно, което прави
кода по-компактен и по-четим. В това предизвикателство ще искаме от вас
да добавите две интресни имплементации на `to_proc` и към други Ruby класове.

В примерите по-долу ще приемем, че имаме дефиниран следния код:

    class Student
      attr_accessor :name, :points, :rank

      def initialize(name, points, rank)
        @name   = name
        @points = points
        @rank   = rank
      end
    end

    ivan   = Student.new 'Иван', 10, :second
    mariya = Student.new 'Мария', 12, :first
    neycho = Student.new 'Нейчо', 9, :third

    students = [ivan, mariya, neycho]

## Array#to_proc

Дефинирайте метод `Array#to_proc`, който да ни позволява да правим следното:

    students.map(&[:name, :rank]) # => [['Иван', :second], ['Мария', :first], ['Нейчо', :third]]

По-просто казано, нашата имплементация на `Array#to_proc` трябва да работи така:

    [:points, :name].to_proc.call(ivan) # => [10, 'Иван']

## Hash#to_proc

Дефинирайте метод `Hash#to_proc`, който да ни улеснява да задаваме стойности на полета на обекти по следния начин:

    students.each &{points: 0, rank: :last}
    students.map(&:points) # => [0, 0, 0]
    students.map(&:rank)   # => [:last, :last, :last]

Или, отново, казано по-просто, `Hash#to_proc` трябва да работи така:

    {name: 'Петкан', points: -100}.to_proc.call(ivan)
    ivan.name   # => 'Петкан'
    ivan.points # => -100
