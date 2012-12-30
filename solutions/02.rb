class Collection
  include Enumerable

  attr_reader :songs

  def Collection.parse(text)
    songs = text.split(/\n/).each_slice(4)
    .map { |a| Song.new(a[0], a[1], a[2]) }
    Collection.new songs
  end

  def initialize(songs)
    @songs = songs
  end

  def each
    @songs.each { |song| yield song }
  end

  def artists
    map { |s| s.artist }.uniq
  end

  def albums
    map { |s| s.album }.uniq
  end

  def names
    map { |s| s.name }.uniq
  end

  def filter(criteria)
    Collection.new select { |s| criteria.filter.call(s) }
  end

  def adjoin(other)
    Collection.new @songs | other.songs
  end

  def |(other)
    adjoin other
  end
end

class Criteria
  attr_reader :filter

  def initialize(&block)
    @filter = Proc.new(&block)
  end

  def Criteria.artist(artist_name)
    Criteria.new { |s| s.artist == artist_name }
  end

  def Criteria.album(album_name)
    Criteria.new { |s| s.album == album_name }
  end

  def Criteria.name(song_name)
    Criteria.new { |s| s.name == song_name }
  end

  def |(other)
    Criteria.new { |s| filter.call(s) | other.filter.call(s) }
  end

  def &(other)
    Criteria.new { |s| filter.call(s) & other.filter.call(s) }
  end

  def !
    Criteria.new { |s| !filter.call(s) }
  end
end

class Song
  attr_reader :artist, :album, :name

  def initialize(name, artist, album)
    @name, @artist, @album = name, artist, album
  end
end
