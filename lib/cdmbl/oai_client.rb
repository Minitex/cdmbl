
require 'json'
require 'http'
module CDMBL
    class OaiClient
      attr_reader :base_url, :client
      def initialize(base_url: '', client: HTTP)
        @base_url    = base_url
        @client = client
      end

      def request(query)
        hashify get("#{base_url}?#{query}")
      end

      private

      def get(url)
        client.get(url).to_s
      end

      def hashify(xml)
        Hash.from_xml(xml)
      end
    end
end