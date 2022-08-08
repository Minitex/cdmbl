require 'test_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

module CDMBL
  describe BatchDeleterWorker do
    let(:batch_deleter_klass) { Minitest::Mock.new }
    let(:batch_deleter_klass_object) { Minitest::Mock.new }
    let(:job_complete_notification) { Minitest::Mock.new }
    let(:solr_client) { Minitest::Mock.new }
    let(:ids) { [{ collection: 'p16022coll44', id: '1' }, { collection: 'p16022coll17', id: '669' }] }
    let(:oai_url) { 'http://cdm16022.contentdm.oclc.org/oai/oai.php' }
    let(:solr_url) { 'http://localhost:8983' }
    let(:prefix) { 'oai:cdm16022.contentdm.oclc.org:' }

    it 'works - a worker sanity check' do
      worker = BatchDeleterWorker.new
      deletables = worker.perform(0, 10, prefix, oai_url, solr_url).deletables
      _(deletables).must_equal(["bad:ID"])
      last_batch = worker.perform(0, 10, prefix, oai_url, solr_url).last_batch?
      _(last_batch).must_equal(true)
    end

    it 'Collaborates with BatchDeleter' do
      batch_deleter_klass.expect(
        :new,
        batch_deleter_klass_object,
        [],
        start: 0,
        batch_size: 42,
        prefix: 'oai:cdm16022.contentdm.oclc.org:',
        solr_client: solr_client,
        oai_url: oai_url
      )
      batch_deleter_klass_object.expect :delete!, nil, []
      batch_deleter_klass_object.expect :last_batch?, nil, []
      batch_deleter_klass_object.expect :next_start, 42
      worker = BatchDeleterWorker.new
      worker.batch_deleter_klass = batch_deleter_klass
      worker.solr_client = solr_client
      worker.perform(0, 42, prefix, oai_url, solr_url)
      batch_deleter_klass.verify
    end

    it 'provides BatchDeleter with the given solr_query if applicable' do
      batch_deleter_klass.expect(
        :new,
        batch_deleter_klass_object,
        [],
        start: 0,
        batch_size: 42,
        prefix: 'oai:cdm16022.contentdm.oclc.org:',
        solr_client: solr_client,
        solr_query: 'setspec_ssi:otter',
        oai_url: oai_url
      )
      batch_deleter_klass_object.expect :delete!, nil, []
      batch_deleter_klass_object.expect :last_batch?, nil, []
      batch_deleter_klass_object.expect :next_start, 42
      worker = BatchDeleterWorker.new
      worker.batch_deleter_klass = batch_deleter_klass
      worker.solr_client = solr_client
      worker.perform(0, 42, prefix, oai_url, solr_url, 'setspec_ssi:otter')
      batch_deleter_klass.verify
    end

    it 'calls the callback after the last batch' do
      batch_deleter_klass.expect(
        :new,
        batch_deleter_klass_object,
        [],
        start: 0,
        batch_size: 42,
        prefix: 'oai:cdm16022.contentdm.oclc.org:',
        solr_client: solr_client,
        oai_url: oai_url
      )
      batch_deleter_klass_object.expect :delete!, nil
      batch_deleter_klass_object.expect :last_batch?, true
      job_complete_notification.expect :call!, nil

      worker = BatchDeleterWorker.new
      worker.batch_deleter_klass = batch_deleter_klass
      worker.solr_client = solr_client
      worker.job_complete_notification = job_complete_notification

      worker.perform(0, 42, prefix, oai_url, solr_url)

      job_complete_notification.verify
    end
  end
end
