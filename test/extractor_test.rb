require 'test_helper'

module CDMBL

  describe Extractor do
    let(:oai_request)  { Minitest::Mock.new }
    let(:cdm_klass)  { Minitest::Mock.new }
    let(:cdm_object)  { Minitest::Mock.new }
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

    it 'parses an OAI ListIdentifiers request into an array of collection / identifier arrays' do
      oai_request.expect :identifiers, identifiers_xml
      Extractor.new(oai_request: oai_request).local_identifiers.must_equal [["p16022coll44", "0"], ["p16022coll44", "1"]]
      oai_request.verify
    end

    it 'makes a request to a CONTENTdm API for each collection/identifier set' do
      oai_request.expect :identifiers, identifiers_xml
      cdm_klass.expect :new, cdm_object, [{:base_url=>"", :collection=>"p16022coll44", :id=>"0"}]
      cdm_klass.expect :new, cdm_object, [{:base_url=>"", :collection=>"p16022coll44", :id=>"1"}]
      cdm_object.expect :metadata, {id: '123'}
      cdm_object.expect :metadata, {id: '321'}
      extractor = Extractor.new(oai_request: oai_request, cdm_item: cdm_klass)
      (extractor.local_identifiers.map { |identifier| extractor.cdm_request(*identifier) }).must_equal [{:id=>"123"}, {:id=>"321"}]
      oai_request.verify
      cdm_object.verify
      cdm_klass.verify
    end

    it 'returns a set of collections keyed by their setSpec' do
      oai_request.expect :sets, sets_xml
      extractor = Extractor.new(oai_request: oai_request, cdm_item: cdm_klass)
      extractor.set_lookup.must_equal({"p16022coll44"=>{:name=>"American Craft Council", :description=>"Collection information undefined."}, "swede"=>{:name=>"American Swedish Institute", :description=>nil}})
      oai_request.verify
    end

    it 'returns the next resumption token' do
      oai_request.expect :identifiers, identifiers_xml
      extractor = Extractor.new(oai_request: oai_request)
      extractor.next_resumption_token.must_equal 'swede:96:oclc-cdm-allsets:0000-00-00:9999-99-99:oai_dc'
      oai_request.verify
    end

    it 'returns the next resumption token' do
      oai_request.expect :identifiers, identifiers_xml
      oai_request.expect :identifiers, identifiers_xml
      oai_filter = Minitest::Mock.new
      oai_filter_object = Minitest::Mock.new
      oai_filter.expect :new, oai_filter_object, [{:headers=>[{"identifier"=>"oai:reflections.mndigital.org:p16022coll44/0", "datestamp"=>"2015-09-30", "setSpec"=>"p16022coll44"}, {"identifier"=>"oai:reflections.mndigital.org:p16022coll44/1", "datestamp"=>"2015-09-30", "setSpec"=>"p16022coll44"}]}]
      oai_filter.expect :new, oai_filter_object, [{:headers=>[{"identifier"=>"oai:reflections.mndigital.org:p16022coll44/0", "datestamp"=>"2015-09-30", "setSpec"=>"p16022coll44"}, {"identifier"=>"oai:reflections.mndigital.org:p16022coll44/1", "datestamp"=>"2015-09-30", "setSpec"=>"p16022coll44"}]}]
      oai_filter_object.expect :updatable_ids, 'foo'
      oai_filter_object.expect :deletable_ids, 'bar'
      extractor = Extractor.new(oai_request: oai_request, oai_filter: oai_filter)
      extractor.local_identifiers.must_equal 'foo'
      extractor.deletable_ids.must_equal 'bar'
      oai_filter.verify
      oai_filter_object.verify
    end


  end

end