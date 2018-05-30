require 'contentdm_api'
require 'active_support/core_ext/hash/conversions'
require 'hash_at_path'
require 'forwardable'

module CDMBL
  # Retrieve OAI records and sort them into add/updatables and deletables
  class Extractor
    extend ::Forwardable
    def_delegators :@oai_request, :sets, :identifiers
    attr_reader :oai_request,
                :oai_request_klass,
                :oai_filter_klass,
                :oai_set_lookup_klass

    def initialize(oai_endpoint: '',
                   resumption_token: nil,
                   set_spec: nil,
                   oai_request_klass: OaiRequest,
                   oai_filter_klass: OAIFilter,
                   oai_set_lookup_klass: OAISetLookup)
      @oai_request_klass    = oai_request_klass
      @oai_filter_klass     = oai_filter_klass
      @oai_set_lookup_klass = oai_set_lookup_klass
      @oai_request          = oai_requester(oai_endpoint,
                                            resumption_token,
                                            set_spec)
    end

    def deletable_ids
      oai_ids.deletable_ids
    end

    def local_identifiers
      oai_ids.updatable_ids
    end

    def next_resumption_token
      oai_identifiers.at_path('OAI_PMH/ListIdentifiers/resumptionToken')
    end

    def oai_ids
      oai_filter_klass.new(headers: oai_headers)
    end

    def set_lookup
      oai_set_lookup_klass.new(oai_sets: sets).keyed
    end

    private

    def oai_requester(oai_endpoint, resumption_token, set_spec)
      @oai_requester ||=
        oai_request_klass.new(base_uri: oai_endpoint,
                              resumption_token: resumption_token,
                              set: set_spec)
    end

    # Get the local collection and id from an OAI namespaced identifier
    # e.g. oai:reflections.mndigital.org:p16022coll44/3
    def extract_identifiers(identifier)
      identifier.split(':').last.split('/')
    end

    def oai_headers
      [oai_identifiers.at_path('OAI_PMH/ListIdentifiers/header')]
        .flatten
        .compact
    end

    def oai_identifiers
      @oai_identifiers ||= identifiers
    end
  end
end
