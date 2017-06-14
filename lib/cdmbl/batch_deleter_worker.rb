require 'sidekiq'
module CDMBL
  class BatchDeleterWorker
    include Sidekiq::Worker
    attr_reader :start, :prefix, :oai_url, :solr_url
    def perform(start = 0, prefix = '', oai_url = '', solr_url = '')
      @start    = start
      @prefix   = prefix
      @oai_url  = oai_url
      @solr_url = solr_url
      delete!
    end

    private

    def delete!
      batch_deleter.delete!
      unless batch_deleter.last_batch?
        BatchDeleteWorker.perform_async(start: start + 1,
                                        prefix: prefix,
                                        oai_url: oai_url,
                                        solr_url: solr_url)
      end
    end

    def batch_deleter
      @deleter ||= BatchDeleter.new(start: start,
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