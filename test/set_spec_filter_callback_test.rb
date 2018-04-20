require 'test_helper'

module CDMBL
  describe SetSpecFilterCallback do

    describe 'When we are looking for a positive match' do
      it 'it finds a positive match' do
        set = {'setSpec' =>  'ul_cat'}
        filter = SetSpecFilterCallback.new(pattern: /^ul_/)
        filter.valid?(set: set).must_equal true
      end
      it 'skips non-matches' do
        set = {'setSpec' =>  'mdl_dog'}
        filter = SetSpecFilterCallback.new(pattern: /^ul_/)
        filter.valid?(set: set).must_equal false
      end
    end

    describe 'When we are looking for a negative match' do
      it 'it finds a positive match' do
        set = {'setSpec' =>  'ul_cat'}
        filter = SetSpecFilterCallback.new(pattern: /^ul_/, inclusive: false)
        filter.valid?(set: set).must_equal false
      end
      it 'skips non-matches' do
        set = {'setSpec' =>  'mdl_dog'}
        filter = SetSpecFilterCallback.new(pattern: /^ul_/, inclusive: false)
        filter.valid?(set: set).must_equal true
      end
    end
  end
end