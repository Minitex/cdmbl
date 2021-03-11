require 'test_helper'

module CDMBL
  describe CompoundLookup do
    let(:request_klass) { Minitest::Mock.new }
    let(:request_klass_object) { Minitest::Mock.new }
    let(:service_klass) { Minitest::Mock.new }
    let(:service_klass_object) { Minitest::Mock.new }
    let(:cdm_endpoint) { 'http://example.com' }
    let(:collection) { 'coll123' }
    let(:id) { 'sq32132112fvpoinvb' }

    describe 'when valid compound object data is received' do
      it 'correctly counts the result' do
        service_klass.expect :new,
                             service_klass_object,
                             [
                               {
                                 function: 'dmGetCompoundObjectInfo',
                                 params: [collection, id]
                               }
                             ]
        request_klass.expect :new,
                             request_klass_object,
                             [
                               {
                                 base_url: cdm_endpoint,
                                 service: service_klass_object
                               }
                             ]

        request_klass_object.expect :fetch, '{"page": [1,2,3]}', []

        count = CompoundLookup.new(cdm_endpoint: cdm_endpoint,
                                collection: collection,
                                id: id,
                                service_klass: service_klass,
                                request_klass: request_klass).count
        _(count).must_equal 3
        service_klass.verify
        request_klass.verify
      end
    end
  end
end
