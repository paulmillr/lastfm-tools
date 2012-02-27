require 'lastfm/backuper'

class Lastfmtools
  class Analyzer
    def initialize(tags_map)
      @tags_map = tags_map
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
      tags.map {|tag| @tags_map[tag]}.reduce do |memo, tag|
        memo & tag
      end
    end

    def tagged_with?(artist, tag)
      @tags_map[tag].include?(artist)
    end

    def to_s
      "Analyzer"
    end
  end
end
