require 'rsolr'

module CDMBL
  # Commnicate with Solr: add / delete stuff
  class DefaultSolr
    attr_reader :url, :client
    def initialize(url: 'http://localhost:8983', client: RSolr)
      @url    = url
      @client = client
    end

    def connection
      @connection ||= client.connect url: url
    end

    def add(records)
      connection.add records
      connection.commit
    end

    def delete(ids)
      connection.delete_by_id ids
    end
  end
end