require 'test_helper'

module CDMBL
  describe Loader do

    it 'provides a default solr client' do
      _(Loader.new).must_respond_to :solr_client
    end

    it 'keeps track of a set of records for loading' do
      _(Loader.new).must_respond_to :records
    end

    it 'persists records' do
      solr_client = Minitest::Mock.new
      solr_client.expect :add, true, [[{id: 'foo123'}]]
      Loader.new(records: [{id: 'foo123'}], solr_client: solr_client).load!
      solr_client.verify
    end
  end
end
