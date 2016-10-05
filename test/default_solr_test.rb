require 'test_helper'
module CDMBL
  describe SolrClient do
    let(:client) { Minitest::Mock.new }
    let(:connection) { Minitest::Mock.new }

    it 'establishes a connection' do
      client.expect :connect, connection, [{url: "http://solr:8983/solr/some-core-here"}]
      Solr.new(url: 'http://solr:8983/solr/some-core-here', client: client).connection
      client.verify
    end

    it 'persists data to solr' do
      client.expect :connect, connection, [{url: "http://solr:8983/solr/some-core-here"}]
      connection.expect :add, 'blah', [[{id: "3sfsdf"}]]
      connection.expect :commit, nil
      Solr.new(url: 'http://solr:8983/solr/some-core-here', client: client).add([{id: "3sfsdf"}])
      client.verify
    end
  end
end