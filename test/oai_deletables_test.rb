require 'test_helper'

module CDMBL
  describe OaiDeletables do
    let(:oai_client) { Minitest::Mock.new }
    let(:oai_record_klass) { Minitest::Mock.new }
    let(:oai_record_instance_1) { Minitest::Mock.new }
    let(:oai_record_instance_2) { Minitest::Mock.new }
    let(:identifiers) { ['colleciton123:1', 'colleciton124:2'] }

    describe '#deletables' do
      it 'makes requests using a persistent connection' do
        OaiClient.stub(:persistent, -> (domain, &block) {
          assert_equal('https://contentdm.oclc.org/oai/oai.php', domain)
          block.call(oai_client)
        }) do
          oai_record_klass.expect :new, oai_record_instance_1, [{ oai_client: oai_client, identifier: 'oai:blah:colleciton123/1' }]
          oai_record_klass.expect :new, oai_record_instance_2, [{ oai_client: oai_client, identifier: 'oai:blah:colleciton124/2' }]
          oai_record_instance_1.expect :record_exists?, true
          oai_record_instance_2.expect :record_exists?, false

          deletables = OaiDeletables.new(
            identifiers: identifiers,
            prefix: 'oai:blah:',
            oai_url: 'https://contentdm.oclc.org/oai/oai.php',
            oai_record_klass: oai_record_klass
          ).deletables

          _(deletables).must_equal ['colleciton124:2']
          oai_record_klass.verify
          oai_record_instance_1.verify
          oai_record_instance_2.verify
        end
      end
    end
  end
end
