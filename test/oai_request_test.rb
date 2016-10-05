require 'test_helper'

module CDMBL
  describe OaiRequest do
    let(:client) { Minitest::Mock.new }
    let(:client_response) { Minitest::Mock.new }

    it 'requests sets' do
      client.expect :get_response, client_response, [URI('http://example.com?verb=ListSets')]
      client_response.expect :body, 'set data here'
      request = OaiRequest.new(base_uri: 'http://example.com', client: client)
      request.sets.must_equal 'set data here'
      client.verify
      client_response.verify
    end

    describe 'when no resumption token is present' do
      it 'requests the first batch' do
      client.expect :get_response, client_response, [URI('http://example.com?verb=ListIdentifiers&metadataPrefix=oai_dc&from=1900-01-01')]
      client_response.expect :body, 'foo'
        request = OaiRequest.new(base_uri: 'http://example.com', client: client)
        request.identifiers.must_equal 'foo'
      end
    end

    describe 'when a resumption token is present' do
      it 'requests a batch with a resumption token' do
      client.expect :get_response, client_response, [URI('http://example.com?verb=ListIdentifiers&resumptionToken=oai:123')]
      client_response.expect :body, 'foo'
        request = OaiRequest.new(base_uri: 'http://example.com', resumption_token: 'oai:123', client: client)
        request.identifiers.must_equal 'foo'
      end
    end
  end
end