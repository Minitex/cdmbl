require 'test_helper'

module CDMBL
  describe BatchDeleter do
    let(:solr_client) { Minitest::Mock.new }
    let(:oai_deletables_klass) { Minitest::Mock.new }
    let(:oai_deletables_klass_object) { Minitest::Mock.new }
    let(:notification_callback) { Minitest::Mock.new }
    let(:solr_docs) { ['collection1:23', 'collection1:24'] }
    let(:prefix) { 'oai:blah:' }
    let(:solr_response) do
      {
        'response' => {
          'docs' => [{ 'id' => 'collection1:23' }, { 'id' => 'collection1:24' }],
          'numFound' => 2,
        }
      }
    end

    let(:oai_url) { 'http://cdm16022.contentdm.oclc.org/oai/oai.php' }
    let(:solr_url) { 'http://localhost:8983' }
    let(:prefix) { 'oai:cdm16022.contentdm.oclc.org:' }

    it 'calls its collaborators' do
      solr_client.expect :ids, solr_response, [{start: 42, rows: 21}]
      oai_deletables_klass.expect(
        :new,
        oai_deletables_klass_object,
        [
          {
            identifiers: solr_docs,
            prefix: prefix,
            oai_url: oai_url
          }
        ]
      )
      solr_client.expect(:delete, nil, [['collection1:23']])
      oai_deletables_klass_object.expect :deletables, ['collection1:23']

      instance = BatchDeleter.new(
        prefix: prefix,
        start: 42,
        batch_size: 21,
        oai_url: oai_url,
        solr_client: solr_client,
        oai_deletables_klass: oai_deletables_klass,
        notification_callback: notification_callback
      )
      notification_callback.expect :call!, nil, [instance]
      instance.delete!
      solr_client.verify
      oai_deletables_klass.verify
      oai_deletables_klass_object.verify
      notification_callback.verify
    end

    it 'responds with deletable records' do
      result = BatchDeleter.new(
        solr_client: CDMBL::Solr.new(url: solr_url),
        oai_url: oai_url,
        prefix: prefix
      ).deletables
      _(result).must_equal(["bad:ID"])
    end

    describe 'when no more results from solr are present' do
      it 'signals the last batch' do
        result = BatchDeleter.new(
          solr_client: CDMBL::Solr.new(url: solr_url),
          oai_url: oai_url,
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
          oai_url: oai_url,
          prefix: prefix
        ).last_batch?
        _(result).must_equal(false)
      end
    end

    describe '#next_start' do
      it 'adds the batch_size to the current start' do
        deleter = BatchDeleter.new(
          start: 100,
          batch_size: 100,
          oai_url: oai_url
        )
        _(deleter.next_start).must_equal(200)
      end
    end
  end
end
