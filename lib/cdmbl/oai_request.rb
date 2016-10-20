module CDMBL
    class OaiRequest
      attr_reader :base_uri, :resumption_token, :client, :from
      def initialize(base_uri: '',
                     resumption_token: false,
                     from: '1900-01-01',
                     client: Net::HTTP)
          @base_uri         = base_uri
          @resumption_token = resumption_token
          @client           = client
          @from             = from
      end

      def identifiers
        (resumption_token) ? request(batch_uri) : request(first_batch_uri)
      end

      def sets
        @sets ||= request(sets_uri)
      end

      private

      def first_batch_uri
        "#{base_uri}?verb=ListIdentifiers&metadataPrefix=oai_dc&from=#{from}"
      end

      def batch_uri
        "#{base_uri}?verb=ListIdentifiers&resumptionToken=#{resumption_token}"
      end

      def sets_uri
        "#{base_uri}?verb=ListSets"
      end

      def request(location)
        CDMBL::OaiNotification.call!(location)
        client.get_response(URI(location)).body
      end
    end
end