describe ArnoldCPM do
  let(:printer) { double('printer') }

  before(:each) do
    ArnoldCPM.printer = printer
  end

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

  it 'can branch with simple if-else statements' do
    expect_execution to_print: [22], not_to_print: [11]

    # if false
    #   print 11
    # else
    #   print 22
    # end
    ArnoldCPM.totally_recall do
      its_showtime
        because_im_going_to_say_please i_lied
          talk_to_the_hand 11
        bull_shit
          talk_to_the_hand 22
        you_have_no_respect_for_logic
      you_have_been_terminated
    end
  end

  it 'can define and call functions with arguments' do
    expect_execution to_print: [11, 22, 33]

    # def _printing_function(_n)
    #   print(_n)
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

  it 'can return without value in void functions' do
    expect_execution not_to_print: [42]

    # def _void_function
    #  return
    #  print 42
    # end
    # _void_function()
    ArnoldCPM.totally_recall do
      listen_to_me_very_carefully _void_function
        ill_be_back
        talk_to_the_hand 42
      hasta_la_vista_baby

      its_showtime
        do_it_now _void_function
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
