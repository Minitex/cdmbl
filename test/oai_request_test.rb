require 'test_helper'

module CDMBL
  describe OaiRequest do
    let(:client) { Minitest::Mock.new }
    let(:client_response) { Minitest::Mock.new }
    let(:header_response) {
      '<OAI_PMH>
        <ListIdentifiers>
          <header>
            <identifier>blerg.com:foocollection1/123</identifier>
          </header>
        </ListIdentifiers>
      </OAI_PMH>'
    }

    let(:header_response_with_status) {
      '<OAI_PMH>
        <ListIdentifiers>
          <header>
            <identifier>blerg.com:foo/123</identifier>
          </header>
          <header status="deleted">
            <identifier>blerg.com:foo/1234</identifier>
          </header>
          <header>
            <identifier>blerg.com:foo/1235</identifier>
          </header>
        </ListIdentifiers>
      </OAI_PMH>'
    }

    let(:resumption_token_response) {
      '<OAI_PMH>
        <ListIdentifiers>
          <header>
            <identifier>blerg.com:foo/123</identifier>
          </header>
          <resumptionToken>foo:123</resumptionToken>
        </ListIdentifiers>
      </OAI_PMH>'
    }

    let(:list_sets_response) {
      '<OAI_PMH>
        <ListSets>
          <set>
              <setSpec>coll123</setSpec>
              <setName>blah</setName>
              <setDescription>
                <dc>
                  <description>blah</description>
                </dc>
              </setDescription>
          </set>
          <set>
              <setSpec>coll1234</setSpec>
              <setName>blah 1</setName>
              <setDescription>
                <dc>
                  <description>blah 1</description>
                </dc>
              </setDescription>
          </set>
        </ListSets>
      </OAI_PMH>'
    }

    let(:list_single_sets_response) {
      '<OAI_PMH>
        <ListSets>
          <set>
              <setSpec>coll123</setSpec>
              <setName>blah</setName>
              <setDescription>
                <dc>
                  <description>blah</description>
                </dc>
              </setDescription>
          </set>
        </ListSets>
      </OAI_PMH>'
    }

    describe 'when only one set is returned' do
      it 'returns an array of one set' do
        client.expect :get_response, client_response, [URI('http://example.com?verb=ListSets')]
        client_response.expect :body, list_single_sets_response
        request = OaiRequest.new(uri: 'http://example.com', client: client)
        assert_respond_to request, :sets
        request.sets.must_equal([{"setSpec"=>"coll123", "setName"=>"blah", "setDescription"=>{"dc"=>{"description"=>"blah"}}}])
        client.verify
        client_response.verify
      end
    end

    it 'requests and parses sets' do
      client.expect :get_response, client_response, [URI('http://example.com?verb=ListSets')]
      client_response.expect :body, list_sets_response
      request = OaiRequest.new(uri: 'http://example.com', client: client)
      assert_respond_to request, :sets
      request.sets.must_equal([{"setSpec"=>"coll123", "setName"=>"blah", "setDescription"=>{"dc"=>{"description"=>"blah"}}}, {"setSpec"=>"coll1234", "setName"=>"blah 1", "setDescription"=>{"dc"=>{"description"=>"blah 1"}}}])
      client.verify
      client_response.verify
    end

    it 'provides a keyed set lookup' do
      client.expect :get_response, client_response, [URI('http://example.com?verb=ListSets')]
      client_response.expect :body, list_sets_response
      request = OaiRequest.new(uri: 'http://example.com', client: client)
      assert_respond_to request, :sets
      request.set_lookup.must_equal({"coll123"=>{:name=>"blah", :description=>"blah"}, "coll1234"=>{:name=>"blah 1", :description=>"blah 1"}})
      client.verify
      client_response.verify
    end

    describe 'when a resumption token is present' do
      it 'retrieves the resumption token' do
        client.expect :get_response,
                      client_response,
                      [URI('http://example.com?verb=ListIdentifiers&metadataPrefix=oai_dc&set=swede')]
        client_response.expect :body, resumption_token_response
        request = OaiRequest.new set_spec: 'swede',
                                uri: 'http://example.com',
                                client: client
        request.next_resumption_token.must_equal("foo:123")
      end
    end

    describe 'when a resumption token is NOT present' do
      it 'retrieves NO resumption token' do
        client.expect :get_response,
                      client_response,
                      [URI('http://example.com?verb=ListIdentifiers&metadataPrefix=oai_dc&set=swede')]
        client_response.expect :body, header_response
        request = OaiRequest.new set_spec: 'swede',
                                uri: 'http://example.com',
                                client: client
        request.next_resumption_token.must_be_nil
      end
    end

    it 'allows selective harvesting by date and set' do
      client.expect :get_response,
                    client_response,
                    [URI('http://example.com?verb=ListIdentifiers&metadataPrefix=oai_dc&set=swede')]
      client_response.expect :body, header_response
      request = OaiRequest.new set_spec: 'swede',
                               uri: 'http://example.com',
                               client: client
      request.records.must_equal([{"identifier"=>"blerg.com:foocollection1/123", :id=>"foocollection1:123"}])
    end

    describe 'when no resumption token is present' do
      it 'requests the first batch' do
        client.expect :get_response,
                      client_response,
                      [URI('http://example.com?verb=ListIdentifiers&metadataPrefix=oai_dc')]
        client_response.expect :body, header_response
        request = OaiRequest.new uri: 'http://example.com',
                                 client: client
        request.records.must_equal([{"identifier"=>"blerg.com:foocollection1/123", :id=>"foocollection1:123"}])
        client.verify
      end
    end

    describe 'when a resumption token is present' do
      it 'requests a batch with a resumption token' do
        client.expect :get_response,
                      client_response,
                      [URI('http://example.com?verb=ListIdentifiers&resumptionToken=oai:123')]
        client_response.expect :body, header_response
        request = OaiRequest.new uri: 'http://example.com',
                                 resumption_token: 'oai:123',
                                 client: client
        request.records.must_equal([{"identifier"=>"blerg.com:foocollection1/123", :id=>"foocollection1:123"}])
        client.verify
      end
    end

    it 'knows the difference between updatable and deletable records' do
      client.expect :get_response,
                    client_response,
                    [URI('http://example.com?verb=ListIdentifiers&metadataPrefix=oai_dc')]
      client_response.expect :body, header_response_with_status
      request = OaiRequest.new uri: 'http://example.com',
                          client: client
      request.deletable_ids.must_equal(["foo:1234"])
      request.updatables.must_equal([{"identifier"=>"blerg.com:foo/123", :id=>"foo:123"}, {"identifier"=>"blerg.com:foo/1235", :id=>"foo:1235"}])
    end
  end
end