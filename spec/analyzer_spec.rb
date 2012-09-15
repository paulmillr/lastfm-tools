require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe LastfmTools::Analyzer do
  before do
    @analyzer = LastfmTools::Analyzer.new(tags: fixture('tags'))
  end

  describe '#intersect_tags' do
    it 'should intersect tags' do
      @analyzer.intersect_tags('good', 'breakcore').should == ['Igorrr']
      @analyzer.intersect_tags('punk', 'meh').should == ['GG Allin']
      @analyzer.intersect_tags('ebm', 'awesome').should be_empty
      @analyzer.intersect_tags('nope', 'yep').should be_empty
    end
  end

  describe '#tagged_with?' do
    it 'should show if some artist was tagged by tag' do
      @analyzer.tagged_with?('good', 'Igorrr').should == true
      @analyzer.tagged_with?('filthstep', 'iBenji').should == true
      @analyzer.tagged_with?('filth', 'iBenji').should == false
      @analyzer.tagged_with?('yep', 'nope').should == false
    end
  end

  describe '#best' do
    it 'should select best tag artists' do
      @analyzer.best_of_tag('breakcore').should == ['Igorrr']
      @analyzer.best_of_tag('glitch').should == ['Hrvatski', 'Aurastys']
      @analyzer.best_of_tag('grindcore').should == ['Bredor']
    end
  end
end
