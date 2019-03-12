require 'test_helper'

module CDMBL
  describe CdmItemTest do
    it '' do
      record = { 'id' => 'fooCol:123' }
      endpoint = 'http://example.com'
      cdm_api_klass = Minitest::Mock.new
      cdm_api_obj = Minitest::Mock.new
      cdm_api_klass.expect :new, cdm_api_obj, [
        {
          base_url: endpoint,
          collection: 'fooCol',
          id: '123'
        }
      ]
      page = {'page' => [{ 'pageptr' => 0, 'blah' => 'blah' }, { 'pageptr' => 1, 'bar' => 'bar' }]}
      cdm_api_obj.expect :metadata, page, []
      cdm_item = CdmItem.new(record: record,
                             cdm_endpoint: endpoint,
                             cdm_api_klass: cdm_api_klass)
      cdm_item.to_h.must_equal({"page"=>[{"pageptr"=>0, "blah"=>"blah", "id"=>"fooCol:0", "parent_id"=>"fooCol:123", "record_type"=>"secondary", "child_index"=>0}, {"pageptr"=>1, "bar"=>"bar", "id"=>"fooCol:1", "parent_id"=>"fooCol:123", "record_type"=>"secondary", "child_index"=>1}], "record_type"=>"primary"})
      cdm_api_klass.verify
      cdm_api_obj.verify
    end
  end
end