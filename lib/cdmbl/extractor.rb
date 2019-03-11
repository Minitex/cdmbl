require 'contentdm_api'
require 'active_support/core_ext/hash/conversions'
require 'forwardable'

module CDMBL
  # Retrieve OAI records and sort them into add/updatables and deletables
  class Extractor
    extend ::Forwardable
    def_delegators :@oai_request,
                   :sets,
                   :records,
                   :next_resumption_token,
                   :set_lookup
    attr_reader :oai_request
    def initialize(oai_endpoint: '',
                   resumption_token: nil,
                   set_spec: nil,
                   oai_request_klass: OaiRequest)
      @oai_request = oai_request_klass.new(base_uri: oai_endpoint,
                                           resumption_token: resumption_token,
                                           set: set_spec)
    end

  end
end
