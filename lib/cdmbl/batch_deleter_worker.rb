require 'sidekiq'

module CDMBL
  class BatchDeleterWorker
    include Sidekiq::Worker
    attr_reader :start, :batch_size, :prefix, :oai_url, :solr_url, :solr_query
    attr_writer :batch_deleter_klass, :job_complete_notification, :solr_client

    def perform(start = 0, batch_size = 10, prefix = '', oai_url = '', solr_url = '', solr_query = nil)
      @start      = start
      @batch_size = batch_size
      @prefix     = prefix
      @oai_url    = oai_url
      @solr_url   = solr_url
      @solr_query = solr_query
      delete!
      batch_deleter
    end

    private

    def batch_deleter_klass
      @batch_deleter_klass ||= BatchDeleter
    end

    def job_complete_notification
      @job_complete_notification ||= CDMBL::BatchDeleteJobCompletedCallback
    end

    def delete!
      batch_deleter.delete!
      if batch_deleter.last_batch?
        job_complete_notification.call!
      else
        BatchDeleterWorker.perform_async(
          batch_deleter.next_start,
          batch_size,
          prefix,
          oai_url,
          solr_url,
          solr_query
        )
      end
    end

    def batch_deleter
      @batch_deleter ||= begin
        args = {
          start: start,
          batch_size: batch_size,
          prefix: prefix,
          solr_client: solr_client,
          solr_query: solr_query,
          oai_url: oai_url
        }.compact

        batch_deleter_klass.new(args)
      end
    end

    def solr_client
      @solr_client ||= CDMBL::Solr.new(url: solr_url)
    end
  end
end
