require 'test_helper'
module CDMBL
  describe SolrClient do
    let(:client) { Minitest::Mock.new }
    let(:connection) { Minitest::Mock.new }

    it 'establishes a connection' do
      client.expect(
        :connect,
        connection,
        [],
        url: "http://solr:8983/solr/some-core-here"
      )
      Solr.new(
        url: 'http://solr:8983/solr/some-core-here',
        client: client
      ).connection
      client.verify
    end

    it 'persists data to solr' do
      client.expect(
        :connect,
        connection,
        [],
        url: "http://solr:8983/solr/some-core-here"
      )
      connection.expect :add, 'blah', [[{id: "3sfsdf"}]]
      connection.expect :commit, nil
      Solr.new(
        url: 'http://solr:8983/solr/some-core-here',
        client: client
      ).add([{id: "3sfsdf"}])
      client.verify
    end

    describe '#ids' do
      it 'passes start and rows to the client' do
        mock_results = []
        client.expect(
          :connect,
          connection,
          [],
          url: "http://solr:8983/solr/some-core-here"
        )
        connection.expect(
          :get,
          mock_results,
          ['select'],
          params: {
            q: '*:*',
            defType: 'edismax',
            fl: '',
            rows: 2,
            start: 1
          }
        )
        results = Solr.new(
          url: 'http://solr:8983/solr/some-core-here',
          client: client
        ).ids(start: 1, rows: 2)
        _(results).must_equal(mock_results)
        client.verify
        connection.verify
      end

      it 'scopes the query when one is provided' do
        mock_results = []
        client.expect(
          :connect,
          connection,
          [],
          url: "http://solr:8983/solr/some-core-here"
        )
        connection.expect(
          :get,
          mock_results,
          ['select'],
          params: {
            q: '*:*',
            fq: 'setspec_ssi:otter',
            defType: 'edismax',
            fl: '',
            rows: 10,
            start: 0
          }
        )
        results = Solr.new(
          url: 'http://solr:8983/solr/some-core-here',
          client: client
        ).ids(fq: 'setspec_ssi:otter')
        _(results).must_equal(mock_results)
        client.verify
        connection.verify
      end
    end
  end
end
