require 'json'
module CDMBL
    class OaiClient
      attr_reader :base_url, :http_client
      def initialize(base_url: '', http_client: Net::HTTP)
        @base_url    = base_url
        @http_client = http_client
      end

      def request(query)
        hashify get("#{base_url}?#{query}")
      end

      private

      def get(url)
        http_client.get_response(URI(url)).body
      end

      def hashify(xml)
        Hash.from_xml(xml)
      end
    end
end