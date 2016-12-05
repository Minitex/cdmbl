require 'sidekiq'
module CDMBL
  class ETLWorker
    attr_reader :solr_config,
                :etl_config,
                :is_recursive,
                :identifiers,
                :deletables,
                :sets

    include Sidekiq::Worker
    def perform(solr_config,
                etl_config,
                is_recursive = true,
                identifiers = [],
                deletables = [],
                sets = [])
  
      @etl_config   = etl_config.symbolize_keys
      @solr_config  = solr_config.symbolize_keys
      @is_recursive = is_recursive
      @identifiers  = identifiers
      @deletables   = deletables
      @sets         = sets
  
      if !identifiers.empty?
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
      extraction.local_identifiers.each_slice(10) do |ids|
        ETLWorker.perform_async(solr_config,
                                etl_config,
                                is_recursive,
                                ids,
                                extraction.deletable_ids,
                                extraction.set_lookup)
      end
    end

    def load!
      etl_run.load!(deletables, transformation.records)
    end

    def transformation
      etl_run.transform(sets, records)
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
      etl_config.merge(resumption_token: etl_run.next_resumption_token)
    end
  end
end