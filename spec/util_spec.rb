require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Util' do
  describe '#array_to_hash' do
    it 'should convert array of 2-arrays to hash' do
      array_to_hash([[1, 2], [3, 'b']]).should == {1 => 2, 3 => 'b'}
      array_to_hash([[:a, :b], [:c, 5]]).should == {:a => :b, :c => 5}
    end
  end
end
