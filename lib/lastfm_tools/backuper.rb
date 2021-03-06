require 'json'
require 'lastfm'
require 'set'

class LastfmTools
  class Backuper
    PAGE_SIZE = 150
    attr_accessor :user

    # Examples
    #
    #   backuper = Lastfmtools::Backuper.new(path, 'key', 'secret')
    #   backuper.user = 'paulmillr'
    #
    def initialize(backup_location, api_key, api_secret)
      @backup_location = backup_location
      @lastfm = Lastfm.new(api_key, api_secret)
    end

    def get_backup_path(type)
      File.join(@backup_location, "#{type}.json")
    end

    # Public: Reads a local backup of last.fm data.
    #
    # type - symbol or string. Currently only :tags and :tracks
    #        are supported.
    #
    # Examples
    #
    #   read_backup(:tags)
    #   # => {'punk' => ['Zebrahead']}
    #   read_backup(:tracks)
    #   # => []
    #
    # Returns object or array with parsed json from file or
    # empty object / array.
    def read_backup(type)
      File.open(get_backup_path(type), 'r') do |file|
        JSON.parse(file.read)
      end
    rescue Errno::ENOENT
      case type
      when :tracks then []
      else {}
      end
    end

    # Public: Writes a local backup of Last.FM data.
    #
    # type - symbol or string. Currently only :tags and :tracks
    #        are supported.
    # data - data that will be JSON-serialized, pretty-printed and written.
    #
    # Examples
    #
    #   write_backup(:tags, {'punk' => ['Zebrahead']})
    #   write_backup(:tracks, [{"artist": "Aphex Twin",
    #     "track": "5", "timestamp": 1313504528}])
    #
    def write_backup(type, data)
      File.open(get_backup_path(type), 'w') do |file|
        file.write(JSON.pretty_generate(data))
      end
      nil
    end

    # Public: Writes a local backup of Last.FM data.
    #
    # type - symbol or string. Currently only :tags and :tracks
    #        are supported.
    # data - data that will be JSON-serialized, pretty-printed and written.
    #
    # Examples
    #
    #   get_top_site_artists('punk')
    #   # =>
    #
    # Returns array.
    def get_top_site_artists(tag, limit = 50)
      artists = @lastfm.tag.get_top_artists(tag, limit).map do |artist|
        artist['name']
      end
      listened_artists = Set.new
      read_backup(:tracks).each do |track|
        listened_artists << track['artist']
      end
      (Set.new(artists) - listened_artists).to_a
    end

    # Public: compares local backup and API data, downloads missing or
    # changed tags and updates backup file.
    def sync_tags
      tags = read_backup(:tags)
      changed_there, changed_here = get_changed_tags
      tags.merge!(get_tags_artists(changed_there)).reject! do |tag, artists|
        changed_here.include?(tag)
      end
      write_backup(:tags, tags)
    end

    # Public: compares local backup and API data and downloads missing tracks
    # and updates backup file.
    def sync_tracks
      tracks = read_backup(:tracks)
      last_timestamp = (tracks.last || {})['timestamp']
      tracks.concat(get_tracks(last_timestamp).reverse.compact)
      write_backup(:tracks, tracks)
    end

    # Public: Does all needed syncing.
    def sync
      sync_tags
      sync_tracks
    end

    private

    # Private: Download artists that user tagged with tag from Last.FM.
    #
    # tag - title of last.fm tag.
    #
    # Examples
    #
    #   get_tag_artists('punk')
    #   # => ['Zebrahead']
    #
    # Returns a list of artist names.
    def get_tag_artists(tag)
      @lastfm.user.get_personal_tags(@user, tag, nil, 500).map do |artist|
        artist['name']
      end
    rescue Lastfm::ApiError
      sleep 15
      retry
    end

    # Private: Download tag data for all tags from Last.FM.
    #
    # with_count - should it also return a count of tagged artists?
    #
    # Examples
    #
    #   get_tags
    #   # => ['punk', 'good', 'meh']
    #   get_tags(true)
    #   # => {'punk' => 21, 'good' => 150, 'meh' => 143}
    #
    # Returns:
    # * A hash where tags are keys and number of tagged artists are
    # values if with_count option were truthy.
    # * An array with tags if with_count option were falsy.
    def get_tags(with_count = false)
      top = @lastfm.user.get_top_tags(@user, 500)

      if with_count
        Hash[top.map { |tag| [tag['name'].downcase, tag['count'].to_i] }]
      else
        top.map { |tag| tag['name'].downcase }
      end
    end

    # Private: Download tag data for specified tags from Last.FM.
    #
    # tags - array of strings (tags).
    #
    # Examples
    #
    #   get_tags_artists(['punk', 'hip-hop'])
    #   # => {'punk' => ['Zebrahead'], 'hip-hop' => ['Eminem']}
    #
    # Returns a hash, where keys are tag names and values are
    # arrays of artists which were tagged by tag.
    def get_tags_artists(tags)
      Hash[tags.map { |tag| [tag, get_tag_artists(tag)] }]
    end

    # Private: Get tags that were added or deleted at last.fm, compared
    # to current tags backup.
    #
    # Examples
    #
    #   get_changed_tags
    #   # => [['punk', 'good'], ['meh']]
    #
    # Returns an array with two elements:
    # * tags that were added at last.fm or tags which changed number of
    # tagged artists.
    # * tags that were deleted at last.fm.
    def get_changed_tags
      old_tags = read_backup(:tags)
      new_tags = get_tags(true)

      changed_there = new_tags.select do |tag, count|
        !old_tags.has_key?(tag) || old_tags[tag].size != count
      end.keys

      changed_here = old_tags.select do |tag, artists|
        !new_tags.has_key?(tag)
      end.keys

      [changed_there, changed_here]
    end

    # Private: Remove not needed data from lastfm query result.
    #
    # tracks - array of hashes, result of @lastfm.user.get_recent_tracks().
    #
    # Returns hash, where keys are timestamps and values are hashes with
    # fields 'artist' and 'track'.
    def convert_recent_tracks(tracks)
      tracks.reject { |track| track.has_key?('nowplaying') }.map do |track|
        {
          'timestamp' => track['date']['uts'].to_i,
          'artist' => track['artist']['content'],
          'track' => track['name']
        }
      end
    end

    # Private: Downloads from Last.FM API page with tracks listened by user.
    #
    # page - which page should it download.
    # timestamp - optional, since what time it should download data.
    #
    # Examples
    #
    #   get_tracks_page(15, 1313504528)
    #   get_tracks_page(1)
    #
    # Returns an array of hashes with tracks data.
    def get_tracks_page(page, timestamp = nil)
      puts "Downloading page #{page}"
      begin
        tracks = if timestamp
          ts = timestamp
          @lastfm.user.get_recent_tracks(@user, PAGE_SIZE, page, nil, ts)
        else
          @lastfm.user.get_recent_tracks(@user, PAGE_SIZE, page)
        end
      rescue Lastfm::APIError
        sleep 10
        retry
      end
      convert_recent_tracks(tracks)
    end

    # Private: Downloads all recent tracks of user.
    #
    # timestamp - optional, since what time it should download data
    #
    # Examples
    #
    #   get_tracks(1313504528)
    #   # => [{"artist": "Aphex Twin", "track": "5",
    #   # "timestamp": 1313504528}])
    #
    # Returns a list of hashes with track information.
    def get_tracks(timestamp = nil)
      tracks = []
      previous_page_tracks = []
      page = 0
      loop do
        page += 1
        current_page_tracks = get_tracks_page(page, timestamp)
        break if previous_page_tracks == current_page_tracks
        tracks.concat(current_page_tracks)
        previous_page_tracks = current_page_tracks
      end
      tracks
    end
  end
end
