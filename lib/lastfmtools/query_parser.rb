module Lastfmtools
  class QueryParser
    def initialize
      @analyzer = Analyzer.new({})
      @backuper = Backuper.new(1, 2, 3)
    end

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

    def ratings_regex
      (Analyzer::RATINGS << Analyzer::BEST).join('|')
    end
    
    def show_artists(rating, genre)
      @analyzer.show_artists(rating, genre).join(', ')
    end
    
    def show_top_site_artists(genre)
      @analyzer.show_top_site_artists(genre).join(', ')
    end
    
    def show_rating_of(artist)
      rating = @analyzer.show_rating_of(artist)
      "#{artist} is #{rating}."
    end

    def sync
      @backuper.sync
      'Everything synced.'
    end

    def tagged_with(rating, artist)
      @analyzer.tagged_with?(rating, artist) ? 'Yep.' : 'Nope.'
    end
  end
end
