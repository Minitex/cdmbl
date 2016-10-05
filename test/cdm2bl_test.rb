require 'test_helper'

class CDMBLTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::CDMBL::VERSION
  end
end
