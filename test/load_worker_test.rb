require 'test_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

module CDMBL
  describe LoadWorker do
    let(:solr_config) { { 'solr' => 'config' } }
    let(:records) { [{ foo: 'bar' }, { foo: 'baz' }] }
    let(:deletables) { [{ meh: 'whatevs' }] }
    let(:solr_klass) { Minitest::Mock.new }
    let(:solr_client) { Minitest::Mock.new }
    let(:loader_klass) { Minitest::Mock.new }
    let(:loader_klass_object) { Minitest::Mock.new }

    it 'sends the records and deletable items to the loader class' do
      solr_klass.expect(
        :new, solr_client, [], solr: 'config'
      )
      loader_klass.expect(
        :new,
        loader_klass_object,
        [],
        records: records,
        deletable_ids: deletables,
        solr_client: solr_client
      )
      loader_klass_object.expect :load!, nil, []
      worker = LoadWorker.new
      worker.solr_klass = solr_klass
      worker.loader_klass = loader_klass
      worker.perform(records, deletables, solr_config)
      solr_klass.verify
      loader_klass.verify
    end
  end
end
