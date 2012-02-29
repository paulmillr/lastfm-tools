class LastfmTools
  class QueryParser
    def initialize(options = {})
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
      when /is (.+) (#{ratings_regex})\?/
        tagged_with($2, $1)
      when /show (#{ratings_regex}) (.+) artists/
        show_artists($1, $2)
      when /show (.+) artists I ha(?:d|ve)n't listened to/
        show_top_site_artists($1)
      when /sync/
        sync
      when /what is (.+)\?/
        show_rating_of($1)
      else
        raise SyntaxError.new('Cannot parse query')
      end
    end

    private
    
    def read_backups
      tracks = @backuper.read_backup(:tracks)
      tags = @backuper.read_backup(:tags)
      @analyzer = Analyzer.new(tracks: tracks, tags: tags)
    end

    def ratings_regex
      (RATINGS.clone << BEST_RATING).join('|')
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
end
