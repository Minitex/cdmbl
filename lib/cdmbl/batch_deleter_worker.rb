require 'sidekiq'
module CDMBL
  class BatchDeleterWorker
    include Sidekiq::Worker
    attr_reader :start, :prefix, :oai_url, :solr_url
    attr_accessor :batch_deleter_klass, :oai_client, :solr_client
    sidekiq_options :backtrace => true
    def perform(start = 0, prefix = '', oai_url = '', solr_url = '')
      @start    = start
      @prefix   = prefix
      @oai_url  = oai_url
      @solr_url = solr_url
      delete!
      batch_deleter
    end

    private

    def batch_deleter_klass
      @batch_deleter_klass ||= BatchDeleter
    end

    def delete!
      batch_deleter.delete!
      unless batch_deleter.last_batch?
        BatchDeleterWorker.perform_async start + 1, prefix, oai_url, solr_url
      end
    end

    def batch_deleter
      @batch_deleter ||=
        batch_deleter_klass.new(start: start,
                                prefix: prefix,
                                solr_client: solr_client,
                                oai_client: oai_client)
    end

    def solr_client
      @solr_client ||= CDMBL::Solr.new(url: solr_url)
    end

    def oai_client
      @oai_client ||= OaiClient.new base_url: oai_url
    end
  end
end