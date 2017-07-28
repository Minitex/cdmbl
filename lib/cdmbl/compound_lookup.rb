module CDMBL
    # Fetching the full metadata for compound records is expensive. This class
    # lets us check on how many compounds a CDM record has so that we know
  class CompoundLookup
      attr_reader :cdm_endpoint,
                  :collection,
                  :id,
                  :request_klass,
                  :service_klass

    def initialize(cdm_endpoint: '',
                   collection: '',
                   id: '',
                   request_klass: CONTENTdmAPI::Request,
                   service_klass: CONTENTdmAPI::Service)
      @cdm_endpoint  = cdm_endpoint
      @collection    = collection
      @id            = id
      @request_klass = request_klass
      @service_klass = service_klass
    end

    def count
      page.respond_to?(:length) ? page.length : 0
    end

    private

    def page
      JSON.parse(request).fetch('page', [])
    end

    def service
      @service ||= service_klass.new(function: 'dmGetCompoundObjectInfo',
                                     params: [collection, id])
    end

    def request
      @request ||= request_klass.new(base_url: cdm_endpoint,
                                     service: service).fetch
    end
  end
end