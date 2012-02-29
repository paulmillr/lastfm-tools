class LastfmTools
  class Analyzer
    def initialize(options = {})
      @tracks = options[:tracks] || []
      @tags = options[:tags] || {}
      @tags.default = []
    end

    # Public: Selects artists that were tagged by all selected tags.
    #
    # *tags - hashmaps with artists in format {'punk' => ['Zebrahead']}
    # 
    # Examples
    # 
    #   # tags are: {'punk' => ['Zebrahead'], 'hip-hop' => ['Eminem'],
    #   #   'good' => 'Zebrahead'}
    #   intersect_tags('good', 'punk')
    #   # => ['Zebrahead']
    # 
    # Returns an array of matched artists.
    def intersect_tags(*tags)
      tags.map { |tag| @tags[tag] }.reduce do |memo, tag|
        memo & tag
      end
    end

    # Public: Shows if some artist was tagged by tag.
    # 
    # Examples
    # 
    #   tagged_with('punk', 'Zebrahead')
    #   # => true
    #   tagged_with('not-existing-tag', 'non-existing-artist')
    #   # => false
    # 
    # Returns boolean value.
    def tagged_with?(tag, artist)
      if tag == BEST_RATING
        best_artist?(artist)
      else
        # This should ignore case.
        !!@tags[tag].select do |tag_artist|
          tag_artist.downcase == artist
        end
      end
    end

    # Examples
    # 
    #   show_artists('good', 'punk')
    #   # => 
    #   show_artists('meh', 'witch house', true)
    #   # => 
    # 
    # 
    def show_artists(rating, genre)
      if rating == BEST_RATING
        get_best_artists(genre)
      else
        intersect_tags(rating, genre)
      end
    end

    # Public: Shows rating of artist.
    #
    # artist - artist name.
    # 
    # Examples
    # 
    #   show_rating_of('Zebrahead')
    #   # => 'good'
    #   show_rating_of('non-existing')
    #   # => nil
    # 
    # Returns rating string or nil.
    def show_rating_of(artist)
      artist_rating = nil
      RATINGS.each do |rating|
        artist_rating = rating if tagged_with?(rating, artist)
      end
      artist_rating
    end

    # Public: Selects best artists tagged by tag.
    # Selects only artists that have "best" and "almost best" ratings.
    #
    # tag - tracks of which tag should be selected.
    # limit - how many tracks should method return.
    # 
    # Examples
    # 
    #   best_of_tag('punk')
    #   # => ['Zebrahead']
    #   best_of_tag('hip-hop')
    #   # => ['Eminem']
    # 
    # Returns an array of matched artists.
    def best_of_tag(tag, limit = 7)
      best = intersect_tags(tag, awesome) + intersect_tags(tag, good)
      best[0..limit]
    end

    private
    
    def awesome
      RATINGS.last
    end

    def good
      RATINGS[RATINGS.size - 2]
    end
    
    def best_consists_of
      [awesome, good]
    end

    def best_artist?(artist)
      best = false
      best_consists_of.map { |rating| best ||= tagged_with?(rating, artist) }
      best
    end
    
    def get_best_artists(genre)
      best_consists_of.map { |rating| intersect_tags(rating, genre) }.flatten
    end
  end
end
