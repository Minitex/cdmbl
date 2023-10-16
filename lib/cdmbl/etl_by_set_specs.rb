module CDMBL
  class ETLBySetSpecs
    attr_reader :set_specs, :etl_config, :etl_worker_klass
    def initialize(set_specs: [:missing_setspec],
                   etl_config: :missing_etl_config,
                   etl_worker_klass: ETLWorker)
      @set_specs        = set_specs
      @etl_config       = etl_config
      @etl_worker_klass = etl_worker_klass
    end

    def run!
      set_specs.map do |set_spec|
        etl_worker_klass.perform_async(
          etl_config.merge(set_spec: set_spec).deep_stringify_keys
        )
      end
    end
  end
end
