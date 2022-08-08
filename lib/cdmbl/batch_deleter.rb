module CDMBL
  class BatchDeleter
    attr_reader :prefix,
                :start,
                :batch_size,
                :oai_url,
                :solr_query,
                :solr_client,
                :oai_deletables_klass,
                :notification_callback
    def initialize(prefix: '',
                   start: 0,
                   batch_size: 10,
                   oai_url:,
                   solr_query: nil,
                   solr_client: :missing_solr_client,
                   oai_deletables_klass: OaiDeletables,
                   notification_callback: CDMBL::BatchDeletedCallback)
      @prefix               = prefix
      @start                = start
      @batch_size           = batch_size
      @oai_url              = oai_url
      @solr_query           = solr_query
      @solr_client          = solr_client
      @oai_deletables_klass = oai_deletables_klass
      @notification_callback = notification_callback
    end

    def delete!
      solr_client.delete deletables
      notification_callback.call!(self)
    end

    def last_batch?
      next_start >= num_found
    end

    def next_start
      start + batch_size
    end

    def deletables
      @deletables ||= oai_deletables_klass.new(
        identifiers: ids,
        oai_url: oai_url,
        prefix: prefix
      ).deletables
    end

    private

    def ids
      results
        .fetch('response', {})
        .fetch('docs', {})
        .map { |doc| doc['id'] }
    end

    def num_found
      results
        .fetch('response', {})
        .fetch('numFound', 0)
    end

    def results
      @results ||= begin
        args = {
          start: start,
          rows: batch_size,
          fq: solr_query
        }.compact
        solr_client.ids(**args)
      end
    end
  end
end
