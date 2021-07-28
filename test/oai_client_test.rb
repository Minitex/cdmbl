require 'test_helper'

module CDMBL
  describe OaiClient do
    let(:http_client) { Minitest::Mock.new }

    describe '#request' do
      it 'makes a request' do
        mock_response = Minitest::Mock.new
        http_client.expect :get, mock_response, ['http://example.com/oai/oai.php?getRecord=blah:foo/1']
        mock_response.expect :to_s, '<xml><foo>blah</foo></xml>'
        oai_client = OaiClient.new(
          base_url: 'http://example.com/oai/oai.php',
          client: http_client
        )
        _(oai_client.request('getRecord=blah:foo/1')).must_equal({"xml"=>{"foo"=>"blah"}})
        http_client.verify
      end
    end

    describe '.persistent' do
      it 'uses a persistent connection for the duration of the block' do
        mock_response_1 = Minitest::Mock.new
        mock_response_2 = Minitest::Mock.new

        http_client.expect(:get, mock_response_1, ['/oai/oai.php?getRecord=Bob:foo/1'])
        http_client.expect(:get, mock_response_2, ['/oai/oai.php?getRecord=Loblaw:foo/2'])
        http_client.expect(:close, nil)

        mock_response_1.expect(:to_s, '<xml><foo>Bob</foo></xml>')
        mock_response_2.expect(:to_s, '<xml><foo>Loblaw</foo></xml>')

        responses = []

        HTTP.stub(:persistent, -> (domain) {
          assert_equal(domain, 'http://example.com')
          http_client
        }) do
          OaiClient.persistent('http://example.com/oai/oai.php') do |client|
            responses << client.request('getRecord=Bob:foo/1')
            responses << client.request('getRecord=Loblaw:foo/2')
          end
        end

        assert_equal({ 'xml' => { 'foo' => 'Bob' } }, responses[0])
        assert_equal({ 'xml' => { 'foo' => 'Loblaw' } }, responses[1])

        http_client.verify
        mock_response_1.verify
        mock_response_2.verify
      end
    end
  end
end
