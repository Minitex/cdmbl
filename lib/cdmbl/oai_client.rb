require 'http'

module CDMBL
  class OaiClient
    class << self
      def persistent(oai_url, &block)
        uri = URI(oai_url)
        client = HTTP.persistent(
          uri.class.build(
            host: uri.host,
            port: uri.port
          ).to_s
        )
        block.call(new(base_url: uri.path, client: client))
      ensure
        client.close
      end
    end

    attr_reader :base_url, :client

    def initialize(base_url: '', client: HTTP)
      @base_url = base_url
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
