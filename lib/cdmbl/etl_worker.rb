require 'sidekiq'
module CDMBL
  # Extract records from OAI, delete records marked for deletion, sort the
  # remaning records them into "big and small" record piles based upon how many
  # compounds a record has, chunk the small records into batches and the big
  # records individuall and then send these records to a transformation worker
  class ETLWorker
    include Sidekiq::Worker
    attr_reader :config,
                :solr_config,
                :cdm_endpoint,
                :oai_endpoint,
                :field_mappings,
                :extract_compounds,
                :resumption_token,
                :set_spec,
                :max_compounds,
                :batch_size,
                :is_recursive,
                :from

    attr_writer :compound_filter_klass,
                :extractor_klass,
                :etl_worker_klass,
                :load_worker_klass,
                :completed_callback_klass,
                :transform_worker_klass

    def perform(config)
      # Sidekiq stores params in JSON, so we can't inject dependencies. This
      # results in the long set of arguments that follows. Otherwise, we'd
      # simply inject the OAI request and extractor objects
      @config            = config
      @solr_config       = config.fetch('solr_config').symbolize_keys
      @cdm_endpoint      = config.fetch('cdm_endpoint')
      @oai_endpoint      = config.fetch('oai_endpoint')
      @field_mappings    = config.fetch('field_mappings', false)
      @extract_compounds = config.fetch('extract_compounds', false)
      @resumption_token  = config.fetch('resumption_token', nil)
      @set_spec          = config.fetch('set_spec', nil)
      @max_compounds     = config.fetch('max_compounds', 10)
      @batch_size        = config.fetch('batch_size', 5).to_i
      @is_recursive      = config.fetch('is_recursive', true)
      @from              = config.fetch('from', nil)
      extract_batch!
      next_batch!
    end

    # Because Sidekiq serializes params to JSON, we provide custom setters
    # for dependencies (normally these would be default params in the
    # constructor) so that they may be mocked and tested
    def completed_callback_klass
      @completed_callback_klass ||= CDMBL::CompletedCallback
    end

    def etl_worker_klass
      @etl_worker_klass ||= ETLWorker
    end

    def compound_filter_klass
      @compound_filter_klass ||= CompoundFilter
    end

    def extractor_klass
      @extractor_klass ||= Extractor
    end

    def load_worker_klass
      @load_worker_klass ||= LoadWorker
    end

    def transform_worker_klass
      @transform_worker_klass ||= TransformWorker
    end

    # Recurse through OAI batches one at a time
    def next_batch!
      if next_resumption_token && is_recursive
        etl_worker_klass.perform_async(next_config)
      else
        completed_callback_klass.call!(solr_config)
      end
    end

    private

    # Extract an oai response - a batch of records
    def extract_batch!
      # Delete records that OAI has marked for deletion
      delete_deletables!
      # Records with few compounds are processed in batches
      transform_small_records!
      # Large records are all transformed and loaded one by one to avoid
      # timeouts
      transform_large_records!
    end

    def next_config
      config.merge(resumption_token: next_resumption_token)
    end

    def next_resumption_token
      @next_resumption_token ||= extraction.next_resumption_token
    end

    def transform_small_records!
      compound_filter.filter(large: false).each_slice(batch_size) do |ids|
        transform!(ids)
      end
    end

    def transform_large_records!
      compound_filter.filter(large: true).each do |id|
        transform!([id])
      end
    end

    def transform!(ids)
      transform_worker_klass.perform_async(
        ids,
        solr_config,
        cdm_endpoint,
        oai_endpoint,
        field_mappings,
        extract_compounds
      )
    end

    def delete_deletables!
      load_worker_klass.perform_async([], extraction.deletable_ids, solr_config)
    end

    def compound_filter
      @compound_filter ||= compound_filter_klass.new(
        record_ids: extraction.local_identifiers,
        cdm_endpoint: cdm_endpoint,
        max_compounds: max_compounds
      )
    end

    def extraction
      @extraction ||= extractor_klass.new(
        oai_endpoint: oai_endpoint,
        resumption_token: resumption_token,
        set_spec: set_spec,
        from: from
      )
    end
  end
end
