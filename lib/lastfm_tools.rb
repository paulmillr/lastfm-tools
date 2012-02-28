require 'yaml'

module LastfmTools
  require 'lastfm_tools/analyzer'
  require 'lastfm_tools/backuper'
  require 'lastfm_tools/query_parser'

  def read_config
    path = File.join(Dir::home, '.lastfm_tools')
    YAML::load_file(path)
  rescue Errno::ENOENT
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
