require 'test_helper'

module CDMBL

  describe FieldTransformer do
    let(:formatter) { Minitest::Mock.new }
    let(:formatter_object) { Minitest::Mock.new }
    let(:record) { { 'title' => '  The Stars My Destination  ' } }

    it 'calls the field formatter for each mapping' do
      formatter.expect :new, formatter_object, [{:value=>'  The Stars My Destination  ', :formatters=>[]}]
      formatter_object.expect :format!, 'The Stars My Destination'
      transformer = FieldTransformer.new(origin_path: 'title',
                                         dest_path: 'title_ssi',
                                         record: record,
                                         formatter_klass: formatter)
      transformer.reduce.must_equal({"title_ssi"=>"The Stars My Destination"})
      formatter.verify
    end

  end

end