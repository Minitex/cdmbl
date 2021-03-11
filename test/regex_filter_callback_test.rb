require 'test_helper'

module CDMBL
  describe RegexFilterCallback do

    describe 'when no field is specified' do
      describe 'When we are looking for a positive match' do
        it 'it finds a positive match' do
          set = {'setName' => 'ul_cat'}
          filter = RegexFilterCallback.new(pattern: /^ul_/)
          _(filter.valid?(set: set)).must_equal true
        end
        it 'skips non-matches' do
          set = {'setName' => 'mdl_dog'}
          filter = RegexFilterCallback.new(pattern: /^ul_/)
          _(filter.valid?(set: set)).must_equal false
        end
      end

      describe 'When we are looking for a negative match' do
        it 'it finds a positive match' do
          set = {'setName' => 'ul_cat'}
          filter = RegexFilterCallback.new(pattern: /^ul_/, inclusive: false)
          _(filter.valid?(set: set)).must_equal false
        end
        it 'skips non-matches' do
          set = {'setName' => 'mdl_dog'}
          filter = RegexFilterCallback.new(pattern: /^ul_/, inclusive: false)
          _(filter.valid?(set: set)).must_equal true
        end
      end
    end
    describe 'when a field is specified' do
      describe 'When we are looking for a positive match' do
        it 'it finds a positive match' do
          set = {'setSpec' => 'ul_cat'}
          filter = RegexFilterCallback.new(field: 'setSpec', pattern: /^ul_/)
          _(filter.valid?(set: set)).must_equal true
        end
        it 'skips non-matches' do
          set = {'setSpec' => 'mdl_dog'}
          filter = RegexFilterCallback.new(field: 'setSpec', pattern: /^ul_/)
          _(filter.valid?(set: set)).must_equal false
        end
      end

      describe 'When we are looking for a negative match' do
        it 'it finds a positive match' do
          set = {'setSpec' => 'ul_cat'}
          filter = RegexFilterCallback.new(field: 'setSpec', pattern: /^ul_/, inclusive: false)
          _(filter.valid?(set: set)).must_equal false
        end
        it 'skips non-matches' do
          set = {'setSpec' =>  'mdl_dog'}
          filter = RegexFilterCallback.new(field: 'setSpec', pattern: /^ul_/, inclusive: false)
          _(filter.valid?(set: set)).must_equal true
        end
      end
    end
  end
end
