require 'cdmbl'

namespace :cdmbl do
  desc 'Launch a background job to index metadata from CONTENTdm to Solr.'
  task :batch, [
    :solr_url,
    :oai_endpoint,
    :cdm_endpoint,
    :set_spec,
    :batch_size,
    :max_compounds
  ] do |t, args|
    CDMBL::ETLWorker.perform_async(
      solr_config: { url: args.fetch(:solr_url) },
      oai_endpoint: args.fetch(:oai_endpoint),
      cdm_endpoint: args.fetch(:cdm_endpoint),
      set_spec: args[:set_spec] != '""' ? args[:set_spec] : nil,
      batch_size: args.fetch(:batch_size, 10),
      max_compounds: args.fetch(:max_compounds, 10)
    )
  end

  desc 'Launch a background job to index a single record.'
  task :record, [
    :collection,
    :id,
    :solr_url,
    :cdm_endpoint,
    :oai_endpoint
  ] do |t, args|
    CDMBL::TransformWorker.perform_async(
      [[args.fetch(:collection), args.fetch(:id)]],
      { url: args.fetch(:solr_url) },
      args.fetch(:cdm_endpoint),
      args.fetch(:oai_endpoint)
    )
  end
end
