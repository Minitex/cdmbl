require 'json'
module CDMBL
    # Request a single item from an OAI endpoint
    # identifier should be forward slash delimited: colllection/identifier
    class OaiGetRecord
      attr_reader :identifier, :oai_client
      def initialize(identifier: '', oai_client: OaiClient.new)
        @identifier = identifier
        @oai_client = oai_client
      end

      def record_exists?
        (/The value of the identifier argument is unknown/ =~ record_errors) == nil
      end

      def record
        @record ||= oai_client.request query
      end

      private

      def record_errors
        record.fetch('OAI_PMH', {}).fetch('error', '')
      end

      def query
        "verb=GetRecord&identifier=#{identifier}&metadataPrefix=oai_dc"
      end
    end
end