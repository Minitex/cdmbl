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

    let(:oai_url) { 'http://cdm16022.contentdm.oclc.org/oai/oai.php' }
    let(:solr_url) { 'http://localhost:8983' }
    let(:prefix) { 'oai:cdm16022.contentdm.oclc.org:' }

    it 'calls its collaborators' do
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

    it 'responds with deletable records' do
      result = BatchDeleter.new(
        solr_client: CDMBL::Solr.new(url: solr_url),
        oai_client: OaiClient.new(base_url: oai_url),
        prefix: prefix
      ).deletables
      _(result).must_equal(["bad:ID"])
    end

    describe 'when no more results from solr are present' do
      it 'signals the last batch' do
        result = BatchDeleter.new(
          solr_client: CDMBL::Solr.new(url: solr_url),
          oai_client: OaiClient.new(base_url: oai_url),
          prefix: prefix
        ).last_batch?
        _(result).must_equal(true)
      end
    end
    describe 'when more results from solr are present' do
      it 'does not signal the last batch' do
        result = BatchDeleter.new(
          batch_size: 1,
          solr_client: CDMBL::Solr.new(url: solr_url),
          oai_client: OaiClient.new(base_url: oai_url),
          prefix: prefix
        ).last_batch?
        _(result).must_equal(false)
      end
    end
  end
end
