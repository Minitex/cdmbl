# require 'test_helper'


# require 'sidekiq/testing'
# Sidekiq::Testing.inline!

# def solr_config
#   { url: "#{base_url}:8983/solr/#{ENV['RAILS_ENV']}" }
# end

# def base_url
#   (ENV['RAILS_ENV'] == 'production') ? 'http://localhost' : 'http://solr'
# end

# def field_mappings
#   [
#     {dest_path: 'id', origin_path: 'id', formatters: [CDMBL::StripFormatter, CDMBL::IDFormatter]},
#     # Full Record View
#     {dest_path: 'title', origin_path: 'title', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'title_sort', origin_path: 'title', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'title_alternative', origin_path: 'title', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'description', origin_path: 'descri', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'date_created', origin_path: 'date', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'historical_era', origin_path: 'histor', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'creator', origin_path: 'creato', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'creator_sort', origin_path: 'creato', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'contributor', origin_path: 'contri', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'publisher', origin_path: 'publis', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'caption', origin_path: 'captio', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'notes', origin_path: 'additi', formatters: [CDMBL::StripFormatter]},
#     # Physical Description
#     {dest_path: 'type', origin_path: 'type', formatters: [CDMBL::Titlieze, CDMBL::StripFormatter]},
#     {dest_path: 'format', origin_path: 'format', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'dimensions', origin_path: 'dimens', formatters: [CDMBL::StripFormatter]},
#     # Topics
#     {dest_path: 'subject', origin_path: 'subjec', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'subject_fast', origin_path: 'fast', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'language', origin_path: 'langua', formatters: [CDMBL::StripFormatter]},
#     # Geographic Details
#     {dest_path: 'city', origin_path: 'city', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'state', origin_path: 'state', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'country', origin_path: 'countr', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'region', origin_path: 'region', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'continent', origin_path: 'contin', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'geonames', origin_path: 'geonam', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'projection', origin_path: 'projec', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'scale', origin_path: 'scale', formatters: [CDMBL::StripFormatter]},
#     # Collection Information
#     {dest_path: 'parent_collection', origin_path: 'a', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'contributing_organization', origin_path: 'contra', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'contact_information', origin_path: 'contac', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'fiscal_sponsor', origin_path: 'fiscal', formatters: [CDMBL::StripFormatter]},
#     # Identifiers
#     {dest_path: 'local_identifier', origin_path: 'identi', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'barcode', origin_path: 'barcod', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'system_identifier', origin_path: 'system', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'dls_identifier', origin_path: 'dls', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'persistent_url', origin_path: 'persis', formatters: [CDMBL::StripFormatter]},
#     # Rights
#     {dest_path: 'local_rights', origin_path: 'local', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'standardized_rights', origin_path: 'standa', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'rights_statement_uri', origin_path: 'righta', formatters: [CDMBL::StripFormatter]},
#     # Transcript
#     {dest_path: 'transcription', origin_path: 'transc', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'translation', origin_path: 'transl', formatters: [CDMBL::StripFormatter]},
#     # NON-DISPLAY FIELDS (not directly displayed)
#     {dest_path: 'kaltura_audio', origin_path: 'kaltur', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'kaltura_audio_playlist', origin_path: 'kaltua', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'kaltura_video', origin_path: 'kaltub', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'kaltura_video_playlist', origin_path: 'kaltuc', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'kaltura_combo_playlist', origin_path: 'kaltud', formatters: [CDMBL::StripFormatter]},
#     {dest_path: 'compound_objects', origin_path: 'page', formatters: [CDMBL::ToJsonFormatter]},
#     {dest_path: 'record_type', origin_path: 'record_type', formatters: []},
#     {dest_path: 'parent_id', origin_path: 'parent_id', formatters: []},
#   ]
# end

# module CDMBL
#   describe ETLBySetSpecs do

#     # it 'iterates through an array of set_specs and launches workers for each' do
#     #   worker = Minitest::Mock.new
#     #   worker.expect :perform_async, nil, [{:foo=>"bar", :set_spec=>"foo1243"}]
#     #   worker.expect :perform_async, nil, [{:foo=>"bar", :set_spec=>"blah"}]
#     #   etl_config = {foo: 'bar'}
#     #   ETLBySetSpecs.new(etl_config: etl_config,
#     #                    set_specs: ['foo1243', 'blah'],
#     #                    etl_worker_klass: worker).run!
#     #   worker.verify
#     # end

#     it 'iterates through an array of set_specs and launches workers for each' do
#       pattern    = '^ul_([a-zA-Z0-9])*\s-\s'
#       inclusive  = true
#       oai_endpoint = 'http://cdm16022.contentdm.oclc.org/oai/oai.php'
#       etl_config = {
#         oai_endpoint: oai_endpoint,
#         extract_compounds: true,
#         field_mappings:field_mappings,
#         cdm_endpoint: 'https://server16022.contentdm.oclc.org/dmwebservices/index.php',
#         max_compounds: 1,
#         batch_size: 5,
#         solr_config: solr_config
#       }
#       ETLBySetSpecs.new(etl_config: etl_config,
#                        set_specs: ['p16022coll94']).run!
#     end
#   end
# end