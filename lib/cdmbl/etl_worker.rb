require 'sidekiq'
module CDMBL
  class ETLWorker
    include Sidekiq::Worker

    attr_reader :solr_config,
                :etl_config,
                :batch_size,
                :is_recursive,
                :identifiers,
                :deletables


    def perform(solr_config,
                etl_config,
                batch_size = 5,
                is_recursive = true,
                identifiers = [],
                deletables = [])

      @etl_config   = etl_config.symbolize_keys
      @solr_config  = solr_config.symbolize_keys
      @batch_size   = batch_size.to_i
      @is_recursive = is_recursive
      @identifiers  = identifiers
      @deletables   = deletables

      if !identifiers.empty?
        load!
      else
        ingest_batches!
        if extraction.next_resumption_token && is_recursive
          # Call the next batch of records
          ETLWorker.perform_async(solr_config, next_etl_config, batch_size)
        else
          CDMBL::CompletedCallback.call!(solr_client)
        end
      end
    end

    private

    # Break down extractions into batches of IDs for ingestion
    def ingest_batches!
      sent_deleted = false
      extraction.local_identifiers.each_slice(batch_size) do |ids|
        delete_ids = (sent_deleted == false) ? extraction.deletable_ids : []
        ETLWorker.perform_async(solr_config,
                                etl_config,
                                batch_size,
                                is_recursive,
                                ids,
                                delete_ids)
        sent_deleted = true
      end
    end

    def load!
      CDMBL::LoaderNotification.call!(transformation.records, deletables)
      etl_run.load!(deletables, transformation.records)
    end

    def transformation
      @transformation ||= etl_run.transform(extraction.set_lookup, records)
    end

    def records
      identifiers.map do |identifier|
        extraction.cdm_request(*identifier)
      end
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