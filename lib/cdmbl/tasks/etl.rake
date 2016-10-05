require 'cdmbl'

namespace :cdmbl do
  desc 'Launch a background job to index metadata from CONTENTdm to Solr.'
  task :ingest, [:solr_url, :oai_endpoint, :cdm_endpoint, :minimum_date] do |t, args|
    solr_config = { url: args[solr_url] }
    etl_config  = { oai_endpoint: args[:oai_endpoint], cdm_endpoint: args[:cdm_endpoint], minimum_date: args[:minimum_date] }
    CDMBL::ETLWorker.perform_async(solr_config, etl_config)
  end
end

