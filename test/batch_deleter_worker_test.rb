require 'test_helper'
require 'sidekiq/testing'
require 'webmock/minitest'
Sidekiq::Testing.fake!

module CDMBL
  describe BatchDeleterWorker do
    let(:ids) { [{ collection: 'p16022coll44', id: '1' }, { collection: 'p16022coll17', id: '669' }] }
    let(:oai_url) { 'http://cdm16022.contentdm.oclc.org/oai/oai.php' }
    let(:solr_url) { 'http://localhost:8983' }
    let(:prefix) { 'oai:cdm16022.contentdm.oclc.org:' }
    it 'works - a worker sanity check' do
      VCR.use_cassette("batch_delete_worker") do
        BatchDeleterWorker.perform_async(0, prefix, oai_url, solr_url)
        BatchDeleterWorker.drain
      end
    end
  end
end