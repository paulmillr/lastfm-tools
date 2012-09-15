require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe LastfmTools::Backuper do
  before do
    @backuper = LastfmTools::Backuper.new(
      fixture_location, 'fake_key', 'secret'
    )
    @backuper.user = 'test'
  end

  describe '#get_changed_tags' do
    it 'should return tags that were changed since last check' do
      response = fixture(:new_tags)
      response.each { |key, value| response[key] = value.size }
      @backuper.should_receive(:get_tags).and_return(response)
      changed_here = ['breakcore', 'raggacore', 'trip-hop', 'good', 'meh']
      changed_there = ['punk']
      @backuper.instance_eval { get_changed_tags }.should == [
        changed_here, changed_there
      ]
    end
  end

  describe '#convert_recent_tracks' do
    it 'should strip not-needed fields' do
      data = fixture(:recent_tracks)
      tracks = @backuper.instance_eval { convert_recent_tracks(data) }
      tracks.size.should == 4
      tracks[0].should == {
        'artist' => 'Ayria',
        'track' => 'Insect Calm',
        'timestamp' => 1330381367
      }

      tracks[3].should == {
        'artist' => 'Ayria',
        'track' => 'My Poison',
        'timestamp' => 1330382978
      }
    end
  end

  describe '#sync_tags' do
    it 'should sync tags' do
      tags = fixture(:tags)
      tags['punk'].should == ['Zebrahead', 'GG Allin']
      tags['raggacore'].should == nil
      tags['meh'].size.should == 2

      get_tags_response = fixture(:new_tags)
      get_tags_response.each do |key, value|
        get_tags_response[key] = value.size
      end

      changed_tags = ['breakcore', 'raggacore', 'trip-hop', 'good', 'meh']
      get_tags_artists_response = fixture(:changed_tags)

      @backuper.should_receive(:get_tags).and_return(get_tags_response)
      @backuper.should_receive(:get_tags_artists).with(changed_tags).and_return(
        get_tags_artists_response
      )
      @backuper.should_receive(:write_backup).with(
        :tags, fixture(:new_tags)
      ).and_return(true)

      @backuper.sync_tags
    end
  end

  describe '#sync_tracks' do
    it 'should sync tracks' do
      def sync_tracks
        tracks = read_backup(:tracks)
        last_timestamp = (tracks.last || {})['timestamp']
        tracks.concat(get_tracks(last_timestamp).reverse.compact)
        write_backup(:tracks, tracks)
      end

      @backuper.should_receive(:get_tracks).with(1313503528).and_return(
        fixture(:new_tracks).reverse
      )
      @backuper.should_receive(:write_backup).with(
        :tracks, fixture(:tracks).concat(fixture(:new_tracks))
      )
      @backuper.sync_tracks
    end
  end
end
