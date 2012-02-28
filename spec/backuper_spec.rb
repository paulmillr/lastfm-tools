require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Lastfmtools::Backuper do
  before do
    @backuper = Lastfmtools::Backuper.new(fixture_location, 'fake_key', 'secret')
  end

  describe '#sync_tags' do
    it 'should sync tags' do
      tags = @backuper.sync_tags
      tags['punk'].should == ['Zebrahead']
      tags['raggacore'].should == nil
      tags['meh'].size.should == 2
  
      tags = @backuper.sync_tags
      tags['punk'].should == nil
      tags['raggacore'].should not_be_empty
      tags['meh'].size.should == 3
    end
  end
  
  describe '#sync_artists' do
    it 'should sync artists' do
      artists.length.should == 5
      artists[0]['timestamp'].should == 1313503128
      artists[5]['timestamp'].should == 1313503528
      artists = @backuper.sync_artists
      artists.length.should == 10
      artists[5]['timestamp'].should == 1313503528
      artists[10]['timestamp'].should == 1313504528
    end
  end
end
