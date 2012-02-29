require 'yaml'

class LastfmTools
  require 'lastfm_tools/analyzer'
  require 'lastfm_tools/backuper'
  require 'lastfm_tools/query_parser'

  BEST_RATING = 'best'
  RATINGS = ['shit', 'meh', 'good', 'awesome']

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
end
