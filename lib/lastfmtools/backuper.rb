require 'json'
require 'lastfm'

module Lastfmtools
  class Backuper
    PAGE_SIZE = 150
    attr_accessor :user

    def initialize(backup_location, api_key, api_secret)
      @backup_location = backup_location
      @lastfm = Lastfm.new(api_key, api_secret)
      # begin
      #   @lastfm.session = @lastfm.auth.get_session(token)['key']
      # rescue Lastfm::ApiError
      #   puts 'Invalid token. Go to'
      #   puts "http://www.last.fm/api/auth/?api_key=#{api_key}&token=#{token}"
      # end
    end
    
    def get_backup_path(type)
      File.join(@backup_location, "#{type}.json")
    end

    # Example
    # 
    #   read_backup(:tags)
    #   read_backup(:tracks)
    # 
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

    def write_backup(type, data)
      File.open(get_backup_path(type), 'w') do |file|
        file.write(JSON.pretty_generate(data))
      end
      true
    end

    def get_tag_artists(tag)
      @lastfm.user.get_personal_tags(@user, tag, nil, 500).map do |artist|
        artist['name']
      end
    rescue Lastfm::ApiError
      sleep 15
      retry
    end
  
    def get_tags(with_count = false)
      top = @lastfm.user.get_top_tags(@user, 500)

      if with_count
        Hash[top.map {|tag| [tag['name'].downcase, tag['count'].to_i]}]
      else
        top.map {|tag| tag['name'].downcase}
      end
    end
  
    def get_tags_artists(tags)
      Hash[tags.map {|tag| [tag, get_tag_artists(tag)]}]
    end
  
    def get_changed_tags
      old_tags = read_backup(:tags)
      new_tags = get_tags(true)

      changed_there = new_tags.select do |tag, count|
        !old_tags.has_key?(tag) || old_tags[tag].size != count
      end.map {|tag, count| tag}

      changed_here = old_tags.select do |tag, artists|
        !new_tags.has_key?(tag)
      end.map {|tag, artists| tag}

      [changed_there, changed_here]
    end

    def sync_tags
      tags = read_backup(:tags)
      changed_there, changed_here = get_changed_tags

      get_tags_artists(changed_there).each do |tag, artists|
        tags[tag] = artists
      end
      
      tags.reject! do |tag, artists|
        changed_here.include?(tag)
      end

      write_backup(:tags, tags)
    end

    # Private: Remove not needed data from lastfm query result.
    # 
    # tracks - array of hashes, result of @lastfm.user.get_recent_tracks().
    # 
    # Returns hash, where keys are timestamps and values are hashes with
    # fields 'artist' and 'track'.
    def convert_recent_tracks(tracks)
      tracks.map do |track|
        next if track['nowplaying']
        {
          'timestamp' => track['date']['uts'].to_i,
          'artist' => track['artist']['content'],
          'track' => track['name']
        }
      end
    end
    
    def get_tracks_page(page, timestamp = nil)
      puts "Downloading page #{page}"
      begin
        tracks = if timestamp
          @lastfm.user.get_recent_tracks(@user, PAGE_SIZE, page, nil, timestamp)
        else
          @lastfm.user.get_recent_tracks(@user, PAGE_SIZE, page)
        end
      rescue Lastfm::APIError
        sleep 10
        retry
      end
      convert_recent_tracks(tracks)
    end

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

    def sync_tracks
      tracks = read_backup(:tracks)
      last_timestamp = (tracks.last || {})['timestamp']
      puts 'Last timestamp', last_timestamp
      tracks.concat(get_tracks(last_timestamp).reverse.compact)
      write_backup(:tracks, tracks)
    end

    def sync
      sync_tags
      sync_tracks
    end
  end
end
