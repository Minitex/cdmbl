require 'json'
module CDMBL
  class OaiRequest
    attr_reader :base_uri,
                :resumption_token,
                :client,
                :set,
                :identifier,
                :from
    def initialize(base_uri: '',
                   resumption_token: nil,
                   set: nil,
                   identifier: '',
                   from: nil,
                   client: Net::HTTP)
      @base_uri         = base_uri
      @resumption_token = resumption_token
      @client           = client
      @set              = (set) ? "&set=#{set}" : ''
      @from             = from ? "&from=#{from}" : ''
      @identifier       = identifier
    end

    def identifiers
      @ids ||= (resumption_token) ? request(batch_uri) : request(first_batch_uri)
    end

    def sets
      @sets ||= request(sets_uri)
    end

    private

    def first_batch_uri
      "#{base_uri}?verb=ListIdentifiers&metadataPrefix=oai_dc#{set}#{from}"
    end

    def batch_uri
      "#{base_uri}?verb=ListIdentifiers&resumptionToken=#{resumption_token}"
    end

    def sets_uri
      "#{base_uri}?verb=ListSets"
    end

    def request(location)
      CDMBL::OaiNotification.call!(location)
      Hash.from_xml(client.get_response(URI(location)).body)
    end
  end
end
