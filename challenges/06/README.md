# Class Macros

Често използван идиом в Ruby са така наречените клас макроси. Това предизвикателство ще ви даде възможност да имплементирате свое такова.

Най-известният пример за използване на клас макроси са `attr_accessor`, `attr_reader`, `attr_writer`, [пример](http://stackoverflow.com/questions/5046831/why-use-rubys-attr-accessor-attr-reader-and-attr-writer).

Задачата ви е да разширите `Class` с макро `attr_initializer`.
То трябва да приема произволен брой символи като аргументи и да се използва в класове, в които с аргументите на `initialize` се инициализират атрибути със същите имена.

Пример:

    class Point
      attr_initializer :x, :y
      attr_reader     :x, :y
    end

Горната дефиниция трябва да е еквивалентна на

    class Point
      attr_reader :x, :y

      def initialize(x, y)
        @x, @y = x, y
      end
    end

Нека при подаване на грешен брой аргументи при инициализиране на обект от клас, използващ това макро, да се вдига `ArgumentError`. Очакваме съобщението на грешката да е стандартното такова за подаване на грешен брой аргументи: "wrong number of arguments (`number of passed arguments here` for `number of expected arguments here`)".

## Примерен тест

За информация как да изпълните примерния тест, погледнете [GitHub хранилището с домашните](http://github.com/fmi/ruby-homework).
