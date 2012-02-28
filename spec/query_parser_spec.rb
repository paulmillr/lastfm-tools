require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Lastfmtools::QueryParser do
  before do
    @parser = Lastfmtools::QueryParser.new
  end

  describe '#parse' do
    it 'should parse sync query' do
      @parser.should_receive(:sync)
      @parser.parse('sync')
    end

    it 'should parse show_artists query' do
      @parser.should_receive(:show_artists).with('good', 'witch house')
      @parser.parse('show good witch house artists')
      @parser.should_receive(:show_artists).with('best', 'test-test tes t-tet')
      @parser.parse('show best test-test tes t-tet artists')
    end

    it 'should parse show_top_site_artists query' do
      @parser.should_receive(:show_top_site_artists).with('witch house')
      @parser.parse('show witch house artists I hadn\'t listened to')
    end

    it 'should parse tagged_with query' do
      @parser.should_receive(:tagged_with).with('awesome', 'eminem')
      @parser.parse('is eminem awesome?')
      @parser.should_receive(:tagged_with).with('shit', 'eminem')
      @parser.parse('is eminem shit?')
    end

    it 'should parse show_rating_of query' do
      @parser.should_receive(:show_rating_of).with('eminem')
      @parser.parse('what is eminem?')
    end
  end
end
