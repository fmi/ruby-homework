describe ArnoldCPM do
  let(:printer) { double('printer') }

  before(:each) do
    ArnoldCPM.printer = printer
  end

  it 'can run an empty program' do
    ArnoldCPM.totally_recall do
      its_showtime
      you_have_been_terminated
    end
  end

  it 'has true and false constants' do
    expect_execution to_print: [0, 1]

    # print 0
    # print 1
    ArnoldCPM.totally_recall do
      its_showtime
        talk_to_the_hand i_lied
        talk_to_the_hand no_problemo
      you_have_been_terminated
    end
  end

  it 'can assign variables' do
    expect_execution to_print: [42]

    # _the_answer = 42
    # print _the_answer
    ArnoldCPM.totally_recall do
      its_showtime
        get_to_the_chopper _the_answer
        here_is_my_invitation 42
        enough_talk

        talk_to_the_hand _the_answer
      you_have_been_terminated
    end
  end

  context 'has algebra that' do
    it 'can sum numbers' do
      expect_execution to_print: [8]

      # _sum = 3 + 5
      # print _sum
      ArnoldCPM.totally_recall do
        its_showtime
          get_to_the_chopper _sum
          here_is_my_invitation 3
          get_up 5
          enough_talk

          talk_to_the_hand _sum
        you_have_been_terminated
      end
    end

    it 'can subtract numbers' do
      expect_execution to_print: [3]

      # _difference = 8 + 5
      # print _difference
      ArnoldCPM.totally_recall do
        its_showtime
          get_to_the_chopper _difference
          here_is_my_invitation 8
          get_down 5
          enough_talk

          talk_to_the_hand _difference
        you_have_been_terminated
      end
    end

    it 'can multiply numbers' do
      expect_execution to_print: [10]

      # _product = 2 * 5
      # print _product
      ArnoldCPM.totally_recall do
        its_showtime
          get_to_the_chopper _product
          here_is_my_invitation 2
          youre_fired 5
          enough_talk

          talk_to_the_hand _product
        you_have_been_terminated
      end
    end

    it 'can divide numbers' do
      expect_execution to_print: [2]

      # _quotient = 10 / 5
      # print _quotient
      ArnoldCPM.totally_recall do
        its_showtime
          get_to_the_chopper _quotient
          here_is_my_invitation 10
          he_had_to_split 5
          enough_talk

          talk_to_the_hand _quotient
        you_have_been_terminated
      end
    end

    it 'can calculate modulo' do
      expect_execution to_print: [2]

      # _modulu = 11 / 3
      # print _modulu
      ArnoldCPM.totally_recall do
        its_showtime
          get_to_the_chopper _modulu
          here_is_my_invitation 11
          i_let_him_go 3
          enough_talk

          talk_to_the_hand _modulu
        you_have_been_terminated
      end
    end

    it 'can chain multiple operations' do
      expect_execution to_print: [42]

      # Note: Ruby operations have different precedence
      # _result = 7 % 4 * 5 + 2 * 22 / 11 - 2 + 10
      # print _result
      ArnoldCPM.totally_recall do
        its_showtime
          get_to_the_chopper _result
          here_is_my_invitation 7
          i_let_him_go 4
          youre_fired 5
          get_up 2
          youre_fired 22
          he_had_to_split 11
          get_down 2
          get_up 10
          enough_talk

          talk_to_the_hand _result
        you_have_been_terminated
      end
    end

    it 'can use variables in calculations' do
      expect_execution to_print: [21]

      # _x = 3
      # _y = 7
      # _result = _x * _y
      # print _result
      ArnoldCPM.totally_recall do
        its_showtime
          get_to_the_chopper _x
          here_is_my_invitation 3
          enough_talk

          get_to_the_chopper _y
          here_is_my_invitation 7
          enough_talk

          get_to_the_chopper _result
          here_is_my_invitation _x
          youre_fired _y
          enough_talk

          talk_to_the_hand _result
        you_have_been_terminated
      end
    end
  end

  context 'has boolean arithmetic that' do
    it 'given *or* returns truthy values if one of the operands is truthy' do
      expect_execution to_print: [1, 1, 1], not_to_print: [0]

      # _result = true or false
      # print _result
      # _result = false or true
      # print _result
      # _result = true or true
      # print _result
      ArnoldCPM.totally_recall do
        its_showtime
          get_to_the_chopper _result
          here_is_my_invitation no_problemo
          consider_that_a_divorce i_lied
          enough_talk

          talk_to_the_hand _result

          get_to_the_chopper _result
          here_is_my_invitation i_lied
          consider_that_a_divorce no_problemo
          enough_talk

          talk_to_the_hand _result

          get_to_the_chopper _result
          here_is_my_invitation no_problemo
          consider_that_a_divorce no_problemo
          enough_talk

          talk_to_the_hand _result
        you_have_been_terminated
      end
    end

    it 'given *or* returns falsy values if both operands are falsy' do
      expect_execution to_print: [0], not_to_print: [1]

      # _result = false or false
      # print _result
      ArnoldCPM.totally_recall do
        its_showtime
          get_to_the_chopper _result
          here_is_my_invitation i_lied
          consider_that_a_divorce i_lied
          enough_talk

          talk_to_the_hand _result
        you_have_been_terminated
      end
    end

    it 'given *or* between two truthy values returns the first one' do
      expect_execution to_print: [11], not_to_print: [22]

      # _result = 11 or 22
      # print _result
      ArnoldCPM.totally_recall do
        its_showtime
          get_to_the_chopper _result
          here_is_my_invitation 11
          consider_that_a_divorce 22
          enough_talk

          talk_to_the_hand _result
        you_have_been_terminated
      end
    end

    it 'given *and* returns falsy values if either operand is falsy' do
      expect_execution to_print: [0, 0, 0], not_to_print: [1]

      # _result = true and false
      # print _result
      # _result = false and true
      # print _result
      # _result = false and false
      # print _result
      ArnoldCPM.totally_recall do
        its_showtime
          get_to_the_chopper _result
          here_is_my_invitation no_problemo
          knock_knock i_lied
          enough_talk

          talk_to_the_hand _result

          get_to_the_chopper _result
          here_is_my_invitation i_lied
          knock_knock no_problemo
          enough_talk

          talk_to_the_hand _result

          get_to_the_chopper _result
          here_is_my_invitation i_lied
          knock_knock i_lied
          enough_talk

          talk_to_the_hand _result
        you_have_been_terminated
      end
    end

    it 'given *and* between two truthy values returns the second one' do
      expect_execution to_print: [22], not_to_print: [11]

      # _result = 11 and 22
      # print _result
      ArnoldCPM.totally_recall do
        its_showtime
          get_to_the_chopper _result
          here_is_my_invitation 11
          knock_knock 22
          enough_talk

          talk_to_the_hand _result
        you_have_been_terminated
      end
    end

    it 'has the same precedence of *or* and *and* operations' do
      expect_execution to_print: [0], not_to_print: [1]

      # _result = true or true and false
      # print _result
      ArnoldCPM.totally_recall do
        its_showtime
          get_to_the_chopper _result
          here_is_my_invitation no_problemo
          consider_that_a_divorce no_problemo
          knock_knock i_lied
          enough_talk

          talk_to_the_hand _result
        you_have_been_terminated
      end
    end
  end

  context 'has branching mechanism that' do
    it 'can execute if statements' do
      expect_execution to_print: [11], not_to_print: [22]

      # if true
      #   print 11
      # end
      #
      # if false
      #  print 22
      # end
      ArnoldCPM.totally_recall do
        its_showtime
          because_im_going_to_say_please no_problemo
            talk_to_the_hand 11
          you_have_no_respect_for_logic

          because_im_going_to_say_please i_lied
            talk_to_the_hand 22
          you_have_no_respect_for_logic
        you_have_been_terminated
      end
    end

    it 'can execute if-else statements' do
      expect_execution to_print: [11, 44], not_to_print: [22, 33]

      # if true
      #   print 11
      # else
      #   print 22
      # end
      #
      # if false
      #   print 33
      # else
      #   print 44
      # end
      ArnoldCPM.totally_recall do
        its_showtime
          because_im_going_to_say_please no_problemo
            talk_to_the_hand 11
          bull_shit
            talk_to_the_hand 22
          you_have_no_respect_for_logic

          because_im_going_to_say_please i_lied
            talk_to_the_hand 33
          bull_shit
            talk_to_the_hand 44
          you_have_no_respect_for_logic
        you_have_been_terminated
      end
    end

    it 'can nest if-else statements' do
      expect_execution to_print: [22, 444], not_to_print: [11, 33, 44, 111, 222, 333]

      # if true
      #   if false
      #     print 11
      #   else
      #     print 22
      #   end
      # else
      #   if false
      #     print 33
      #   else
      #     print 44
      #   end
      # end
      #
      # if false
      #   if true
      #     print 111
      #   else
      #     print 222
      #   end
      # else
      #   if false
      #     print 333
      #   else
      #     print 444
      #   end
      # end
      ArnoldCPM.totally_recall do
        its_showtime
          because_im_going_to_say_please no_problemo
            because_im_going_to_say_please i_lied
              talk_to_the_hand 11
            bull_shit
              talk_to_the_hand 22
            you_have_no_respect_for_logic
          bull_shit
            because_im_going_to_say_please i_lied
              talk_to_the_hand 33
            bull_shit
              talk_to_the_hand 44
            you_have_no_respect_for_logic
          you_have_no_respect_for_logic

          because_im_going_to_say_please i_lied
            because_im_going_to_say_please no_problemo
              talk_to_the_hand 111
            bull_shit
              talk_to_the_hand 222
            you_have_no_respect_for_logic
          bull_shit
            because_im_going_to_say_please i_lied
              talk_to_the_hand 333
            bull_shit
              talk_to_the_hand 444
            you_have_no_respect_for_logic
          you_have_no_respect_for_logic
        you_have_been_terminated
      end
    end

    it 'considers functions truthy' do
      expect_execution to_print: [11], not_to_print: [22]

      # Note: Using lambdas as Ruby functions don't map directly
      # _function = -> {}
      # if _function
      #   print 11
      # else
      #   print 22
      # end
      ArnoldCPM.totally_recall do
        listen_to_me_very_carefully _function
        hasta_la_vista_baby

        its_showtime
          because_im_going_to_say_please _function
            talk_to_the_hand 11
          bull_shit
            talk_to_the_hand 22
          you_have_no_respect_for_logic
        you_have_been_terminated
      end
    end
  end

  it 'can define and call functions with arguments' do
    expect_execution to_print: [11, 22, 33]

    # def _printing_function(_n)
    #   print _n
    # end
    # print 11
    # _printing_function(22)
    # print 33
    ArnoldCPM.totally_recall do
      listen_to_me_very_carefully _printing_function
      i_need_your_clothes_your_boots_and_your_motorcycle _n
        talk_to_the_hand _n
      hasta_la_vista_baby

      its_showtime
        talk_to_the_hand 11
        do_it_now _printing_function, 22
        talk_to_the_hand 33
      you_have_been_terminated
    end
  end

  it 'can define and call functions with return value' do
    expect_execution to_print: [11, 22, 33]

    # def _non_void_function
    #   return 22
    # end
    # print 11
    # _invocation_result = _non_void_function()
    # print _invocation_result
    # print 33
    ArnoldCPM.totally_recall do
      listen_to_me_very_carefully _non_void_function
      give_these_people_air
        ill_be_back 22
      hasta_la_vista_baby

      its_showtime
        talk_to_the_hand 11

        get_your_ass_to_mars _invocation_result
        do_it_now _non_void_function
        talk_to_the_hand _invocation_result

        talk_to_the_hand 33
      you_have_been_terminated
    end
  end

  it 'returns 0 by default' do
    expect_execution to_print: [0]

    # def _return_no_argument
    #   return
    # end
    # _invocation_result = _return_no_argument()
    # print _invocation_result
    ArnoldCPM.totally_recall do
      listen_to_me_very_carefully _return_no_argument
      give_these_people_air
        ill_be_back
      hasta_la_vista_baby

      its_showtime
        get_your_ass_to_mars _invocation_result
        do_it_now _return_no_argument

        talk_to_the_hand _invocation_result
      you_have_been_terminated
    end
  end

  it 'can take functions as arguments' do
    expect_execution to_print: [42], not_to_print: [6, 9]

    # Note: Using lambdas as Ruby functions don't map directly
    # _forty_two_printer = -> { print 42 }
    # _ingredients_printer = lambda do
    #   print 6
    #   print 9
    # end
    # _invoker = lambda do |_target_function, _should_invoke_it|
    #   if _should_invoke_it
    #     _target_function.()
    #   end
    # end
    # _invoker.(_forty_two_printer, true)
    # _invoker.(_ingredients_printer, false)
    ArnoldCPM.totally_recall do
      listen_to_me_very_carefully _forty_two_printer
      give_these_people_air
        talk_to_the_hand 42
      hasta_la_vista_baby

      listen_to_me_very_carefully _ingredients_printer
      give_these_people_air
        talk_to_the_hand 6
        talk_to_the_hand 9
      hasta_la_vista_baby

      listen_to_me_very_carefully _invoker
      i_need_your_clothes_your_boots_and_your_motorcycle _target_function
      i_need_your_clothes_your_boots_and_your_motorcycle _should_invoke_it
        because_im_going_to_say_please _should_invoke_it
          do_it_now _target_function
        you_have_no_respect_for_logic
      hasta_la_vista_baby

      its_showtime
        do_it_now _invoker, _forty_two_printer, 1
        do_it_now _invoker, _ingredients_printer, 0
      you_have_been_terminated
    end
  end

  it 'can return functions' do
    expect_execution to_print: [42]

    # Note: Using lambdas as Ruby functions don't map directly
    # _function_generator = lambda do
    #   _generated_function = -> { print 42 }
    #   return _generated_function
    # end
    # _forty_two_printer = _function_generator.()
    # _forty_two_printer.()
    ArnoldCPM.totally_recall do
      listen_to_me_very_carefully _function_generator
      give_these_people_air
        listen_to_me_very_carefully _generated_function
        give_these_people_air
          talk_to_the_hand 42
        hasta_la_vista_baby

        ill_be_back _generated_function
      hasta_la_vista_baby

      its_showtime
        get_your_ass_to_mars _forty_two_printer
        do_it_now _function_generator

        do_it_now _forty_two_printer
      you_have_been_terminated
    end
  end

  it 'defines new inner functions for each function invocation' do
    expect_execution to_print: [0], not_to_print: [1]

    # Note: Using lambdas as Ruby functions don't map directly
    # _define_function = lambda do
    #   _inner_function = -> {}
    #   return _inner_function
    # end
    # _first_invocation = _define_function.()
    # _second_invocation = _define_function.()
    # _are_the_two_functions_identical = _first_invocation == _second_invocation
    # print _are_the_two_functions_identical
    ArnoldCPM.totally_recall do
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

        talk_to_the_hand _are_the_two_functions_identical
      you_have_been_terminated
    end
  end

  it 'supports basic recursion' do
    expect_execution to_print: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], not_to_print: [11]

    # def _count(_from, _to)
    #   print _from
    #   _next = _from + 1
    #   _should_terminate = _next > _to

    #   if _should_terminate
    #     return
    #   end

    #   _count(_next, _to)
    # end
    # _count(1, 10)
    ArnoldCPM.totally_recall do
      listen_to_me_very_carefully _count
      i_need_your_clothes_your_boots_and_your_motorcycle _from
      i_need_your_clothes_your_boots_and_your_motorcycle _to
        talk_to_the_hand _from

        get_to_the_chopper _next
        here_is_my_invitation _from
        get_up 1
        enough_talk

        get_to_the_chopper _should_terminate
        here_is_my_invitation _next
        let_off_some_steam_bennet _to
        enough_talk

        because_im_going_to_say_please _should_terminate
          ill_be_back
        you_have_no_respect_for_logic

        do_it_now _count, _next, _to
      hasta_la_vista_baby

      its_showtime
        do_it_now _count, 1, 10
      you_have_been_terminated
    end
  end

  it 'can calculate fibonacci(20) recursively' do
    expect_execution to_print: [6765]

    # def _fibonacci(_n)
    #   _is_less_than_two = 2 > _n

    #   if _is_less_than_two
    #     return _n
    #   end

    #   _n_minus_one = _n - 1
    #   _n_minus_two = _n - 2

    #   _fibonacci_n_minus_one = _fibonacci(_n_minus_one)
    #   _fibonacci_n_minus_two = _fibonacci(_n_minus_two)

    #   _fibonacci_n = _fibonacci_n_minus_one + _fibonacci_n_minus_two
    #   return _fibonacci_n
    # end
    ArnoldCPM.totally_recall do
      listen_to_me_very_carefully _fibonacci
      i_need_your_clothes_your_boots_and_your_motorcycle _n
      give_these_people_air
        get_to_the_chopper _is_less_than_two
        here_is_my_invitation 2
        let_off_some_steam_bennet _n
        enough_talk

        because_im_going_to_say_please _is_less_than_two
          ill_be_back _n
        you_have_no_respect_for_logic

        get_to_the_chopper _n_minus_one
        here_is_my_invitation _n
        get_down 1
        enough_talk

        get_to_the_chopper _n_minus_two
        here_is_my_invitation _n
        get_down 2
        enough_talk

        get_your_ass_to_mars _fibonacci_n_minus_one
        do_it_now _fibonacci, _n_minus_one

        get_your_ass_to_mars _fibonacci_n_minus_two
        do_it_now _fibonacci, _n_minus_two

        get_to_the_chopper _fibonacci_n
        here_is_my_invitation _fibonacci_n_minus_one
        get_up _fibonacci_n_minus_two
        enough_talk

        ill_be_back _fibonacci_n
      hasta_la_vista_baby

      its_showtime
        get_your_ass_to_mars _fibonacci_20
        do_it_now _fibonacci, 20

        talk_to_the_hand _fibonacci_20
      you_have_been_terminated
    end
  end

  it 'can use closures in very convoluted ways' do
    expect_execution to_print: [9, 8, 7, 6, 5, 4, 3, 2, 1, 0], not_to_print: [10, -1]

    # You are actually reading this, heh?
    # Creates a linked list using closures with the numbers 0..9 and prints it
    ArnoldCPM.totally_recall do
      listen_to_me_very_carefully _null
      hasta_la_vista_baby

      listen_to_me_very_carefully _cons
      i_need_your_clothes_your_boots_and_your_motorcycle _head
      i_need_your_clothes_your_boots_and_your_motorcycle _tail
      give_these_people_air
        listen_to_me_very_carefully _anon
        i_need_your_clothes_your_boots_and_your_motorcycle _func
        give_these_people_air
          get_your_ass_to_mars _result
          do_it_now _func, _head, _tail

          ill_be_back _result
        hasta_la_vista_baby

        ill_be_back _anon
      hasta_la_vista_baby

      listen_to_me_very_carefully _car
      i_need_your_clothes_your_boots_and_your_motorcycle _pair
      give_these_people_air
        listen_to_me_very_carefully _anon
        i_need_your_clothes_your_boots_and_your_motorcycle _head
        i_need_your_clothes_your_boots_and_your_motorcycle _tail
        give_these_people_air
          ill_be_back _head
        hasta_la_vista_baby

        get_your_ass_to_mars _result
        do_it_now _pair, _anon

        ill_be_back _result
      hasta_la_vista_baby

      listen_to_me_very_carefully _cdr
      i_need_your_clothes_your_boots_and_your_motorcycle _pair
      give_these_people_air
        listen_to_me_very_carefully _anon
        i_need_your_clothes_your_boots_and_your_motorcycle _head
        i_need_your_clothes_your_boots_and_your_motorcycle _tail
        give_these_people_air
          ill_be_back _tail
        hasta_la_vista_baby

        get_your_ass_to_mars _result
        do_it_now _pair, _anon

        ill_be_back _result
      hasta_la_vista_baby

      listen_to_me_very_carefully _create_long_list
      i_need_your_clothes_your_boots_and_your_motorcycle _length
      give_these_people_air
        get_to_the_chopper _next_element
        here_is_my_invitation _length
        get_down 1
        enough_talk

        get_to_the_chopper _is_last_element
        here_is_my_invitation _next_element
        you_are_not_you_you_are_me 0
        enough_talk

        because_im_going_to_say_please _is_last_element
          get_your_ass_to_mars _start_pair
          do_it_now _cons, _next_element, _null

          ill_be_back _start_pair
        bull_shit
          get_your_ass_to_mars _list_with_previous_elements
          do_it_now _create_long_list, _next_element

          get_your_ass_to_mars _list_with_next_element
          do_it_now _cons, _next_element, _list_with_previous_elements

          ill_be_back _list_with_next_element
        you_have_no_respect_for_logic
      hasta_la_vista_baby

      listen_to_me_very_carefully _print_list
      i_need_your_clothes_your_boots_and_your_motorcycle _list

        get_to_the_chopper _list_ended
        here_is_my_invitation _list
        you_are_not_you_you_are_me _null
        enough_talk

        because_im_going_to_say_please _list_ended
        bull_shit
          get_your_ass_to_mars _head
          do_it_now _car, _list
          get_your_ass_to_mars _tail
          do_it_now _cdr, _list

          talk_to_the_hand _head

          do_it_now _print_list, _tail
        you_have_no_respect_for_logic
      hasta_la_vista_baby

      its_showtime
        get_your_ass_to_mars _numbers_nine_to_zero
        do_it_now _create_long_list, 10

        do_it_now _print_list, _numbers_nine_to_zero
      you_have_been_terminated
    end
  end

  def expect_execution(to_print: [], not_to_print: [])
    to_print.each do |value_to_be_printed|
      expect(printer).to receive(:print).with(value_to_be_printed).ordered
    end

    not_to_print.each do |value_not_to_be_printed|
      expect(printer).to_not receive(:print).with(value_not_to_be_printed)
    end
  end
end
