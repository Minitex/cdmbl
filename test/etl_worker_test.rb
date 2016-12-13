require 'test_helper'
require 'sidekiq/testing'
require 'webmock/minitest'
Sidekiq::Testing.fake!

module CDMBL
  describe ETLWorker do
    let(:oai_endpoint) { 'http://reflections.mndigital.org/oai/oai.php' }
    let(:cdm_endpoint) { 'https://server16022.contentdm.oclc.org/dmwebservices/index.php' }
    let(:etl_config)   { {oai_endpoint: oai_endpoint, cdm_endpoint: cdm_endpoint, minimum_date: '1900-01-01', field_mappings: false, resumption_token: 'swede:296:oclc-cdm-allsets:2011-01-01:9999-99-99:oai_dc'} }
    let(:solr_config)  { {url: 'http://localhost:8983'} }
    it 'works - a worker sanity check' do
      VCR.use_cassette("etl_worker_integration") do
        ETLWorker.perform_async(solr_config, etl_config, 3, false)
        ETLWorker.drain
      end      
    end
  end
end