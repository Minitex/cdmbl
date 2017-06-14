require 'test_helper'

module CDMBL
  describe OaiRequest do
    let(:client) { Minitest::Mock.new }
    let(:client_response) { Minitest::Mock.new }

    it 'requests and parses sets' do
      client.expect :get_response, client_response, [URI('http://example.com?verb=ListSets')]
      client_response.expect :body, '<sets><set>foo</set></sets>'
      request = OaiRequest.new(base_uri: 'http://example.com', client: client)
      assert_respond_to request, :sets
      request.sets.must_equal('sets' => { 'set' => 'foo' })
      client.verify
      client_response.verify
    end

    it 'allows selective harvesting by date and set' do
      client.expect :get_response,
                    client_response,
                    [URI('http://example.com?verb=ListIdentifiers&metadataPrefix=oai_dc&from=1900-01-01&set=swede')]
      client_response.expect :body,
                             '<oai-response><record>foo</record></oai-response>'
      request = OaiRequest.new from: '1900-01-01',
                               set: 'swede',
                               base_uri: 'http://example.com',
                               client: client
      request.identifiers.must_equal('oai_response' => { 'record' => 'foo' })
    end

    describe 'when no resumption token is present' do
      it 'requests the first batch' do
        client.expect :get_response,
                      client_response,
                      [URI('http://example.com?verb=ListIdentifiers&metadataPrefix=oai_dc')]
        client_response.expect :body, '<record>foo</record>'
        request = OaiRequest.new base_uri: 'http://example.com',
                                 client: client
        request.identifiers.must_equal('record' => 'foo')
      end
    end

    describe 'when a resumption token is present' do
      it 'requests a batch with a resumption token' do
        client.expect :get_response,
                      client_response,
                      [URI('http://example.com?verb=ListIdentifiers&resumptionToken=oai:123')]
        client_response.expect :body, '<record>foo</record>'
        request = OaiRequest.new base_uri: 'http://example.com',
                                 resumption_token: 'oai:123',
                                 client: client
        request.identifiers.must_equal('record' => 'foo')
      end
    end
  end
end