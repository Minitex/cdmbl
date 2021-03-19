require 'test_helper'
module CDMBL
  describe OaiClient do
    let(:http_client) { Minitest::Mock.new }
    let(:http_client_object) { Minitest::Mock.new }
    let(:oai_client) do
      OaiClient.new(base_url: 'http://example.come',
                    client: http_client)
    end

    it 'makes a request' do
      http_client.expect :get, http_client_object, ['http://example.come?getRecord=blah:foo/1']
      http_client_object.expect :to_s, '<xml><foo>blah</foo></xml>'
      _(oai_client.request('getRecord=blah:foo/1')).must_equal({"xml"=>{"foo"=>"blah"}})
      http_client.verify
    end
  end
end
