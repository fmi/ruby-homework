# Arnold C+-

> [What killed the dinosaurs? The ice age.](https://www.youtube.com/watch?v=qQRWfxkCdU4)

Имплементирането на [езотеричен език за програмиране](https://en.wikipedia.org/wiki/Esoteric_programming_language) е част от life complete checklist-a на всеки програмист. С тази задача ще ви помогнем да убиете два заека.

[ArnoldC](https://github.com/lhartikk/ArnoldC) е базиран на фрази от кариерата на небезизвестен актьор от австрийски произход.

Тъй като сме махнали, добавили и променили няколко неща, ще наречем нашия диалект на езика Arnold C+-.

### `main`
Всяка ArnoldC+- програма има main метод, играещ ролята на entry point. Той започва с фразата `its_showtime` и завършва с `you_have_been_terminated`:

```ruby
its_showtime
  # do_something
you_have_been_terminated
```

### Типове:

Езикът не е статично типизиран. Има само два типа - цели числа и функции.

Всички операции, освен извикване на функция и сравнение за равенство, работят само върху числа.

### Принтиране:

```ruby
talk_to_the_hand 42
talk_to_the_hand _some_var
```

### Присвояване на променливи:

```ruby
get_to_the_chopper _the_answer
here_is_my_invitation 42
enough_talk
```

Горното ще присвои начална стойност `42` на `_the_answer`. Не може да се декларира променлива без начална стойност. `enough_talk` затваря присвояването (представете си `;` в други езици).

Имената на променливите спазват същите ограничения като тези в Ruby, като допълнително не могат да са сред запазените фрази в ArnoldC+- (aka `its_showtime`, `talk_to_the_hand` etc). По конвенция ще използваме `_snake_case_with_leading_underscore`, но кодът ви не бива да разчита на това. Това важи и за имената на функции и техните параметри.

### Операции:

Изпълняването на операции изисква да присвоите начална стойност на променлива, като изредите въпросните операции преди затварящия `enough_talk`:

```ruby
# _forty_two = 6 * 9
get_to_the_chopper _forty_two
here_is_my_invitation 6
youre_fired 9
enough_talk
```

Множество операции могат да следват една след друга в едно и също присвояване:

```ruby
# _fibonacci_5 = 1 + 1 + 2 + 3 + 5
get_to_the_chopper _fibonacci_5
here_is_my_invitation 1
get_up 1
get_up 2
get_up 3
get_up 5
enough_talk
```

**Всички операции имат равен приоритет.**

* Аритметични операции:

  ```ruby
  # + _x
  get_up _x

  # - _x
  get_down _x

  # * _x
  youre_fired _x

  # / _x
  he_had_to_split _x

  # % _x
  i_let_him_go _x
  ```

* Логически операции:

  `0` се смята за неистина. Всичко друго - истина.

  Съществуват две логически константи - `i_lied` = `0` и `no_problemo` = `1`.

  ```ruby
  # or _x
  consider_that_a_divorce _x

  # and _x
  knock_knock _x
  ```

  `or` връща първия операнд, ако той е истина, и втория - в противен случай.

  `and` връща първия операнд, ако той е неистина, и втория иначе.

  Няма `not`.

* Операции за сравнение:

  ```ruby
  # > _x
  let_off_some_steam_bennet _x

  # == _x
  you_are_not_you_you_are_me _x
  ```

  Проверката за равенство може да работи и върху функции. Тогава се оценява на истина ако двете функции имат един и същи идентитет. С други думи - ако реферирате една и съща функция, но не и ако имате две различни фунции с еднакво тяло (например генерирани от друга функция).

  Сравнението на число с функция винаги се оценява на неистина.

### `if-else`:

```ruby
# if _condition
#   # do_something
# else
#   # do_something_else
# end
because_im_going_to_say_please _condition
  # do_something
bull_shit
  # do_something_else
you_have_no_respect_for_logic
```

`bull_shit` клаузата може да липсва.

Множество `if-else`-ове могат да се влагат един в друг.

Условията създават нов блок - те могат да виждат външните променливи, но не могат да ги променят или да добавят нови такива в обграждащия ги scope. Същото важи и за дефиницията на функции.

### Деклариране на функции:

```ruby
# def _function_name(_x, _y)
#   # do_something
#   return _return_value
# end
listen_to_me_very_carefully _function_name
i_need_your_clothes_your_boots_and_your_motorcycle _x
i_need_your_clothes_your_boots_and_your_motorcycle _y
give_these_people_air
  # do_something
  ill_be_back _return_value
hasta_la_vista_baby
```

По подразбиране всички функции са void. Void функциите могат да имат `return`, но самата върната стойност се игнорира от извикващия код. За да направите функция не-void е нужна ключовата фраза `give_these_people_air` след дефиницията на параметрите на функцията.

`ill_be_back` не е задължително да е последният израз във функцията.

Ако не е дадена стойност, `ill_be_back` връща 0.

Функциите може да нямат параметри.

### Извикване на функции:

```ruby
# _foo()
do_it_now _foo

# _bar(_a, _b)
do_it_now _bar, _a, _b

# _quiz = _baz(_a, _b, _c)
get_your_ass_to_mars _quiz
do_it_now _baz, _a, _b, _c
```

Резултатът от извикване на не-void функции **трябва** да се присвои на променлива чрез фразата `get_your_ass_to_mars`.

### Вложени функции:

Могат да се дефинират вложени функции, като дефиницията им остава в scope-a на дефиниращата ги функция.

Всяка функция си пази closure с околните променливи.

Всяко извикване на функция дефинира вложените си функции наново. С други думи:

```ruby
# _define_function = lambda do
#   _inner_function = -> {}
#   return _inner_function
# end
#
# _first_invocation = _define_function.()
# _second_invocation = _define_function.()
# _are_the_two_functions_identical = _first_invocation == _second_invocation
# 
# print _are_the_two_functions_identical

listen_to_me_very_carefully _define_function
give_these_people_air
  listen_to_me_very_carefully _inner_function
  hasta_la_vista_baby

  ill_be_back _inner_function
hasta_la_vista_baby

its_showtime
  get_your_ass_to_mars _first_invocation
  do_it_now _define_function

  get_your_ass_to_mars _second_invocation
  do_it_now _define_function

  get_to_the_chopper _are_the_two_functions_identical
  here_is_my_invitation _first_invocation
  you_are_not_you_you_are_me _second_invocation
  enough_talk

  # prints 0
  talk_to_the_hand _are_the_two_functions_identical
you_have_been_terminated
```

Забележете, че в Ruby "превода" използвахме lambda, понеже дефинирането на вложени функции не работи по същия начин. В ArnoldCPM няма анонимни функции.

### Още за функциите

Функциите поддържат рекурсия (което е и единственият метод за циклене в езика):

```ruby
# def _to_infinity_and_beyond(_n)
#   print _n
#   _n_plus_one = _n + 1
#   _to_infinity_and_beyond(_n_plus_one)
# end
#
# _to_infinity_and_beyond(1)

listen_to_me_very_carefully _to_infinity_and_beyond
i_need_your_clothes_your_boots_and_your_motorcycle _n
  talk_to_the_hand _n

  get_to_the_chopper _n_plus_one
  here_is_my_invitation _n
  get_up 1
  enough_talk

  do_it_now _to_infinity_and_beyond, _n_plus_one
hasta_la_vista_baby

its_showtime
  do_it_now _to_infinity_and_beyond, 1
you_have_been_terminated
```

Функциите могат да приемат други функции като аргументи както и да връщат такива.

`main` е запазено име за функцията, дефинирана от `its_showtime`. Няма да се опитваме да дефинираме такава с `listen_to_me_very_carefully`.

## Ruby интерфейс

Трябва да дефинирате модул `ArnoldCPM` с метод `totally_recall`, който оценява ArnoldC+- кодът, подаден му като блок.

Нужен е и метод `ArnoldCPM.printer=`, който задава обектът, чиито `print` метод ще се вика при принтиране. `print` методът приема един аргумент - числото, което бива принтирано.

Пример:

```ruby
# prints
# 110110
# 11101101
ArnoldCPM.printer = Kernel

ArnoldCPM.totally_recall do
  its_showtime
    talk_to_the_hand 110110
    talk_to_the_hand 11101101
  you_have_been_terminated
end
```

**Забележка**: От изключителна важност е `talk_to_the_hand` да вика `printer.print`. В противен случай тестовете ви няма да минават.

## Примерни тестове

* Не забравяйте да си пуснете [примерните тестове](https://github.com/fmi/ruby-homework/tree/master/tasks/06/sample_spec.rb) преди да предадете решение.
* В тях ще намерите и повече примери.
