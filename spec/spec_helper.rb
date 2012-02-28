require 'json'
require 'lastfmtools'

RSpec.configure do |config|
  def fixture_location
    File.join(File.dirname(__FILE__), 'fixtures')
  end
  
  def fixture(type)
    path = File.join(fixture_location, "#{type}.json")
    File.open(path, 'r') { |file| JSON.parse(file.read) }
  end
end
