require 'test_helper'

module CDMBL
  describe CompoundFilter do
    let(:compound_lookup) { Minitest::Mock.new }
    let(:compound_lookup_object) { Minitest::Mock.new }
    let(:record_ids) { [['col1', 'sdf3'], ['col1', 'sdf4']] }
    it 'returns the correct large and small compounds' do
      record_ids.each do |record_id|
        compound_lookup.expect :new,
                                compound_lookup_object,
                                [
                                  {
                                    cdm_endpoint: 'http://example.com',
                                    collection: record_id.first,
                                    id: record_id.last
                                  }
                                ]
      end
      compound_lookup_object.expect :count, 1, []
      compound_lookup_object.expect :count, 11, []
      compound_filter = CompoundFilter.new(record_ids: record_ids,
                                           cdm_endpoint: 'http://example.com',
                                           compound_lookup_klass: compound_lookup)
      compound_filter.filter(large: true).must_equal [["col1", "sdf4"]]
      compound_filter.filter(large: false).must_equal [["col1", "sdf3"]]
      compound_lookup.verify
      compound_lookup_object.verify
    end



  end
end