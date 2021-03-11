require 'test_helper'

module CDMBL

  describe FieldTransformer do
    let(:formatter) { Minitest::Mock.new }
    let(:formatter_object) { Minitest::Mock.new }
    let(:field_mapping) { Minitest::Mock.new }
    let(:record) { { 'title' => '  The Stars My Destination  ' } }

    it 'calls the field formatter for each mapping' do
      formatter.expect :new, formatter_object, [{:value=>'  The Stars My Destination  ', :formatters=>[CDMBL::DefaultFormatter]}]
      formatter_object.expect :format!, 'The Stars My Destination'
      field_mapping.expect :origin_path, 'title', []
      field_mapping.expect :dest_path, 'title_ssi', []
      field_mapping.expect :formatters, [DefaultFormatter], []
      transformer = FieldTransformer.new(field_mapping: field_mapping,
                                         record: record,
                                         formatter_klass: formatter)
      _(transformer.reduce).must_equal({"title_ssi"=>"The Stars My Destination"})
      formatter.verify
      field_mapping.verify
    end

  end

end
