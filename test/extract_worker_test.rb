# require 'test_helper'
# require 'sidekiq/testing'
# require 'webmock/minitest'
# Sidekiq::Testing.fake!

# module CDMBL
#   describe ExtractWorker do
#     let(:completed_callback_klass) { Minitest::Mock.new }
#     let(:extraction_worker_klass) { Minitest::Mock.new }
#     let(:compound_filter_klass) { Minitest::Mock.new }
#     let(:compound_filter_klass_object) { Minitest::Mock.new }
#     let(:extractor_klass) { Minitest::Mock.new }
#     let(:extractor_klass_object) { Minitest::Mock.new }
#     let(:load_worker_klass) { Minitest::Mock.new }
#     let(:transform_worker_klass) { Minitest::Mock.new }
#     let(:local_identifiers) { [1, 3, 4, 5, 6, 9] }
#     let(:large_records) { [4, 9] }
#     let(:small_records) { [1, 3, 5] }
#     let(:config) do
#       {
#         'cdm_endpoint' => 'http://example.com',
#         'oai_endpoint' => 'http://example.com1',
#         'max_compounds' => 10,
#         'is_recursive' => true,
#         'batch_size' => 2,
#         'solr_config' => { blah: 'blah' }
#       }
#     end
#     let(:deletable_ids) { [9, 10, 2] }

#     it 'correctly uses its collaborators' do
#       extraction_worker_klass.expect :perform_async,
#                                      nil,
#                                      [
#                                         {
#                                           'cdm_endpoint' => 'http://example.com',
#                                           'oai_endpoint' => 'http://example.com1',
#                                           'max_compounds' => 10,
#                                           'is_recursive' => true,
#                                           'batch_size' => 2,
#                                           'solr_config' => {
#                                             blah: 'blah'
#                                           },
#                                           resumption_token: 'col134/blarg'
#                                         }
#                                      ]
#       compound_filter_klass.expect :new,
#                                    compound_filter_klass_object,
#                                    [
#                                      {
#                                        record_ids: local_identifiers,
#                                        cdm_endpoint: config['cdm_endpoint'],
#                                        max_compounds: config['max_compounds']
#                                      }
#                                    ]
#       compound_filter_klass_object.expect :filter,
#                                           small_records,
#                                           [{ large: false }]
#       compound_filter_klass_object.expect :filter,
#                                           large_records,
#                                           [{ large: true }]
#       extractor_klass.expect :new,
#                              extractor_klass_object,
#                              [
#                                {
#                                  oai_endpoint: 'http://example.com1',
#                                  resumption_token: nil,
#                                  set_spec: nil
#                                }
#                              ]
#       extractor_klass_object.expect :next_resumption_token, 'col134/blarg', []
#       extractor_klass_object.expect :deletable_ids, deletable_ids, []
#       extractor_klass_object.expect :local_identifiers, local_identifiers, []
#       load_worker_klass.expect :perform_async,
#                                nil,
#                                [[], [9, 10, 2], {:blah=>'blah'}]
#       # Since we have configured the extractor to process batches of two
#       # the small record batches will be processed in two goes
#       transform_worker_klass.expect :perform_async,
#                                     nil,
#                                     [
#                                       [1, 3],
#                                       config['solr_config'],
#                                       'http://example.com',
#                                       'http://example.com1',
#                                       []
#                                     ]
#       transform_worker_klass.expect :perform_async,
#                                     nil,
#                                     [
#                                       [5],
#                                       config['solr_config'],
#                                       'http://example.com',
#                                       'http://example.com1',
#                                       []
#                                     ]
#       transform_worker_klass.expect :perform_async,
#                                     nil,
#                                     [
#                                       [4],
#                                       config['solr_config'],
#                                       'http://example.com',
#                                       'http://example.com1',
#                                       []
#                                     ]
#       transform_worker_klass.expect :perform_async,
#                                     nil,
#                                     [
#                                       [9],
#                                       config['solr_config'],
#                                       'http://example.com', 'http://example.com1',
#                                       []
#                                     ]
#       worker = ExtractWorker.new
#       worker.extraction_worker_klass = extraction_worker_klass
#       worker.compound_filter_klass = compound_filter_klass
#       worker.extractor_klass = extractor_klass
#       worker.load_worker_klass = load_worker_klass
#       worker.transform_worker_klass = transform_worker_klass

#       # Run the extractor worker
#       worker.perform(config)

#       extraction_worker_klass.verify
#       compound_filter_klass.verify
#       extractor_klass.verify
#       load_worker_klass.verify
#       transform_worker_klass.verify
#     end

#     it 'extracts, transforms, loads' do
#       config = {
#         'cdm_endpoint' => 'https://server16022.contentdm.oclc.org/dmwebservices/index.php',
#         'oai_endpoint' => 'http://cdm16022.contentdm.oclc.org/oai/oai.php',
#         'max_compounds' => 10,
#         'is_recursive' => false,
#         'batch_size' => 2,
#         'solr_config' => { blah: 'blah' }
#       }
#       worker = ExtractWorker.perform_async(config)
#       ExtractWorker.drain
#     end
#   end
# end