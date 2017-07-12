require 'test_helper'
require 'sidekiq/testing'
require 'webmock/minitest'
Sidekiq::Testing.fake!

module CDMBL
  describe BatchDeleterWorker do
    let(:batch_deleter_klass) { Minitest::Mock.new }
    let(:batch_deleter_klass_object) { Minitest::Mock.new }
    let(:oai_client) { Minitest::Mock.new }
    let(:solr_client) { Minitest::Mock.new }
    let(:ids) { [{ collection: 'p16022coll44', id: '1' }, { collection: 'p16022coll17', id: '669' }] }
    let(:oai_url) { 'http://cdm16022.contentdm.oclc.org/oai/oai.php' }
    let(:solr_url) { 'http://localhost:8983' }
    let(:prefix) { 'oai:cdm16022.contentdm.oclc.org:' }

    it 'works - a worker sanity check' do
      VCR.use_cassette("batch_delete_worker") do
        worker = BatchDeleterWorker.new
        worker.perform(0, prefix, oai_url, solr_url).deletables.must_equal ["bad:ID"]
        worker.perform(0, prefix, oai_url, solr_url).last_batch?.must_equal true
      end
    end

    it 'Collaborates with BatchDeleter' do
      VCR.use_cassette("batch_delete_worker") do
      batch_deleter_klass.expect :new,
                                 batch_deleter_klass_object,
                                 [
                                   {
                                    :start => 0,
                                    :prefix => 'oai:cdm16022.contentdm.oclc.org:',
                                    :solr_client => solr_client,
                                    :oai_client=> oai_client
                                    }
                                  ]
        batch_deleter_klass_object.expect :delete!, nil, []
        batch_deleter_klass_object.expect :last_batch?, nil, []
        worker = BatchDeleterWorker.new
        worker.batch_deleter_klass = batch_deleter_klass
        worker.oai_client = oai_client
        worker.solr_client = solr_client
        worker.perform(0, prefix, oai_url, solr_url)
        batch_deleter_klass.verify
      end
    end
  end
end