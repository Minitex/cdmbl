require 'contentdm_api'
require 'active_support/core_ext/hash/conversions'
require 'hash_at_path'
require 'forwardable'

module CDMBL
  # This extractor uses the SimpleGet extractor initially and then makes
  # subsequent passes at the full ContentDM API with identifiers taken from
  # the contentdm api
  class Extractor
    extend ::Forwardable
    def_delegators :@oai_request, :sets, :identifiers
    attr_reader :oai_request,
                :cdm_item,
                :cdm_endpoint,
                :oai_set_lookup,
                :oai_filter

    def initialize(oai_request: OaiRequest.new,
                   cdm_endpoint: '',
                   oai_set_lookup: OAISetLookup,
                   cdm_item: CONTENTdmAPI::Item,
                   oai_filter: OAIFilter)
      @oai_request    = oai_request
      @cdm_item       = cdm_item
      @cdm_endpoint   = cdm_endpoint
      @oai_set_lookup = oai_set_lookup
      @oai_filter     = oai_filter
    end

    def set_lookup
      oai_set_lookup.new(oai_sets: to_hash(sets)).keyed
    end

    def ids
      (specific_ids) ? specific_ids : local_identifiers
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

    # e.g. local_identifiers.map { |identifier| extractor.cdm_request(*identifier) }
    def cdm_request(collection, id)
      CDMBL::CdmNotification.call!(collection, id, cdm_endpoint)
      cdm_item.new(base_url: cdm_endpoint, collection: collection, id: id).metadata
    end

    private

    def oai_ids
      oai_filter.new(headers: oai_headers)
    end

    # Get the local collection and id from an OAI namespaced identifier
    # e.g. oai:reflections.mndigital.org:p16022coll44/3
    def extract_identifiers(identifier)
      identifier.split(':').last.split('/')
    end

    def oai_headers
      oai_identifiers.at_path('OAI_PMH/ListIdentifiers/header')
    end

    def oai_identifiers
      to_hash(identifiers)
    end

    def to_hash(xml)
      Hash.from_xml(xml)
    end
  end
end