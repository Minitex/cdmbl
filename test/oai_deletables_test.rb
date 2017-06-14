require 'test_helper'
module CDMBL
  describe OaiDeletables do
    let(:oai_client) { Minitest::Mock.new }
    let(:oai_record_klass) { Minitest::Mock.new }
    let(:oai_record_klass_object_1) { Minitest::Mock.new }
    let(:oai_record_klass_object_2) { Minitest::Mock.new }
    let(:oai_record_klass_object_3) { Minitest::Mock.new }
    let(:oai_record_klass_object_4) { Minitest::Mock.new }
    let(:identifiers) { ['colleciton123:1', 'colleciton124:2'] }


    it 'makes a request' do
      oai_record_klass.expect :new, oai_record_klass_object_1, [{:oai_client=> oai_client, :identifier=>'oai:blah:colleciton123/1'}]
      oai_record_klass.expect :new, oai_record_klass_object_2, [{:oai_client=> oai_client, :identifier=>'oai:blah:colleciton124/2'}]
      oai_record_klass_object_1.expect :record_exists?, true
      oai_record_klass_object_2.expect :record_exists?, false
      OaiDeletables.new(identifiers: identifiers,
                        prefix: 'oai:blah:',
                        oai_client: oai_client,
                        oai_record_klass: oai_record_klass).deletables
        .must_equal ['colleciton124:2']
      oai_record_klass.verify
      oai_record_klass_object_1.verify
      oai_record_klass_object_2.verify
    end
  end
end