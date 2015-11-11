class Card < Struct.new(:rank, :suit)
  def to_s
    "#{rank.to_s.capitalize} of #{suit.to_s.capitalize}"
  end
end

class Deck
  class Hand
    attr_reader :cards

    def initialize(game, cards)
      @game = game
      @cards = cards
    end

    def size
      @cards.size
    end
  end

  include Enumerable

  def initialize(suits, ranks, cards)
    @suits = suits
    @ranks = ranks

    if cards
      @cards = cards
    else
      @cards = @suits.product(@ranks).map { |suit, rank| Card.new(rank, suit) }
    end
  end

  def each(&block)
    @cards.each(&block)
  end

  def size
    @cards.size
  end

  def draw_top_card
    @cards.shift
  end

  def draw_bottom_card
    @cards.pop
  end

  def top_card
    @cards.first
  end

  def bottom_card
    @cards.last
  end

  def shuffle
    @cards.shuffle!
  end

  def compare_cards(card_one, card_two)
    card_grade(card_one) <=> card_grade(card_two)
  end

  def sort
    @cards.sort_by! { |card| card_grade(card) }
    @cards.reverse!
  end

  def to_s
    @cards.map(&:to_s).join("\n")
  end

  private

  def card_grade(card)
    suit_grade = @suits.find_index(card.suit)
    rank_grade = @ranks.find_index(card.rank)

    suit_grade * @ranks.size + rank_grade
  end
end

class WarDeck < Deck
  SUITS = [:clubs, :diamonds, :hearts, :spades]
  RANKS = [2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king, :ace]

  def initialize(cards = nil)
    super(SUITS, RANKS, cards)
  end

  def deal
    cards_in_hand = @cards.shift(Hand::INITIAL_SIZE)

    Hand.new(self, cards_in_hand)
  end

  class Hand < Deck::Hand
    INITIAL_SIZE = 26

    def play_card
      @cards.pop
    end

    def allow_face_up?
      @cards.size <= 3
    end
  end
end

class BeloteDeck < Deck
  SUITS = [:clubs, :diamonds, :hearts, :spades]
  RANKS = [7, 8, 9, :jack, :queen, :king, 10, :ace]

  def initialize(cards = nil)
    super(SUITS, RANKS, cards)
  end

  def deal
    cards_in_hand = @cards.shift(Hand::INITIAL_SIZE)

    Hand.new(self, cards_in_hand)
  end

  class Hand < Deck::Hand
    INITIAL_SIZE = 8

    def highest_of_suit(suit)
      @cards.select { |card| card.suit == suit }.sort do |card_one, card_two|
        @game.compare_cards(card_one, card_two)
      end.last
    end

    def belote?
      SUITS.any? do |suit|
        has_queen = @cards.include?(Card.new(:queen, suit))
        has_king = @cards.include?(Card.new(:king, suit))

        has_queen && has_king
      end
    end

    def tierce?
      consecutive_cards?(3)
    end

    def quarte?
      consecutive_cards?(4)
    end

    def quint?
      consecutive_cards?(5)
    end

    def carre_of_jacks?
      carre?(:jack)
    end

    def carre_of_nines?
      carre?(9)
    end

    def carre_of_aces?
      carre?(:ace)
    end

    private

    def carre?(card_rank)
      @cards.select { |card| card.rank == card_rank }.size == 4
    end

    def consecutive_cards?(card_count)
      sorted_cards = sort_by_rank(@cards)

      SUITS.any? do |suit|
        cards_of_suit = sorted_cards.select { |card| card.suit == suit }

        next false if cards_of_suit.size < card_count

        cards_of_suit.each_cons(card_count).any? do |cards|
          consecutive_ranks?(cards)
        end
      end
    end

    def consecutive_ranks?(cards)
      cards.each_cons(2).all? do |card_one, card_two|
        index_of_rank(card_one.rank) + 1 == index_of_rank(card_two.rank)
      end
    end

    def sort_by_rank(cards)
      cards.sort_by { |card| index_of_rank(card.rank) }
    end

    def index_of_rank(rank)
      RANKS.find_index(rank)
    end
  end
end

class SixtySixDeck < Deck
  SUITS = [:clubs, :diamonds, :hearts, :spades]
  RANKS = [9, :jack, :queen, :king, 10, :ace]

  def initialize(cards = nil)
    super(SUITS, RANKS, cards)
  end

  def deal
    cards_in_hand = @cards.shift(Hand::INITIAL_SIZE)

    Hand.new(self, cards_in_hand)
  end

  class Hand < Deck::Hand
    INITIAL_SIZE = 6

    def twenty?(trump_suit)
      pair_of_queen_and_king?(SUITS - [trump_suit])
    end

    def forty?(trump_suit)
      pair_of_queen_and_king?([trump_suit])
    end

    private

    def pair_of_queen_and_king?(allowed_suits)
      allowed_suits.any? do |suit|
        has_queen = @cards.include?(Card.new(:queen, suit))
        has_king = @cards.include?(Card.new(:king, suit))

        has_queen && has_king
      end
    end
  end
end
