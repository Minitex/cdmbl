module CDMBL
  class BatchDeleter
    attr_reader :prefix,
                :start,
                :batch_size,
                :oai_client,
                :solr_client,
                :oai_deletables_klass
    def initialize(prefix: '',
                   start: 0,
                   batch_size: 200,
                   oai_client: :missing_oai_client,
                   solr_client: :missing_solr_client,
                   oai_deletables_klass: OaiDeletables)
      @prefix               = prefix
      @start                = start
      @batch_size           = batch_size
      @oai_client           = oai_client
      @solr_client          = solr_client
      @oai_deletables_klass = oai_deletables_klass
    end

    def delete!
      solr_client.delete deletables
    end

    def last_batch?
      start + batch_size >= num_found
    end

    private

    def deletables
      oai_deletables_klass.new(identifiers: docs,
                               prefix: prefix,
                               oai_client: oai_client).deletables
    end

    def docs
      ids.fetch('response', {}).fetch('docs', {})
    end

    def num_found
      ids.fetch('response', {}).fetch('numFound', 0)
    end

    def ids
      @ids ||= solr_client.ids(start: start)
    end
  end
end
