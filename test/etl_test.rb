require 'test_helper'
module CDMBL
  describe ETLRun do
    let(:oai_requester) { Minitest::Mock.new }
    let(:oai_request_object) { Minitest::Mock.new }
    let(:extractor) { Minitest::Mock.new }
    let(:extractor_object) { Minitest::Mock.new }
    let(:loader) { Minitest::Mock.new }
    let(:loader_object) { Minitest::Mock.new }
    let(:persister_object) { Minitest::Mock.new }
    let(:transformer) { Minitest::Mock.new }
    let(:transformer_object) { Minitest::Mock.new }
    let(:solr_client) { Minitest::Mock.new }
    let(:cdm_response) do
      [{ title: 'Swedes in Tweeds' },
       { title: 'Swedes in Reeds' }]
    end
    let(:oai_sets) do
      [{ 'swede1' => { name: 'Swede', description: 'All about the Swedes' } }]
    end
    let(:loader_params) do
      { records: [{ blah: 'blah' }],
        deletable_ids: ['swede:1', 'swede:2'],
        solr_client: solr_client }
    end
    let(:etl_run) do
      ETLRun.new(oai_endpoint: 'http://blerg',
                 cdm_endpoint: 'http://blorg',
                 resumption_token: false,
                 oai_requester: oai_requester,
                 extractor: extractor,
                 transformer: transformer,
                 solr_client: solr_client,
                 loader: loader)
    end

    it 'requests and extracts records' do
      oai_requester.expect :new,
                           oai_request_object,
                           [{ base_uri: 'http://blerg',
                              resumption_token: false,
                              from: nil,
                              set: false }]
      extractor.expect :new,
                       extractor_object,
                       [{ oai_request: oai_request_object,
                          cdm_endpoint: 'http://blorg' }]
      etl_run.extract
      extractor.verify
      oai_requester.verify
    end

    it 'transforms records' do
      transformer.expect :new,
                         transformer_object,
                         [{ cdm_records: cdm_response,
                            oai_sets: oai_sets,
                            field_mappings: false }]
      etl_run.transform(oai_sets, cdm_response)
      transformer.verify
    end

    it 'loads records' do
      loader.expect :new,
                    loader_object,
                    [loader_params]
      loader_object.expect :load!, nil
      etl_run.load!(loader_params[:deletable_ids], loader_params[:records])
      loader.verify
    end
  end
end
