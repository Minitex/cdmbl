require 'sidekiq'
module CDMBL
  class TransformWorker
    include Sidekiq::Worker
    attr_reader :records,
                :solr_config,
                :cdm_endpoint,
                :oai_endpoint,
                :field_mappings,
                :batch_size

    attr_writer :cdm_item_klass,
                :load_worker_klass,
                :transformer_klass,
                :transformer_worker_klass

    def perform(records,
                solr_config,
                cdm_endpoint,
                oai_endpoint,
                field_mappings,
                batch_size)

      @records           = records
      @solr_config       = solr_config
      @cdm_endpoint      = cdm_endpoint
      @oai_endpoint      = oai_endpoint
      @field_mappings    = field_mappings
      @batch_size        = batch_size
      transform_and_load!
      transform_and_load_compounds!
    end

    def cdm_item_klass
      @cdm_item_klass ||= CdmItem
    end

    def transformer_klass
      @transformer_klass ||= Transformer
    end

    def load_worker_klass
      @load_worker_klass ||= LoadWorker
    end

    def transformer_worker_klass
      @transformer_worker_klass ||= TransformerWorker
    end

    private

    # Recursivly call the transformer_worker with all the the compound
    # data we have collected in the first pass
    def transform_and_load_compounds!
      compound_records.each_slice(batch_size) do |compound_records_batch|
        transformer_worker_klass.perform_async(
          compound_records_batch,
          solr_config,
          cdm_endpoint,
          oai_endpoint,
          field_mappings,
          batch_size
        )
      end
    end

    def transform_and_load!
      load_worker_klass.perform_async(transformed_records, [], solr_config)
    end

    def compound_records
      cmd_items.map(&:page).flatten
    end

    def cmd_items
      @cdm_items ||= records.map do |record|
        cdm_item_klass.new(record: record, cdm_endpoint: cdm_endpoint)
      end
    end

    def transformed_records
      @transformation ||=
        transformer_klass.new(cdm_records: cmd_items.map(&:metadata),
                              oai_endpoint: oai_endpoint,
                              field_mappings: field_mappings).records
    end

    def complete_records
      records.map do |record|
        cdm_request(*identifier)
      end
    end
  end
end
