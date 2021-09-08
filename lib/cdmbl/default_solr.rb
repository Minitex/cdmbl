require 'rsolr'

module CDMBL
  # Communicate with Solr: add / delete stuff
  class DefaultSolr
    attr_reader :url, :client
    def initialize(url: 'http://localhost:8983/solr/core-here', client: RSolr)
      @url    = url
      @client = client
    end

    def ids(start: 0, rows: 10, fq: nil)
      params = {
        q: '*:*',
        fq: fq,
        defType: 'edismax',
        fl: '',
        rows: rows,
        start: start
      }.compact
      connection.get('select', params: params)
    end

    def connection
      @connection ||= client.connect url: url
    end

    def add(records)
      connection.add records
    end

    def delete(ids)
      connection.delete_by_id ids
    end
  end
end
