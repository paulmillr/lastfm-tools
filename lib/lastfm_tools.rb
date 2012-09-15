require 'appscript'
require 'yaml'

class LastfmTools
  require_relative 'lastfm_tools/analyzer'
  require_relative 'lastfm_tools/backuper'

  attr_reader :backuper, :analyzer

  BEST_RATING = 'best'
  RATINGS = ['shit', 'meh', 'good']

  def self.read_config(path = nil)
    path = File.join(Dir::home, '.lastfm_tools') unless path
    YAML::load_file(path)
  rescue Errno::ENOENT
    self.write_example_config
    puts "Example config has been created in #{path}. Fill it with your info"
  end

  def self.write_example_config(path = nil)
    example = {
      api_key: '',
      api_secret: '',
      backup_location: '',
      token: '',
      user: ''
    }
    File.open(path, 'w') { |file| file.write(example.to_yaml) }
  end

  def initialize(options = nil)
    options = LastfmTools.read_config unless options
    @backuper = Backuper.new(
      options[:backup_location] || '',
      options[:api_key] || '',
      options[:api_secret] || ''
    )
    @backuper.user = options[:user]
    read_backups
  end

  # Public: Parses query and does appropriate actions.
  #
  # query - query in english.
  #
  # Examples
  #
  #   parse('show good punk artists')
  #   # => 'Zebrahead, H2O'
  #   parse('sync')
  #   # => 'Everything synced.'
  #   parse('is eminem shit?')
  #   # => 'Nope.'
  #
  # Returns string with result of query execution.
  # Raises SyntaxError if query has unusual syntax.
  def parse(query)
    case query
    when /--help/
      <<-EOF
Usage is: `lastfmtools "query"`. Example queries:

* `sync` will sync tags user and tracks to local files in
order to not mess around Last.FM API limits in the future. Backup format
is JSON.
* `sync with itunes` will adjust tracks listen count in iTunes and
it will be equal to tracks listen count on last.fm.
* `show best hip-hop artists` will print a list of 7 hip-hop
artists i've listened to and which I tagged with tags `awesome` and `good`.
* `show witch house artists I hadn't listened to` will print a
list of [tag's top artists](http://www.last.fm/tag/witch%20house/artists)
that are not persist in my library yet.
* `is eminem awesome?` will print `yep` or
`nope`, depending on tag used for `eminem` in tag library. Also works for
`good`, `meh` and `shit`.
* `what is eminem?` will print `eminem is awesome / good / meh / shit`.
EOF
    when /is (.+) (#{ratings_regex})\?/
      tagged_with($2, $1)
    when /show (#{ratings_regex}) artists/
      show_artists_and_group_by_genre($1)
    when /show (#{ratings_regex}) (.+) artists/
      show_artists($1, $2)
    when /show (.+) artists I ha(?:d|ve)n't listened to/
      show_top_site_artists($1)
    when /sync/
      sync
    when /sync with itunes/
      sync_with_itunes
    when /what is (.+)\?/
      show_rating_of($1)
    else
      raise SyntaxError.new('Cannot parse query')
    end
  end

  def sync_with_itunes
    itunes = Appscript.app('iTunes')
    tracks = itunes.tracks.get
    plays_count = @analyzer.get_plays_count
    tracks.each do |track|
      artist = UnicodeUtils.downcase(track.artist.get)
      title = UnicodeUtils.downcase(track.name.get).slice(0, 150)
      count = plays_count.fetch(artist, {})[title]
      next unless count
      track.played_count.set(count)
    end
    true
  end

  def read_backups
    tracks = @backuper.read_backup(:tracks)
    tags = @backuper.read_backup(:tags)
    @analyzer = Analyzer.new(tracks: tracks, tags: tags)
  end

  def ratings_regex
    (RATINGS.clone << BEST_RATING).join('|')
  end

  def show_artists_and_group_by_genre(rating)
    @analyzer.show_artists_and_group_by_genre(rating).join("\n")
  end

  def show_artists(rating, genre)
    @analyzer.show_artists(rating, genre).join(', ')
  end

  def show_top_site_artists(genre)
    @backuper.get_top_site_artists(genre).join(', ')
  end

  def show_rating_of(artist)
    rating = @analyzer.show_rating_of(artist)
    if rating
      "#{artist} is #{rating}."
    else
      'There\'s no such artist in your library.'
    end
  end

  def sync
    @backuper.sync
    read_backups
    'Everything synced.'
  end

  def tagged_with(rating, artist)
    @analyzer.tagged_with?(rating, artist) ? 'Yep.' : 'Nope.'
  end
end
