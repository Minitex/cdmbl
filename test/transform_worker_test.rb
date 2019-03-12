require 'test_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

module CDMBL
  describe TransformWorkerTest do
    it 'processes an array of items' do
      #  CdmItem Mocks
      cdm_endpoint = 'example.com'
      pages = [{ 'pageptr' => 0, 'id' => 'foo:0' }, { 'pageptr' => 2, 'id' => 'foo:1' }]
      records = [
        { 'id' => 'foo:134', 'page' => [] },
        { 'id' => 'foo:135', 'page' => pages }
      ]
      cdm_item_klass = Minitest::Mock.new
      cdm_item_obj = Minitest::Mock.new
      records.map do |record|
        cdm_item_klass.expect :new, cdm_item_obj, [record: record, cdm_endpoint: 'example.com']
        cdm_item_obj.expect :page, record['page'], []
        cdm_item_obj.expect :metadata, record, []
      end

      # Transformer Mocks
      oai_endpoint = 'example.com'
      field_mappings = {}
      solr_config = {}
      transformed_records = [{ foo: 'bar'}]
      transformer_klass = Minitest::Mock.new
      transformer_obj = Minitest::Mock.new
      transformer_klass.expect :new, transformer_obj, [
        cdm_records: records,
        oai_endpoint: oai_endpoint,
        field_mappings: field_mappings
      ]
      transformer_obj.expect :records, transformed_records, []

      # Loader Mocks
      load_worker_klass = Minitest::Mock.new
      load_worker_klass.expect :perform_async, nil, [transformed_records, [], solr_config]

      # TransformerWorker mocks - for compound recursion
      transformer_worker_klass = Minitest::Mock.new
      batch_size = 1
      pages.map do |page|
        transformer_worker_klass.expect :perform_async, nil, [
          [page],
          solr_config,
          cdm_endpoint,
          oai_endpoint,
          field_mappings,
          batch_size
        ]
      end

      worker = TransformWorker.new
      worker.cdm_item_klass = cdm_item_klass
      worker.transformer_klass = transformer_klass
      worker.load_worker_klass = load_worker_klass
      worker.transformer_worker_klass = transformer_worker_klass

      worker.perform(
        records,
        solr_config,
        cdm_endpoint,
        oai_endpoint,
        field_mappings,
        batch_size
      )
      cdm_item_klass.verify
      transformer_klass.verify
      load_worker_klass.verify
      transformer_worker_klass.verify

      TransformWorker.drain
    end
  end
end