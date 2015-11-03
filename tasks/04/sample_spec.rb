describe Card do
  it 'can be converted to a string' do
    expect(Card.new(10, :spades).to_s).to eq '10 of Spades'
  end
end

describe WarDeck do
  it 'implements Enumerable' do
    expect(WarDeck).to include(Enumerable)
  end

  it 'fills the deck if no initialize parameters are given' do
    deck = WarDeck.new

    expect(deck.size).to eq 52
  end

  it 'implements all required methods' do
    deck = WarDeck.new

    expect(deck).to respond_to(:size)
    expect(deck).to respond_to(:draw_top_card)
    expect(deck).to respond_to(:draw_bottom_card)
    expect(deck).to respond_to(:top_card)
    expect(deck).to respond_to(:bottom_card)
    expect(deck).to respond_to(:shuffle)
    expect(deck).to respond_to(:sort)
    expect(deck).to respond_to(:to_s)
    expect(deck).to respond_to(:deal)
  end

  describe '#sort' do
    it 'sorts two cards of the same suit' do
      two_of_clubs  = Card.new(2, :clubs)
      jack_of_clubs = Card.new(:jack, :clubs)

      deck = WarDeck.new([two_of_clubs, jack_of_clubs])

      expect(deck.sort.to_a).to eq [jack_of_clubs, two_of_clubs]
    end
  end

  describe 'hand' do
    subject(:hand) { WarDeck.new.deal }

    it 'implements all required methods' do
      expect(hand).to respond_to(:size)
      expect(hand).to respond_to(:play_card)
      expect(hand).to respond_to(:allow_face_up?)
    end

    describe '#deal' do
      it 'deals 26 cards' do
        expect(hand.size).to eq 26
      end
    end

    describe '#allow_face_up?' do
      it 'returns false if the cards are more than 3' do
        expect(hand.allow_face_up?).to eq false
      end
    end
  end
end

describe BeloteDeck do
  it 'implements all required methods' do
    deck = BeloteDeck.new

    expect(deck).to respond_to(:size)
    expect(deck).to respond_to(:draw_top_card)
    expect(deck).to respond_to(:draw_bottom_card)
    expect(deck).to respond_to(:top_card)
    expect(deck).to respond_to(:bottom_card)
    expect(deck).to respond_to(:shuffle)
    expect(deck).to respond_to(:sort)
    expect(deck).to respond_to(:to_s)
    expect(deck).to respond_to(:deal)
  end

  describe 'hand' do
    subject(:hand) { BeloteDeck.new.deal }

    it 'implements all required methods' do
      expect(hand).to respond_to(:size)
      expect(hand).to respond_to(:highest_of_suit)
      expect(hand).to respond_to(:belote?)
      expect(hand).to respond_to(:tierce?)
      expect(hand).to respond_to(:quarte?)
      expect(hand).to respond_to(:quint?)
      expect(hand).to respond_to(:carre_of_jacks?)
      expect(hand).to respond_to(:carre_of_nines?)
      expect(hand).to respond_to(:carre_of_aces?)
    end
  end
end

describe SixtySixDeck do
  it 'implements all required methods' do
    deck = SixtySixDeck.new

    expect(deck).to respond_to(:size)
    expect(deck).to respond_to(:draw_top_card)
    expect(deck).to respond_to(:draw_bottom_card)
    expect(deck).to respond_to(:top_card)
    expect(deck).to respond_to(:bottom_card)
    expect(deck).to respond_to(:shuffle)
    expect(deck).to respond_to(:sort)
    expect(deck).to respond_to(:to_s)
    expect(deck).to respond_to(:deal)
  end

  describe 'hand' do
    subject(:hand) { SixtySixDeck.new.deal }

    it 'implements all required methods' do
      expect(hand).to respond_to(:size)
      expect(hand).to respond_to(:twenty?)
      expect(hand).to respond_to(:forty?)
    end
  end
end
