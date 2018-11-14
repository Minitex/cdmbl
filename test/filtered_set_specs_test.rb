require 'test_helper'


module CDMBL

  describe FilteredSetSpecs do

    it 'Requests ListSets from an OAI Endpoint, filters them with provided callback' do
      oai_base_url = 'http://cdm16022.contentdm.oclc.org/oai/oai.php'
      sets = [
        {'setSpec' => 'fooBar', 'setName' => 'Blah Collection of Blah'},
        {'setSpec' => 'fooBan', 'setName' => 'Blah Collection of Blas'}
      ]
      oai_response = {'OAI_PMH' => {'ListSets' => {'set' => sets}}}
      oai_client = Minitest::Mock.new("OAIClient")
      oai_client_obj = Minitest::Mock.new("OAIClientOBJ")
      filter_set_callback = Minitest::Mock.new("FilterSetCallback")
      oai_client.expect(:new, oai_client_obj, [{base_url: oai_base_url}])
      oai_client_obj.expect(:request, oai_response, ['verb=ListSets'])
      filter_set_callback.expect(:valid?, true, [{:set => sets.first}])
      filter_set_callback.expect(:valid?, true, [{:set => sets.last}])

      filtered = FilteredSetSpecs.new(oai_base_url: oai_base_url,
                                       callback: filter_set_callback,
                                       oai_client: oai_client)

      expect(filtered.set_specs).must_equal ["fooBar", "fooBan"]
      expect(filtered.filtered_sets).must_equal [{"setSpec"=>"fooBar", "setName"=>"Blah Collection of Blah"}, {"setSpec"=>"fooBan", "setName"=>"Blah Collection of Blas"}]
    end
  end
end