require 'cdmbl'

namespace :cdmbl do
  desc 'Launch a background job to index metadata from CONTENTdm to Solr.'
  task :ingest, [:solr_url, :oai_endpoint, :cdm_endpoint, :minimum_date, :batch_size, :set_spec] do |t, args|
    solr_config = { url: args[solr_url] }
    etl_config  = {
                    oai_endpoint: args[:oai_endpoint],
                    cdm_endpoint: args[:cdm_endpoint],
                    minimum_date: args[:minimum_date],
                    set_spec: args[:set_spec]
                  }
    etl_config = (args[:resumption_token]) ? etl_cofig.merge(args[:resumption_token]) : etl_config
    batch_size = (args[:batch_size]) ? args[:batch_size] : 10
    CDMBL::ETLWorker.perform_async(solr_config, etl_config, batch_size, true)
  end
end

