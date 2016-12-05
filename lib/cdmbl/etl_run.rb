module CDMBL
  # TODO: extract params into a an ETL Profile and delegate
  class ETLRun
    attr_reader :oai_endpoint,
                :cdm_endpoint,
                :resumption_token,
                :field_mappings,
                :minimum_date,
                :oai_requester,
                :extractor,
                :transformer,
                :loader,
                :solr_client
    def initialize(oai_endpoint: '',
                   cdm_endpoint: '',
                   resumption_token: false,
                   field_mappings: false,
                   minimum_date: '1900-01-01',
                   oai_requester: OaiRequest,
                   extractor: Extractor,
                   transformer: Transformer,
                   loader: Loader,
                   solr_client: SolrClient.new)

      @oai_endpoint     = oai_endpoint
      @cdm_endpoint     = cdm_endpoint
      @resumption_token = resumption_token
      @field_mappings   = field_mappings
      @oai_requester    = oai_requester
      @minimum_date     = minimum_date
      @extractor        = extractor
      @transformer      = transformer
      @loader           = loader
      @solr_client      = solr_client
    end

    def extract
      @extraction ||= extractor.new(oai_request: oai_request,
                                    cdm_endpoint: cdm_endpoint)
    end

    def transform(sets, records)
      @transformation ||= transformer.new(cdm_records: records,
                                          oai_sets: sets,
                                          field_mappings: field_mappings)
    end

    def load!(deletables, records)
      loader.new(records: records,
                 deletable_ids: deletables,
                 solr_client: solr_client).load!
    end

    def oai_request
      @oai_request ||= oai_requester.new(base_uri: oai_endpoint,
                                         resumption_token: resumption_token,
                                         from: minimum_date)
    end
  end

end