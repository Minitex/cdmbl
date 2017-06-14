require 'test_helper'

module CDMBL
  describe BatchDeleter do
    let(:oai_client) { Minitest::Mock.new }
    let(:solr_client) { Minitest::Mock.new }
    let(:oai_deletables_klass) { Minitest::Mock.new }
    let(:oai_deletables_klass_object) { Minitest::Mock.new }
    let(:solr_docs) { ['collection1:23' , 'collection1:24'] }
    let(:prefix) { 'oai:blah:' }
    let(:solr_response) do
      {
        'response' =>
          {
            'docs' => [{ 'id' => 'collection1:23' }, { 'id' => 'collection1:24' }],
            'numFound' => 2,
          }
      }
    end

    it 'deletes deletable records' do
      solr_client.expect :ids, solr_response, [{start: 0}]
      oai_deletables_klass.expect :new,
                                  oai_deletables_klass_object,
                                  [
                                    {
                                      identifiers: solr_docs,
                                      prefix: prefix,
                                      oai_client: oai_client
                                    }
                                  ]
      solr_client.expect :delete,
                         nil,
                         [['collection1:23']]
      oai_deletables_klass_object.expect :deletables, ['collection1:23']
      BatchDeleter.new(prefix: prefix,
                       oai_client: oai_client,
                       solr_client: solr_client,
                       oai_deletables_klass: oai_deletables_klass).delete!
      solr_client.verify
      oai_deletables_klass.verify
      oai_deletables_klass_object.verify
    end
  end
end