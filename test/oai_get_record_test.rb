require 'test_helper'

module CDMBL
  describe OaiGetRecord do
    let(:oai_client) { Minitest::Mock.new }
    let(:oai_client_object) { Minitest::Mock.new }
    let(:missing_record_error) { 'The value of the identifier argument is unknown' }

    describe 'when no missing record error is present' do
      it 'indicates the record exists' do
        oai_client.expect :request,
                          {'OAI_PMH' => {'error' => ''}},
                          ['verb=GetRecord&identifier=blah:foo/1&metadataPrefix=oai_dc']
        OaiGetRecord.new(oai_client: oai_client,
                         identifier: 'blah:foo/1').record_exists?.must_equal true
        oai_client.verify
      end
    end

    describe 'when the record error is present' do
      it 'indicates the does not exist' do
        oai_client.expect :request,
                          {'OAI_PMH' => {'error' => missing_record_error}},
                          ['verb=GetRecord&identifier=blah:foo/1&metadataPrefix=oai_dc']
        OaiGetRecord.new(oai_client: oai_client,
                         identifier: 'blah:foo/1').record_exists?.must_equal false
        oai_client.verify
      end
    end
  end
end