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

  desc 'Launch an indexing worker for each collection with an optional regex
        pattern to match setSpec. Patterns can be inclusive or exclusive.'
  task :by_collections, [
    :solr_url,
    :oai_endpoint,
    :cdm_endpoint,
    :set_spec_pattern,
    :inclusive,
    :batch_size
  ] do |t, args|
    oai_endpoint = args.fetch(:oai_endpoint)
    # Optional args
    pattern = args.fetch(:set_spec_pattern, false)
    inclusive = args.fetch(:inclusive, 'true') == 'true'
    # Define your own callback if you want to use other set related fields
    # Use the RegexFilterCallback as an example of how to build your own filter
    set_specs =
      if pattern
        filter = CDMBL::RegexFilterCallback.new(field: 'setName',
                                                pattern: Regexp.new(pattern),
                                                inclusive: inclusive)
        CDMBL::FilteredSetSpecs.new(oai_base_url: oai_endpoint,
                                    callback: filter).set_specs
      else
        CDMBL::FilteredSetSpecs.new(oai_base_url: oai_endpoint).set_specs
      end

    puts "Indexing Sets: '#{set_specs.join(', ')}'"

    etl_config = {
      solr_config: { url: args.fetch(:solr_url) },
      oai_endpoint: args.fetch(:oai_endpoint),
      cdm_endpoint: args.fetch(:cdm_endpoint),
      batch_size: args.fetch(:batch_size, 5),
      max_compounds: args.fetch(:max_compounds, 10)
    }

    CDMBL::ETLBySetSpecs.new(set_specs: set_specs, etl_config: etl_config).run!
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
