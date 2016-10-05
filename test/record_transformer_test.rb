require 'test_helper'

module CDMBL
  describe RecordTransformer do
    let(:field_transformer) { Minitest::Mock.new }
    let(:field_transformer_object) { Minitest::Mock.new }
    let(:mappings) { [{dest_path: 'foo', origin_path: 'bar' }, {dest_path: 'blerg', origin_path: 'baaa' }] }
    let(:record) { {foo: 'bar'} }

    it 'iterates over a set of field mappings and calls the a field transformer for each mapping' do
      field_transformer.expect :new, field_transformer_object, [{:origin_path=>"bar", :dest_path=>"foo", :formatters=>nil, :record=>{:foo=>"bar"}}]
      field_transformer.expect :new, field_transformer_object, [{:origin_path=>"baaa", :dest_path=>"blerg", :formatters=>nil, :record=>{:foo=>"bar"}}]
      field_transformer_object.expect :reduce, {foo: 'bar', baz: 'bar'}
      field_transformer_object.expect :reduce, {foo: 'bar', baz: 'blech'}
      transformer = RecordTransformer.new(record: record,
                                          field_mappings: mappings,
                                          field_transformer: field_transformer)
      transformer.transform!.must_equal({foo: 'bar', baz: 'blech'})
      field_transformer.verify
      field_transformer_object.verify
    end

  end

end