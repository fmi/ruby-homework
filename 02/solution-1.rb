class Song
  attr_reader :name, :artist, :album

  def initialize(name, artist, album)
    @name   = name
    @artist = artist
    @album  = album
  end
end

class Collection
  include Enumerable

  def self.parse(text)
    songs = text.lines.each_slice(4).map do |name, artist, album|
      Song.new name.chomp, artist.chomp, album.chomp
    end

    new songs
  end

  def initialize(songs)
    @songs = songs
  end

  def filter(criteria)
    Collection.new @songs.select { |song| criteria.met_by? song }
  end

  def artists
    @songs.map(&:artist).uniq
  end

  def names
    @songs.map(&:name).uniq
  end

  def albums
    @songs.map(&:album).uniq
  end

  def adjoin(other)
    Collection.new songs | other.songs
  end

  def each(&block)
    @songs.each(&block)
  end

  protected

  def songs
    @songs
  end
end

module Criteria
  def self.name(name)
    NameMatches.new name
  end

  def self.artist(artist)
    ArtistMatches.new artist
  end

  def self.album(album)
    AlbumMatches.new album
  end

  class Criterion
    def &(other)
      Conjunction.new self, other
    end

    def |(other)
      Disjunction.new self, other
    end

    def !
      Negation.new self
    end
  end

  class NameMatches < Criterion
    def initialize(name)
      @name = name
    end

    def met_by?(song)
      song.name == @name
    end
  end

  class ArtistMatches < Criterion
    def initialize(artist)
      @artist = artist
    end

    def met_by?(song)
      song.artist == @artist
    end
  end

  class AlbumMatches < Criterion
    def initialize(album)
      @album = album
    end

    def met_by?(song)
      song.album == @album
    end
  end

  class Conjunction < Criterion
    def initialize(left, right)
      @left  = left
      @right = right
    end

    def met_by?(song)
      @left.met_by?(song) and @right.met_by?(song)
    end
  end

  class Disjunction < Criterion
    def initialize(left, right)
      @left  = left
      @right = right
    end

    def met_by?(song)
      @left.met_by?(song) or @right.met_by?(song)
    end
  end

  class Negation < Criterion
    def initialize(criterion)
      @criterion = criterion
    end

    def met_by?(song)
      not @criterion.met_by?(song)
    end
  end
end
