require 'test_helper'

module CDMBL
  describe FieldFormatter do
    it 'does nothing when no formatters have been specified' do
      formatter = FieldFormatter.new(value: {foo: 'bar'})
      _(formatter.format!).must_equal({foo: 'bar'})
    end

    it 'allows for custom field formatters' do
      fake_formatter = Minitest::Mock.new
      fake_formatter.expect :format, {bar: 'foo'}, [{:foo=>"bar"}]
      formatter = FieldFormatter.new(value: {foo: 'bar'}, formatters: [fake_formatter])
      _(formatter.format!).must_equal({bar: 'foo'})
      fake_formatter.verify
    end

    describe 'when the StripFormatter is given a nil value' do
      it 'returns an empty string' do
        formatter = FieldFormatter.new(value: nil, formatters: [StripFormatter])
        _(formatter.format!).must_equal('')
      end
    end
  end
end
