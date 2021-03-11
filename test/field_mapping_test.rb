require 'test_helper'

module CDMBL
  describe FieldMapingTest do
    describe 'when it is given a hash with string keys' do
      it 'symbolizes these keys' do
        stringy_config = {'dest_path' => 'blah', 'origin_path' => 'gah', 'formatters' => [1,2]}
        _(FieldMapping.new(config: stringy_config).config).must_equal(
          {:dest_path=>"blah", :origin_path=>"gah", :formatters=>[1, 2]}
        )
      end
    end

    describe 'when it is givin an array of formatters in string format' do
      it 'constantizes these formatters' do
        stringy_formatters = { formatters: ['CDMBL::StripFormatter', 'CDMBL::IDFormatter'] }
        _(FieldMapping.new(config: stringy_formatters).formatters).must_equal(
          [CDMBL::StripFormatter, CDMBL::IDFormatter]
        )
      end
    end

    describe 'when given incomplete config data' do
      it 'throws an error for the origin_path field' do
        mapping = FieldMapping.new(config: {})
        _(-> { mapping.origin_path }).must_raise(KeyError)
      end

      it 'throws an error for the dest_path field' do
        mapping = FieldMapping.new(config: {})
        _(-> { mapping.dest_path }).must_raise(KeyError)
      end

      it 'sets a default formatter' do
        mapping = FieldMapping.new(config: {})
        _(mapping.formatters).must_equal([CDMBL::DefaultFormatter])
      end
    end
  end
end
