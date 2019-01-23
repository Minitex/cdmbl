require 'test_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

module CDMBL
  describe TransformWorker do
    let(:oai_request_klass) { Minitest::Mock.new }
    let(:oai_request_klass_object) { Minitest::Mock.new }
    let(:oai_set_lookup_klass) { Minitest::Mock.new }
    let(:oai_set_lookup_klass_object) { Minitest::Mock.new }
    let(:cdm_api_klass) { Minitest::Mock.new }
    let(:cdm_api_klass_object) { Minitest::Mock.new }
    let(:cdm_notification_klass) { Minitest::Mock.new }
    let(:transformer_klass) { Minitest::Mock.new }
    let(:transformer_klass_object) { Minitest::Mock.new }
    let(:load_worker_klass)  { Minitest::Mock.new }
    let(:identifiers) { [['coll1', 1], ['coll1', 2]] }
    let(:solr_config) { { foo: 'bar' } }
    let(:cdm_endpoint) { 'http://example.com1' }
    let(:oai_endpoint) { 'http://example.com2' }
    let(:field_mappings) { false }
    let(:sets) { [{'id' => 'coll1:blah'}] }
    let(:sets_keyed) { {'coll1' => 'bla'} }
    let(:transformed_records) { [{ blah: 'blerg' }] }


    let(:deletable_ids) { [9, 10, 2] }

    it 'extracts data from OAI' do
      oai_request_klass.expect :new,
                               oai_request_klass_object,
                               [{base_uri: oai_endpoint}]
      oai_request_klass_object.expect :sets, sets, []
      oai_set_lookup_klass.expect :new,
                                  oai_set_lookup_klass_object,
                                  [{ oai_sets: sets }]
      oai_set_lookup_klass_object.expect :keyed, sets_keyed, []
      cdm_api_klass.expect :new,
                           cdm_api_klass_object,
                           [
                             {
                               base_url: cdm_endpoint,
                               collection: 'coll1',
                               id: 1
                             }
                           ]
      cdm_api_klass.expect :new,
                           cdm_api_klass_object,
                           [
                             {
                               base_url: cdm_endpoint,
                               collection: 'coll1',
                               id: 2
                             }
                           ]
      cdm_api_klass_object.expect :metadata, { blah: 'blah' }, []
      cdm_api_klass_object.expect :metadata, { blah: 'blah1' }, []
      cdm_notification_klass.expect :call!, nil, ['coll1', 1, cdm_endpoint]
      cdm_notification_klass.expect :call!, nil, ['coll1', 2, cdm_endpoint]
      transformer_klass.expect :new,
                               transformer_klass_object,
                               [
                                 {
                                   cdm_records: [
                                     { blah: 'blah' },
                                     { blah: 'blah1' }
                                   ],
                                   oai_sets: sets_keyed,
                                   field_mappings: field_mappings,
                                   extract_compounds: false
                                 }
                               ]
      transformer_klass_object.expect :records, transformed_records, []
      load_worker_klass.expect :perform_async,
                               nil,
                               [
                                 transformed_records,
                                 [],
                                 solr_config
                               ]

      worker = TransformWorker.new
      worker.oai_request_klass = oai_request_klass
      worker.oai_set_lookup_klass = oai_set_lookup_klass
      worker.cdm_api_klass = cdm_api_klass
      worker.cdm_notification_klass = cdm_notification_klass
      worker.transformer_klass = transformer_klass
      worker.load_worker_klass = load_worker_klass

      # Run the extractor worker
      worker.perform(identifiers,
                     solr_config,
                     cdm_endpoint,
                     oai_endpoint,
                     field_mappings,
                     false)
      oai_request_klass.verify
      oai_set_lookup_klass.verify
      cdm_api_klass.verify
      cdm_notification_klass.verify
      transformer_klass.verify
      transformer_klass.verify
      load_worker_klass.verify
    end
  end
end