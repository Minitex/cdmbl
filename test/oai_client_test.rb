require 'test_helper'
module CDMBL
  describe OaiClient do
    let(:http_client) { Minitest::Mock.new }
    let(:http_client_object) { Minitest::Mock.new }
    let(:oai_client) do
      OaiClient.new(base_url: 'http://example.come',
                    http_client: http_client)
    end

    it 'makes a request' do
      http_client.expect :get_response, http_client_object, [URI('http://example.come?getRecord=blah:foo/1')]
      http_client_object.expect :body, '<xml><foo>blah</foo></xml>'
      oai_client.request('getRecord=blah:foo/1').must_equal({"xml"=>{"foo"=>"blah"}})
      http_client.verify
    end
  end
end