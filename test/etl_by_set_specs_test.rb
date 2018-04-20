require 'test_helper'

module CDMBL
  describe ETLBySetSpecs do

    it 'iterates through an array of set_specs and launches workers for each' do
      worker = Minitest::Mock.new
      worker.expect :perform_async, nil, [{:foo=>"bar", :set_spec=>"foo1243"}]
      worker.expect :perform_async, nil, [{:foo=>"bar", :set_spec=>"blah"}]
      etl_config = {foo: 'bar'}
      ETLBySetSpecs.new(etl_config: etl_config,
                       set_specs: ['foo1243', 'blah'],
                       etl_worker_klass: worker).run!
      worker.verify
    end
  end
end