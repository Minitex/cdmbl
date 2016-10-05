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

    def load!(resumption_token: false)
      persister.load!
    end

    def next_resumption_token
      extraction.next_resumption_token
    end

    def persister
      loader.new(records: transformation.records,
                 deletable_ids: extraction.deletable_ids,
                 solr_client: solr_client)
    end

    def transformation
      @transformation ||= transformer.new(cdm_records: extraction.records,
                                          oai_sets: extraction.set_lookup,
                                          field_mappings: field_mappings)
    end

    def extraction
      @extraction ||= extractor.new(oai_request: oai_request,
                                    cdm_endpoint: cdm_endpoint)
    end

    def oai_request
      @oai_request ||= oai_requester.new(base_uri: oai_endpoint,
                                         resumption_token: resumption_token,
                                         from: minimum_date)
    end
  end

end