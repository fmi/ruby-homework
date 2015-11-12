shared_examples 'a deck' do |klass, suits:, ranks:|
  subject(:deck_class) { Object.const_get(klass) }

  let(:ace_of_spades) { Card.new(:ace, :spades) }
  let(:nine_of_clubs) { Card.new(9, :clubs) }
  let(:small_deck) { deck_class.new([ace_of_spades, nine_of_clubs]) }

  it 'implements Enumerable' do
    expect(deck_class).to include(Enumerable)
    expect(small_deck).to respond_to(:each)
    expect(small_deck.to_a).to eq [ace_of_spades, nine_of_clubs]
  end

  it 'fills the deck if no initialize parameters are given' do
    deck = deck_class.new
    all_available_cards = suits.product(ranks).map { |suit, rank| Card.new(rank, suit) }

    expect(deck.to_a).to match_array all_available_cards
  end

  describe '#size' do
    it 'returns the size of the deck' do
      expect(small_deck.size).to eq 2
    end
  end

  describe '#draw_top_card' do
    it 'pops the top-most card' do
      expect(small_deck.draw_top_card).to eq ace_of_spades
      expect(small_deck.to_a).to eq [nine_of_clubs]
    end
  end

  describe '#draw_bottom_card' do
    it 'pops the bottom-most card' do
      expect(small_deck.draw_bottom_card).to eq nine_of_clubs
      expect(small_deck.to_a).to eq [ace_of_spades]
    end
  end

  describe '#top' do
    it 'peeks at the top-most card' do
      expect(small_deck.top_card).to eq ace_of_spades
      expect(small_deck.to_a).to eq [ace_of_spades, nine_of_clubs]
    end
  end

  describe '#bottom' do
    it 'peeks at the bottom-most card' do
      expect(small_deck.bottom_card).to eq nine_of_clubs
      expect(small_deck.to_a).to eq [ace_of_spades, nine_of_clubs]
    end
  end

  describe '#shuffle' do
    it 'does not remove cards from the deck' do
      deck = deck_class.new

      initial_size = deck.size
      deck.shuffle

      expect(deck.size).to eq initial_size
    end
  end

  describe '#to_s' do
    it 'returns the names of the cards, each on its own line' do
      expect(small_deck.to_s.strip).to eq "Ace of Spades\n9 of Clubs"
    end
  end
end

shared_examples 'carre-checking method' do |method, rank|
  it 'returns true when there is a carre' do
    hand = BeloteDeck.new([
      Card.new(7, :clubs),
      Card.new(7, :diamonds),
      Card.new(10, :spades),
      Card.new(rank, :clubs),
      Card.new(rank, :spades),
      Card.new(rank, :diamonds),
      Card.new(rank, :hearts),
      Card.new(10, :diamonds),
    ]).deal

    expect(hand.public_send(method)).to be true
  end

  it 'returns false when there is no carre' do
    hand = BeloteDeck.new([
      Card.new(7, :clubs),
      Card.new(7, :diamonds),
      Card.new(10, :spades),
      Card.new(10, :clubs),
      Card.new(rank, :spades),
      Card.new(rank, :diamonds),
      Card.new(rank, :hearts),
      Card.new(8, :diamonds),
    ]).deal

    expect(hand.public_send(method)).to be false
  end
end

describe 'Card' do
  let(:suits) { [:clubs, :diamonds, :hearts, :spades] }
  let(:ranks) { [2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king, :ace] }

  describe '#to_s' do
    it 'stringifies and capitalizes the rank and suit' do
      all_cards = suits.product(ranks).map { |suit, rank| Card.new(rank, suit) }
      all_card_names = suits.product(ranks).map do |suit, rank|
        "#{rank.to_s.capitalize} of #{suit.to_s.capitalize}"
      end

      expect(all_cards.map(&:to_s)).to eq all_card_names
    end
  end

  describe 'readers' do
    it 'has readers for rank and suit' do
      card = Card.new(:jack, :spades)

      expect(card.rank).to eq :jack
      expect(card.suit).to eq :spades
    end
  end

  describe '#==' do
    it 'compares two cards by their rank and suit' do
      expect(Card.new(4, :spades)).to eq Card.new(4, :spades)
      expect(Card.new(4, :spades)).to_not eq Card.new(4, :clubs)
      expect(Card.new(2, :clubs)).to_not eq Card.new(4, :clubs)
      expect(Card.new(2, :hearts)).to_not eq Card.new(:jack, :diamonds)
    end
  end
end

describe 'WarDeck' do
  it_behaves_like 'a deck', 'WarDeck',
                            suits: [:clubs, :diamonds, :hearts, :spades],
                            ranks: [2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king, :ace]

  describe '#sort' do
    it 'sorts the cards in the defined order' do
      ace_of_clubs   = Card.new(:ace, :clubs)
      jack_of_spades = Card.new(:jack, :spades)
      two_of_clubs   = Card.new(2, :clubs)
      ten_of_hearts  = Card.new(10, :hearts)

      cards = [ace_of_clubs, jack_of_spades, two_of_clubs, ten_of_hearts]

      deck = WarDeck.new(cards)

      expect(deck.sort.to_a).to eq [jack_of_spades, ten_of_hearts, ace_of_clubs, two_of_clubs]
    end
  end

  describe 'hand' do
    describe '#deal' do
      it 'deals 26 cards' do
        hand = WarDeck.new.deal

        expect(hand.size).to eq 26
      end
    end

    describe '#allow_face_up?' do
      let(:hand) { WarDeck.new.deal }

      it 'returns false if the cards are more than 3' do
        expect(hand.allow_face_up?).to eq false
      end

      it 'returns true if the cards are less than or equal to 3' do
        23.times { hand.play_card }

        expect(hand.allow_face_up?).to eq true

        hand.play_card
        expect(hand.allow_face_up?).to eq true

        hand.play_card
        expect(hand.allow_face_up?).to eq true
      end
    end
  end
end

describe 'BeloteDeck' do
  it_behaves_like 'a deck', 'BeloteDeck',
                            suits: [:clubs, :diamonds, :hearts, :spades],
                            ranks: [7, 8, 9, :jack, :queen, :king, 10, :ace]

  describe '#sort' do
    it 'sorts the cards in the defined order' do
      ace_of_clubs   = Card.new(:ace, :clubs)
      jack_of_spades = Card.new(:jack, :spades)
      seven_of_clubs = Card.new(7, :clubs)
      ten_of_hearts  = Card.new(10, :hearts)

      cards = [ace_of_clubs, jack_of_spades, seven_of_clubs, ten_of_hearts]

      deck = BeloteDeck.new(cards)

      expect(deck.sort.to_a).to eq [jack_of_spades, ten_of_hearts, ace_of_clubs, seven_of_clubs]
    end
  end

  describe 'hand' do
    describe '#deal' do
      it 'deals 8 cards' do
        hand = BeloteDeck.new.deal

        expect(hand.size).to eq 8
      end
    end

    describe '#highest_of_suit' do
      it 'returns the strongest card of the specified suit' do
        hand = BeloteDeck.new([
          Card.new(:ace, :clubs),
          Card.new(:jack, :spades),
          Card.new(7, :clubs),
          Card.new(10, :hearts),
          Card.new(:queen, :clubs),
          Card.new(:king, :spades),
          Card.new(8, :diamonds),
          Card.new(9, :clubs),
        ]).deal

        expect(hand.highest_of_suit(:clubs)).to eq Card.new(:ace, :clubs)
        expect(hand.highest_of_suit(:spades)).to eq Card.new(:king, :spades)
        expect(hand.highest_of_suit(:diamonds)).to eq Card.new(8, :diamonds)
      end
    end

    describe '#belote?' do
      it 'returns true if there is a king and a queen of the same suit' do
        hand = BeloteDeck.new([
          Card.new(:ace, :clubs),
          Card.new(:jack, :spades),
          Card.new(7, :clubs),
          Card.new(10, :hearts),
          Card.new(:queen, :clubs),
          Card.new(:king, :clubs),
          Card.new(8, :diamonds),
          Card.new(9, :clubs),
        ]).deal

        expect(hand.belote?).to be true
      end

      it 'returns false when there is no king and queen of the same suit' do
        hand = BeloteDeck.new([
          Card.new(:ace, :clubs),
          Card.new(:jack, :spades),
          Card.new(7, :clubs),
          Card.new(10, :hearts),
          Card.new(:queen, :clubs),
          Card.new(:king, :hearts),
          Card.new(8, :diamonds),
          Card.new(9, :clubs),
        ]).deal

        expect(hand.belote?).to be false
      end
    end

    describe '#tierce?' do
      context 'with tierce' do
        it 'returns true for cards with names' do
          hand = BeloteDeck.new([
            Card.new(:ace, :clubs),
            Card.new(:jack, :clubs),
            Card.new(7, :clubs),
            Card.new(10, :hearts),
            Card.new(:queen, :clubs),
            Card.new(:king, :clubs),
            Card.new(8, :diamonds),
            Card.new(9, :clubs),
          ]).deal

          expect(hand.tierce?).to be true
        end

        it 'returns true for cards with numbers' do
          hand = BeloteDeck.new([
            Card.new(:ace, :clubs),
            Card.new(:jack, :spades),
            Card.new(7, :diamonds),
            Card.new(10, :hearts),
            Card.new(:king, :hearts),
            Card.new(:king, :clubs),
            Card.new(8, :diamonds),
            Card.new(9, :diamonds),
          ]).deal

          expect(hand.tierce?).to be true
        end
      end

      context 'without tierce' do
        it 'does not confuse cards with different suits' do
          hand = BeloteDeck.new([
            Card.new(7, :clubs),
            Card.new(7, :diamonds),
            Card.new(7, :hearts),
            Card.new(7, :spades),
            Card.new(:jack, :hearts),
            Card.new(:queen, :clubs),
            Card.new(:king, :spades),
            Card.new(8, :diamonds),
          ]).deal

          expect(hand.tierce?).to be false
        end
      end
    end

    describe '#quarte?' do
      it 'detects four cards with increasing ranks' do
        hand = BeloteDeck.new([
          Card.new(7, :clubs),
          Card.new(7, :diamonds),
          Card.new(9, :spades),
          Card.new(10, :diamonds),
          Card.new(:jack, :spades),
          Card.new(:queen, :spades),
          Card.new(:king, :spades),
          Card.new(:ace, :spades),
        ]).deal

        expect(hand.quarte?).to be true
      end

      it 'does not return true if there is no quarte' do
        hand = BeloteDeck.new([
          Card.new(7, :clubs),
          Card.new(7, :diamonds),
          Card.new(9, :spades),
          Card.new(10, :clubs),
          Card.new(:jack, :spades),
          Card.new(:queen, :diamonds),
          Card.new(:king, :spades),
          Card.new(8, :diamonds),
        ]).deal

        expect(hand.quarte?).to be false
      end
    end

    describe '#quint?' do
      it 'detects five cards with increasing ranks' do
        hand = BeloteDeck.new([
          Card.new(7, :clubs),
          Card.new(7, :diamonds),
          Card.new(9, :spades),
          Card.new(10, :spades),
          Card.new(:jack, :spades),
          Card.new(:queen, :spades),
          Card.new(:king, :spades),
          Card.new(8, :diamonds),
        ]).deal

        expect(hand.quint?).to be true
      end

      it 'does not return true if there is no quint' do
        hand = BeloteDeck.new([
          Card.new(7, :clubs),
          Card.new(7, :diamonds),
          Card.new(9, :spades),
          Card.new(10, :clubs),
          Card.new(:jack, :spades),
          Card.new(:queen, :diamonds),
          Card.new(:king, :spades),
          Card.new(8, :diamonds),
        ]).deal

        expect(hand.quint?).to be false
      end
    end

    describe '#carre_of_jacks?' do
      it_behaves_like 'carre-checking method', :carre_of_jacks?, :jack
    end

    describe '#carre_of_nines?' do
      it_behaves_like 'carre-checking method', :carre_of_nines?, 9
    end

    describe '#carre_of_aces?' do
      it_behaves_like 'carre-checking method', :carre_of_aces?, :ace
    end
  end
end

describe 'SixtySixDeck' do
  it_behaves_like 'a deck', 'SixtySixDeck',
                            suits: [:clubs, :diamonds, :hearts, :spades],
                            ranks: [9, :jack, :queen, :king, 10, :ace]

  describe '#sort' do
    it 'sorts the cards in the defined order' do
      ace_of_clubs   = Card.new(:ace, :clubs)
      jack_of_spades = Card.new(:jack, :spades)
      two_of_clubs   = Card.new(9, :clubs)
      ten_of_hearts  = Card.new(10, :hearts)

      cards = [ace_of_clubs, jack_of_spades, two_of_clubs, ten_of_hearts]

      deck = SixtySixDeck.new(cards)

      expect(deck.sort.to_a).to eq [jack_of_spades, ten_of_hearts, ace_of_clubs, two_of_clubs]
    end
  end

  describe 'hand' do
    describe '#deal' do
      it 'deals 6 cards' do
        hand = SixtySixDeck.new.deal

        expect(hand.size).to eq 6
      end
    end

    describe '#twenty?' do
      it 'returns true for king and queen not of the trump suit' do
        hand = SixtySixDeck.new([
          Card.new(:ace, :clubs),
          Card.new(:jack, :spades),
          Card.new(9, :clubs),
          Card.new(10, :hearts),
          Card.new(:queen, :clubs),
          Card.new(:king, :clubs),
        ]).deal

        expect(hand.twenty?(:hearts)).to be true
      end

      it 'returns false for king and queen of the trump suit' do
        hand = SixtySixDeck.new([
          Card.new(:ace, :clubs),
          Card.new(:jack, :spades),
          Card.new(9, :clubs),
          Card.new(10, :hearts),
          Card.new(:queen, :clubs),
          Card.new(:king, :clubs),
        ]).deal

        expect(hand.twenty?(:clubs)).to be false
      end

      it 'returns false for hands without a king and queen of the same suit' do
        hand = SixtySixDeck.new([
          Card.new(:ace, :clubs),
          Card.new(:jack, :spades),
          Card.new(9, :clubs),
          Card.new(10, :hearts),
          Card.new(:queen, :clubs),
          Card.new(:king, :spades),
        ]).deal

        expect(hand.twenty?(:hearts)).to be false
      end
    end
  end
end
