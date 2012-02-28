require 'json'
require 'lastfmtools'

RSpec.configure do |config|
  fixture_cache = {}

  def fixture_location
    File.join(File.dirname(__FILE__), 'fixtures')
  end
  
  def fixture(type)
    path = File.join(fixture_location, "#{type}.json")
    File.open(path, 'r') do |file|
      #fixture_cache[path] ||= 
      JSON.parse(file.read)
    end
  end
end
