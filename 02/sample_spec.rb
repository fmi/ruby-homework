describe "Collection" do
  let(:collection) { Collection.parse(SONGS) }

  it "can find all the albums in the collection" do
    collection.albums.should =~ [
      "Ten Summoner's Tales",
      'The Soul Cages',
      'Live at Blues Alley',
      'Portrait in Jazz',
      'Yield',
      'Ten',
      'One',
      'A Love Supreme',
      'Mysterioso',
    ]
  end

  it "supports a conjuction of filters" do
    filtered = collection.filter Criteria.artist('Sting') & Criteria.name('Fields of Gold')
    filtered.map(&:album).should eq ["Ten Summoner's Tales"]
  end

  it "can be adjoined with another collection" do
    sting    = collection.filter Criteria.artist('Sting')
    eva      = collection.filter Criteria.artist('Eva Cassidy')
    adjoined = sting.adjoin(eva)

    adjoined.count.should eq 4
    adjoined.names.should =~ [
      'Fields of Gold',
      'Autumn Leaves',
      'Mad About You',
    ]
  end

  SONGS = <<END
Fields of Gold
Sting
Ten Summoner's Tales

Mad About You
Sting
The Soul Cages

Fields of Gold
Eva Cassidy
Live at Blues Alley

Autumn Leaves
Eva Cassidy
Live at Blues Alley

Autumn Leaves
Bill Evans
Portrait in Jazz

Brain of J.F.K
Pearl Jam
Yield

Jeremy
Pearl Jam
Ten

Come Away With Me
Norah Johnes
One

Acknowledgment
John Coltrane
A Love Supreme

Ruby, My Dear
Thelonious Monk
Mysterioso
END
end
