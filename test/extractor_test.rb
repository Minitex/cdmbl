require 'test_helper'

module CDMBL

  describe Extractor do
    let(:oai_request_klass) { Minitest::Mock.new }
    let(:oai_request_klass_object) { Minitest::Mock.new }
    let(:oai_endpoint) { 'http//oai_endpoint.example.com' }
    let(:cdm_klass) { Minitest::Mock.new }
    let(:cdm_object) { Minitest::Mock.new }
    let(:identifiers_xml) {'<OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
                              <ListIdentifiers>
                                <header>
                                  <identifier>oai:reflections.mndigital.org:p16022coll44/0</identifier>
                                    <datestamp>2015-09-30</datestamp>
                                    <setSpec>p16022coll44</setSpec>
                                  </header>
                                  <header>
                                    <identifier>oai:reflections.mndigital.org:p16022coll44/1</identifier>
                                    <datestamp>2015-09-30</datestamp>
                                    <setSpec>p16022coll44</setSpec>
                                  </header>
                                  <resumptionToken>swede:96:oclc-cdm-allsets:0000-00-00:9999-99-99:oai_dc</resumptionToken>
                              </ListIdentifiers>
                            </OAI-PMH>'}
    let(:sets_xml) {'<OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
                      <ListSets>
                        <set>
                            <setSpec>p16022coll44</setSpec>
                            <setName>American Craft Council</setName>
                            <setDescription>
                              <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
                              <dc:description>Collection information undefined.</dc:description>
                              </oai_dc:dc>
                            </setDescription>
                        </set>
                        <set>
                          <setSpec>swede</setSpec>
                          <setName>American Swedish Institute</setName>
                        </set>
                      </ListSets>
                    </OAI-PMH>'}

    let(:identifier_single_xml) {'<OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
                        <ListIdentifiers>
                          <header>
                            <identifier>oai:reflections.mndigital.org:p16022coll44/0</identifier>
                              <datestamp>2015-09-30</datestamp>
                              <setSpec>p16022coll44</setSpec>
                            </header>
                            <resumptionToken>swede:96:oclc-cdm-allsets:0000-00-00:9999-99-99:oai_dc</resumptionToken>
                        </ListIdentifiers>
                      </OAI-PMH>'}
    let(:no_results_xml) {'<OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
      <responseDate>2021-03-14T03:42:21Z</responseDate>
      <request verb="ListIdentifiers" metadataPrefix="oai_dc" set="p16022coll5" from="2021-03-04">http://cdm16022.contentdm.oclc.org/oai/oai.php</request>
      <error code="noRecordsMatch">The combination of the values of the from, until, set and metadataPrefix arguments results in an empty list. </error>
    </OAI-PMH>'}
    let(:sets_hash) { Hash.from_xml(sets_xml) }
    let(:identifiers_hash) { Hash.from_xml(identifiers_xml) }


    describe 'when only one record is returned' do
      it 'handles the request' do
        oai_request_klass.expect :new,
                                 oai_request_klass_object,
                                 [
                                   {
                                     :base_uri => 'oai_endpoint_here',
                                     :resumption_token => 'foo',
                                     :set => 'bar'
                                   }
                                 ]
        oai_request_klass_object.expect :identifiers, Hash.from_xml(identifier_single_xml)
        extractor = Extractor.new(oai_endpoint: 'oai_endpoint_here',
                                  resumption_token: 'foo',
                                  set_spec: 'bar',
                                  oai_request_klass: oai_request_klass)
        local_ids = extractor.local_identifiers
        _(local_ids).must_equal [['p16022coll44', '0']]
        oai_request_klass.verify
        oai_request_klass_object.verify
      end
    end


    it 'parses an OAI ListIdentifiers request into an array of collection / identifier arrays' do
      oai_request_klass.expect :new,
                               oai_request_klass_object,
                               [
                                 {
                                   :base_uri => 'oai_endpoint_here',
                                   :resumption_token => 'foo',
                                   :set => 'bar'
                                 }
                               ]
      oai_request_klass_object.expect :identifiers, identifiers_hash
      extractor = Extractor.new(oai_endpoint: 'oai_endpoint_here',
                                resumption_token: 'foo',
                                set_spec: 'bar',
                                oai_request_klass: oai_request_klass)
      local_ids = extractor.local_identifiers
      _(local_ids).must_equal [
                                ['p16022coll44', '0'],
                                ['p16022coll44', '1']
                              ]
      oai_request_klass.verify
      oai_request_klass_object.verify
    end

    it 'returns a set of collections keyed by their setSpec' do
      oai_request_klass.expect :new,
                               oai_request_klass_object,
                               [
                                 {
                                  :base_uri => 'oai_endpoint_here',
                                  :resumption_token => 'foo',
                                  :set=>'bar'
                                 }
                               ]
      oai_request_klass_object.expect :sets, sets_hash
      extractor = Extractor.new(oai_endpoint: 'oai_endpoint_here',
                                resumption_token: 'foo',
                                set_spec: 'bar',
                                oai_request_klass: oai_request_klass)
      _(extractor.set_lookup).must_equal(
        {
          'p16022coll44' => {
              :name => 'American Craft Council',
              :description => 'Collection information undefined.'
            },
              'swede' => {
                :name => 'American Swedish Institute',
                :description => nil
            }
        })
      oai_request_klass.verify
      oai_request_klass_object.verify
    end

    it 'returns the next resumption token' do
      oai_request_klass.expect :new,
                               oai_request_klass_object,
                               [
                                 {
                                   :base_uri => 'oai_endpoint_here',
                                   :resumption_token => 'foo',
                                   :set => 'bar'
                                 }
                               ]
      oai_request_klass_object.expect :identifiers, identifiers_hash
      extractor = Extractor.new(oai_endpoint: 'oai_endpoint_here',
                                resumption_token: 'foo',
                                set_spec: 'bar',
                                oai_request_klass: oai_request_klass)
      _(extractor.next_resumption_token).must_equal 'swede:96:oclc-cdm-allsets:0000-00-00:9999-99-99:oai_dc'
      oai_request_klass.verify
      oai_request_klass_object.verify
    end

    it 'calls the OAI filter object' do
      oai_request_klass.expect :new,
                               oai_request_klass_object,
                               [
                                 {
                                   :base_uri => 'oai_endpoint_here',
                                   :resumption_token => 'foo',
                                   :set => 'bar'
                                 }
                               ]
      oai_request_klass_object.expect :identifiers, identifiers_hash
      oai_filter_klass = Minitest::Mock.new
      oai_filter_klass_object = Minitest::Mock.new
      oai_filter_klass.expect :new,
                              oai_filter_klass_object,
                              [
                                {
                                  headers: [
                                    {
                                      'identifier' => 'oai:reflections.mndigital.org:p16022coll44/0',
                                      'datestamp' => '2015-09-30',
                                      'setSpec' => 'p16022coll44'
                                    },
                                    {
                                      'identifier' => 'oai:reflections.mndigital.org:p16022coll44/1',
                                      'datestamp' => '2015-09-30',
                                      'setSpec' => 'p16022coll44'
                                    }
                                  ]
                                }
                              ]
      oai_filter_klass.expect :new,
                              oai_filter_klass_object,
                              [
                                {
                                  headers: [
                                    {
                                      'identifier' => 'oai:reflections.mndigital.org:p16022coll44/0',
                                      'datestamp' => '2015-09-30',
                                      'setSpec' => 'p16022coll44'
                                    },
                                    {
                                      'identifier' => 'oai:reflections.mndigital.org:p16022coll44/1',
                                      'datestamp' => '2015-09-30',
                                      'setSpec' => 'p16022coll44'
                                    }
                                  ]
                                }
                              ]
      oai_filter_klass_object.expect :updatable_ids, 'foo'
      oai_filter_klass_object.expect :deletable_ids, 'bar'
      extractor = Extractor.new(oai_endpoint: 'oai_endpoint_here',
                                resumption_token: 'foo',
                                set_spec: 'bar',
                                oai_request_klass: oai_request_klass,
                                oai_filter_klass: oai_filter_klass)
      _(extractor.local_identifiers).must_equal 'foo'
      _(extractor.deletable_ids).must_equal 'bar'
      oai_filter_klass.verify
      oai_filter_klass_object.verify
    end

    describe 'when a collection is empty or doesn\'t exist' do
      it 'returns an emtpy identifier list' do
        oai_filter_klass = Minitest::Mock.new
        oai_filter_klass_object = Minitest::Mock.new
        oai_request_klass.expect(:new, oai_request_klass_object, [
          {
            base_uri: 'oai_endpoint_here',
            set: 'bar',
            resumption_token: nil
          }
        ])
        oai_request_klass_object.expect(
          :identifiers,
          Hash.from_xml(no_results_xml)
        )
        oai_filter_klass.expect(
          :new,
          oai_filter_klass_object,
          [ { headers: [] } ]
        )
        oai_filter_klass_object.expect(:updatable_ids, [])
        local_ids = Extractor.new(
          oai_endpoint: 'oai_endpoint_here',
          set_spec: 'bar',
          oai_filter_klass: oai_filter_klass,
          oai_request_klass: oai_request_klass
        ).local_identifiers
        _(local_ids).must_equal([])
      end
    end

    describe 'when given a "from" date for selective harvesting' do
      it 'instantiates the OaiRequest class with the given date' do
        oai_request_klass.expect(:new, oai_request_klass_object, [
          {
            base_uri: 'oai_endpoint_here',
            resumption_token: 'foo',
            set: 'bar',
            from: '2021-02-23'
          }
        ])
        Extractor.new(
          oai_endpoint: 'oai_endpoint_here',
          resumption_token: 'foo',
          set_spec: 'bar',
          from: '2021-02-23',
          oai_request_klass: oai_request_klass
        )

        oai_request_klass.verify
      end
    end
  end
end
