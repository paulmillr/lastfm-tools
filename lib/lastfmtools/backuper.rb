require 'json'
require 'lastfm'

class Lastfmtools
  class Backuper
    attr_accessor :user
  
    def self.read_tags_backup
      File.open(TAGS_PATH, 'r') {|file| JSON.parse(file.read)}
    end

    def self.write_tags_backup(tags)
      File.open(TAGS_PATH, 'w') do |file|
        file.write(JSON.pretty_generate(tags))
      end
    end

    def initialize(api_key, api_secret, token)
      @lastfm = Lastfm.new(api_key, api_secret)
      begin
        @lastfm.session = @lastfm.auth.get_session(token)['key']
      rescue Lastfm::ApiError
        puts 'Invalid token. Go to'
        puts "http://www.last.fm/api/auth/?api_key=#{api_key}&token=#{token}"
      end
    end

    def get_tag_artists(tag)
      puts "Getting artists for #{tag}"
      begin
        @lastfm.user.get_personal_tags(@user, tag, nil, 500).map do |artist|
          artist['name']
        end
      rescue Lastfm::ApiError
        sleep 15
        retry
      end
    end
  
    def get_tags(with_count=false)
      top = @lastfm.user.get_top_tags(@user, 500)

      if with_count
        array_to_hash top.map {|tag| [tag['name'].downcase, tag['count'].to_i]}
      else
        top.map {|tag| tag['name'].downcase}
      end
    end
  
    def get_tags_artists(tags)
      array_to_hash(tags.map {|tag| [tag, get_tag_artists(tag)]})
    end
  
    def get_changed_tags
      old_tags = Backuper::read_tags_backup
      new_tags = get_tags(true)

      changed_there = new_tags.select do |tag, count|
        !old_tags.include?(tag) || old_tags[tag].size != count
      end.map {|tag, count| tag}

      changed_here = old_tags.select do |tag, artists|
        !new_tags.include?(tag)
      end.map {|tag, artists| tag}

      [changed_there, changed_here]
    end
  
    def sync_tags
      tags = Backuper::read_tags_backup
      changed_there, changed_here = get_changed_tags

      get_tags_artists(changed_there).each do |tag, artists|
       tags[tag] = artists
      end

      changed_here.each do |tag|
        tags.delete(tag)
      end

      Backuper::write_tags_backup(tags)
    end

    def sync
      # sync_artists
      sync_tags
    end
  end
end
