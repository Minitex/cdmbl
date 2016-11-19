require 'sidekiq'
module CDMBL
  class ETLWorker
    attr_reader :solr_config, :etl_config
    include Sidekiq::Worker
    def perform(solr_config, etl_config, recursive = true)
      @etl_config  = etl_config.symbolize_keys
      @solr_config = solr_config.symbolize_keys
      puts "Ingesting resumptionToken batch: #{etl_config['resumption_token']}"
      etl_run.load!
      if etl_run.next_resumption_token && recursive
        ETLWorker.perform_async(solr_config, next_etl_config)
      else
        CDMBL::CompletedCallback.call!(solr_client)
      end
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