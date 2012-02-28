module Lastfmtools
  class Analyzer
    RATINGS = ['shit', 'meh', 'good', 'awesome']

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
    #   # tags is: {'punk' => ['Zebrahead'], 'hip-hop' => ['Eminem'],
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
      @tags[tag].include?(artist)
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
      awesome = intersect_tags(tag, RATINGS.last)
      good = intersect_tags(tag, RATINGS[RATINGS.size - 2])
      awesome.concat(good)[0..limit]
    end

    def to_s
      "Analyzer"
    end
  end
end
