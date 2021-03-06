require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe LastfmTools do
  before do
    @parser = LastfmTools.new
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
      @parser.should_receive(:tagged_with).with('good', 'eminem')
      @parser.parse('is eminem good?')
      @parser.should_receive(:tagged_with).with('shit', 'eminem')
      @parser.parse('is eminem shit?')
    end

    it 'should parse show_rating_of query' do
      @parser.should_receive(:show_rating_of).with('eminem')
      @parser.parse('what is eminem?')
    end

    it 'should throw error on invalid queries' do
      (-> {@parser.parse('asd')}).should raise_error(SyntaxError)
    end
  end
end
