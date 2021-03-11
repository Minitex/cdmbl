require 'test_helper'

module CDMBL

  describe OAISetLookup do
    let(:oai_sets) do
      {"OAI_PMH"=>{"xmlns"=>"http://www.openarchives.org/OAI/2.0/", "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance", "xsi:schemaLocation"=>"http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd", "ListSets"=>{"set"=>[{"setSpec"=>"p16022coll44", "setName"=>"American Craft Council", "setDescription"=>{"dc"=>{"xmlns:oai_dc"=>"http://www.openarchives.org/OAI/2.0/oai_dc/", "xmlns:dc"=>"http://purl.org/dc/elements/1.1/", "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance", "xsi:schemaLocation"=>"http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd", "description"=>"Collection information undefined."}}}, {"setSpec"=>"swede", "setName"=>"American Swedish Institute"}]}}}
    end

    it 'keys an OAI ListSet response by the setSpec' do
      lookup = OAISetLookup.new(oai_sets: oai_sets)
      _(lookup.keyed).must_equal({"p16022coll44"=>{:name=>"American Craft Council", :description=>"Collection information undefined."}, "swede"=>{:name=>"American Swedish Institute", :description=>nil}})
    end

  end

end
