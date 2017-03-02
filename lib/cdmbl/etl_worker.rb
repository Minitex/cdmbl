require 'sidekiq'
module CDMBL
  class ETLWorker
    include Sidekiq::Worker

    attr_reader :solr_config,
                :etl_config,
                :is_recursive,
                :identifier,
                :deletables


    def perform(solr_config,
                etl_config,
                is_recursive = true,
                identifier = false,
                deletables = [])

      @etl_config   = etl_config.symbolize_keys
      @solr_config  = solr_config.symbolize_keys
      @is_recursive = is_recursive
      @identifier   = identifier
      @deletables   = deletables

      if identifier
        load!
      else
        ingest_batches!
        if extraction.next_resumption_token && is_recursive
          ETLWorker.perform_async(solr_config, next_etl_config)
        else
          CDMBL::CompletedCallback.call!(solr_client)
        end
      end
    end

    private

    def ingest_batches!
      sent_deleted = false
      extraction.local_identifiers.each do |id|
        delete_ids = (sent_deleted == false) ? extraction.deletable_ids : []
        ETLWorker.perform_async(solr_config,
                                etl_config,
                                is_recursive,
                                id,
                                delete_ids)
        sent_deleted = true
      end
    end

    def load!
      CDMBL::LoaderNotification.call!(transformation.records, deletables)
      etl_run.load!(deletables, transformation.records)
    end

    def transformation
      @transformation ||= etl_run.transform(extraction.set_lookup, [record])
    end

    def record
      extraction.cdm_request(*identifier)
    end

    def extraction
      @extraction ||= etl_run.extract
    end

    def etl_run
      ETLRun.new(etl_config.merge(solr_client: solr_client))
    end

    def solr_client
      @solr_client ||= CDMBL::Solr.new(solr_config)
    end

    def next_etl_config
      etl_config.merge(resumption_token: extraction.next_resumption_token)
    end
  end
end