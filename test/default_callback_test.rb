require 'test_helper'

module CDMBL
  describe DefaultCallback do
    it 'calls the default callback' do
      # See test_helper.rb for the test implementation where it lives because
      # the test implementation is used in multiple places
      Callback.call!('').must_equal 'blerg this is a test callback'
    end
  end
end