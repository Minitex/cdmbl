require 'test_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

module CDMBL
  describe ETLWorker do
    let(:etl_worker_klass) { Minitest::Mock.new }
    let(:oai_request_klass) { Minitest::Mock.new }
    let(:oai_request_klass_object) { Minitest::Mock.new }
    let(:load_worker_klass) { Minitest::Mock.new }
    let(:transform_worker_klass) { Minitest::Mock.new }
    let(:config) do
      {
        'cdm_endpoint' => 'http://example.com',
        'oai_endpoint' => 'http://example.com1',
        'max_compounds' => 10,
        'is_recursive' => true,
        'batch_size' => 2,
        'solr_config' => { blah: 'blah' }
      }
    end

    it 'correctly uses its collaborators' do
      etl_worker_klass.expect :perform_async, nil, [{"cdm_endpoint"=>"http://example.com", "oai_endpoint"=>"http://example.com1", "max_compounds"=>10, "is_recursive"=>true, "batch_size"=>2, "solr_config"=>{:blah=>"blah"}, :resumption_token=>"coll:21112niner123"}]
      oai_request_klass.expect :new,
                             oai_request_klass_object,
                             [
                               {
                                uri: 'http://example.com1',
                                resumption_token: nil,
                                set_spec: nil
                               }
                             ]
      oai_request_klass_object.expect :deletable_ids, ['col134:blarg'], []
      oai_request_klass_object.expect :updatables, [{foo: 'bar'}], []
      oai_request_klass_object.expect :next_resumption_token, 'coll:21112niner', []
      oai_request_klass_object.expect :next_resumption_token, 'coll:21112niner123', []


      load_worker_klass.expect :perform_async, nil, [[], ["col134:blarg"], {:blah=>'blah'}]
      # Since we have configured the extractor to process batches of two
      # the small record batches will be processed in two goes
      transform_worker_klass.expect :perform_async, '', [[{:foo=>"bar"}], {:blah=>"blah"}, "http://example.com", "http://example.com1", false]

      worker = ETLWorker.new
      worker.etl_worker_klass = etl_worker_klass
      worker.oai_request_klass = oai_request_klass
      worker.load_worker_klass = load_worker_klass
      worker.transform_worker_klass = transform_worker_klass

      # Run the extractor worker
      worker.perform(config)
      etl_worker_klass.verify
      oai_request_klass.verify
      load_worker_klass.verify
      transform_worker_klass.verify
    end

    it 'sanity check: extracts, transforms, loads' do
      config = {
        'cdm_endpoint' => 'https://server16022.contentdm.oclc.org/dmwebservices/index.php',
        'oai_endpoint' => 'http://cdm16022.contentdm.oclc.org/oai/oai.php',
        'max_compounds' => 10,
        'is_recursive' => false,
        'batch_size' => 2,
        'solr_config' => { blah: 'blah' }
      }
      worker = ETLWorker.perform_async(config)
      ETLWorker.drain
    end
  end
end