require 'sidekiq'
require 'active_support/core_ext/hash/keys'

module CDMBL
  # Load Records into a solr index
  class LoadWorker
    include Sidekiq::Worker

    sidekiq_options queue: 'critical'

    attr_reader :solr_config, :records, :deletables
    attr_writer :loader_klass, :solr_klass

    def perform(records = [], deletables = [], solr_config = {})
      @solr_config = solr_config.symbolize_keys
      @records     = records
      @deletables  = deletables
      load!
    end

    def loader_klass
      @loader_klass ||= Loader
    end

    def solr_klass
      @solr_klass ||= CDMBL::Solr
    end

    def load!
      loader_klass.new(
        records: records,
        deletable_ids: deletables,
        solr_client: solr_client
      ).load!
    end

    private

    def solr_client
      @solr_client ||= solr_klass.new(**solr_config)
    end
  end
end
