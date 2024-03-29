require 'sidekiq'
require 'active_support/core_ext/numeric'

module CDMBL
  class TransformWorker
    include Sidekiq::Worker
    attr_reader :identifiers,
                :solr_config,
                :cdm_endpoint,
                :oai_endpoint,
                :field_mappings,
                :extract_compounds

    attr_writer :cdm_api_klass,
                :oai_request_klass,
                :oai_set_lookup_klass,
                :cdm_notification_klass,
                :load_worker_klass,
                :transformer_klass,
                :cache_klass

    def perform(identifiers,
                solr_config,
                cdm_endpoint,
                oai_endpoint,
                field_mappings,
                extract_compounds)

      @identifiers       = identifiers
      @solr_config       = solr_config
      @cdm_endpoint      = cdm_endpoint
      @oai_endpoint      = oai_endpoint
      @field_mappings    = field_mappings
      @extract_compounds = extract_compounds
      transform_and_load!
    end

    def oai_set_lookup_klass
      @oai_set_lookup_klass ||= OAISetLookup
    end

    def oai_request_klass
      @oai_request_klass ||= OaiRequest
    end

    def cdm_api_klass
      @cdm_api_klass ||= CONTENTdmAPI::Item
    end

    def cdm_notification_klass
      @cdm_notification_klass ||= CDMBL::CdmNotification
    end

    def transformer_klass
      @transformer_klass ||= Transformer
    end

    def load_worker_klass
      @load_worker_klass ||= LoadWorker
    end

    def cache_klass
      @cache_klass ||= Rails
    end

    private

    def transform_and_load!
      load_worker_klass.perform_async(transformed_records, [], solr_config)
    end

    def transformed_records
      @transformation ||= transformer_klass.new(
        cdm_records: records,
        oai_sets: set_lookup,
        field_mappings: field_mappings,
        extract_compounds: extract_compounds
      ).records
    end

    def set_lookup
      oai_set_lookup_klass.new(oai_sets: sets).keyed
    end

    def records
      identifiers.map do |identifier|
        cdm_request(*identifier)
      end
    end

    # e.g. local_identifiers.map { |identifier| extractor.cdm_request(*identifier) }
    def cdm_request(collection, id)
      cdm_notification_klass.call!(collection, id, cdm_endpoint)
      cdm_api_klass.new(
        base_url: cdm_endpoint,
        collection: collection,
        id: id
      ).metadata
    end

    def sets
      @oai_request ||=
        cache_klass.cache.fetch("cdmbl_set_specs", expires_in: 10.minutes) do
          oai_request_klass.new(base_uri: oai_endpoint).sets
        end
    end
  end
end
