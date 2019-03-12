require 'test_helper'

module CDMBL

  describe Transformer do
    let(:cdm_records) { [{'title' => 'The Three-Body Problem', 'id' => 'foo:123'}] }
    let(:record_transformer) { Minitest::Mock.new }
    let(:record_transformer_object) { Minitest::Mock.new }
    let(:field_mappings) {
      [
        {dest_path: 'id', origin_path: 'id', formatters: [StripFormatter, IDFormatter]},
        {dest_path: 'transcription_tesi', origin_path: 'transc', formatters: [StripFormatter]},
        {dest_path: 'record_type', origin_path: 'record_type', formatters: []},
        {dest_path: 'parent_id', origin_path: 'parent_id', formatters: []},
        {dest_path: 'child_index', origin_path: 'child_index', formatters: []}
      ]
    }

    class FakeCache
      def self.cache
        {'cdmdexer_sets' => {}}
      end
    end

    describe 'when not given a field mapping' do
      it 'uses the default field mappings' do
        oai_endpoint = 'example.com'
        oai_request_klass = Minitest::Mock.new
        oai_request_obj = Minitest::Mock.new
        oai_request_klass.expect :new, oai_request_obj, [base_uri: oai_endpoint]
        oai_request_obj.expect :sets, { 'foo' => { bar: 'ba' } }, []

        records = Transformer.new(cdm_records: cdm_records, cache_klass: FakeCache, oai_request_klass: oai_request_klass).records
        records.must_equal [{"id"=>"foo:123", "setspec_ssi"=>"foo:123", "title_tesi"=>"The Three-Body Problem", "title_ssi"=>"The Three-Body Problem", "title_sort"=>"The Three-Body Problem", "title_unstem_search"=>"The Three-Body Problem"}]
      end
    end

    it "transforms kaltura media metadata" do
      records = [{
                    'id' => 'foo:123',
                    'audioa' => '0_sdfsdf',
                    'audio' => '0_eenv',
                    'video' => '0_w3vvA'
                }]
      field_mappings = [
        {dest_path: 'kaltura_audio_ssi', origin_path: 'audio', formatters: [StripFormatter]},
        {dest_path: 'kaltura_audio_playlist_ssi', origin_path: 'audioa', formatters: [StripFormatter]},
        {dest_path: 'kaltura_video_ssi', origin_path: 'video', formatters: [StripFormatter]},
        {dest_path: 'kaltura_video_playlist_ssi', origin_path: 'videoa', formatters: [StripFormatter]}
      ]
      oai_endpoint = 'example.com'
      oai_request_klass = Minitest::Mock.new
      oai_request_obj = Minitest::Mock.new
      oai_request_klass.expect :new, oai_request_obj, [base_uri: oai_endpoint]
      oai_request_obj.expect :sets, { 'foo' => { bar: 'ba' } }, []

      transformation =  Transformer.new(cdm_records: records, field_mappings: field_mappings, cache_klass: FakeCache, oai_request_klass: oai_request_klass).records.first
      transformation['kaltura_audio_ssi'].must_equal '0_eenv'
      transformation['kaltura_video_ssi'].must_equal '0_w3vvA'
      transformation['kaltura_audio_playlist_ssi'].must_equal '0_sdfsdf'
    end

    it 'transforms table of contents data' do
      records = [{
              'id' => 'foo:123',
              'table' => "First Item; Second Item; \nThird Item"
          }]
      field_mappings = [
        {dest_path: 'table_ssim', origin_path: 'table', formatters: [StripFormatter, SplitFormatter, StripFormatter]}
      ]
      oai_endpoint = 'example.com'
      oai_request_klass = Minitest::Mock.new
      oai_request_obj = Minitest::Mock.new
      oai_request_klass.expect :new, oai_request_obj, [base_uri: oai_endpoint]
      oai_request_obj.expect :sets, { 'foo' => { bar: 'ba' } }, []

      transformation =  Transformer.new(cdm_records: records, field_mappings: field_mappings, cache_klass: FakeCache, oai_request_klass: oai_request_klass).records.first
      transformation['table_ssim'].must_equal ["First Item", "Second Item", "Third Item"]
    end

    it "enriches from GeoNames service" do
        records = [{
                    'id' => 'foo:123',
                    'geonam' => 'http://sws.geonames.org/5024729/'
                }]
        field_mappings = [
          {dest_path: 'coordinates_llsi', origin_path: 'geonam', formatters: [GeoNameID, GeoNameIDToJson, GeoNameToLocation]},
          {dest_path: 'placename_ssim', origin_path: 'geonam', formatters: [GeoNameID, GeoNameIDToJson, GeoNameToPlaceName]}
        ]

        oai_endpoint = 'example.com'
        oai_request_klass = Minitest::Mock.new
        oai_request_obj = Minitest::Mock.new
        oai_request_klass.expect :new, oai_request_obj, [base_uri: oai_endpoint]
        oai_request_obj.expect :sets, { 'foo' => { bar: 'ba' } }, []

        transformation =  Transformer.new(cdm_records: records, field_mappings: field_mappings, cache_klass: FakeCache, oai_request_klass: oai_request_klass).records.first
        transformation['coordinates_llsi'].must_equal '46.78111,-92.11806'
        transformation['placename_ssim'].must_equal ["City of Duluth", "Saint Louis"]
    end

    it "creates a composite keyword field" do
      records = [{
                    'id' => 'foo:123',
                    'genera' => 'Minnesota;Lakes',
                    'specif' => 'Hennepin County',
                    'subjec' => 'Bar'
                }]

        field_mappings = [
          {dest_path: 'keyword_ssim', origin_path: '/', formatters: [KeywordFormatter, Titlieze, UniqueFormatter, StripFormatter]}
        ]
        oai_endpoint = 'example.com'
        oai_request_klass = Minitest::Mock.new
        oai_request_obj = Minitest::Mock.new
        oai_request_klass.expect :new, oai_request_obj, [base_uri: oai_endpoint]
        oai_request_obj.expect :sets, { 'foo' => { bar: 'ba' } }, []

        transformation =  Transformer.new(cdm_records: records, field_mappings: field_mappings, cache_klass: FakeCache, oai_request_klass: oai_request_klass).records.first
        transformation['keyword_ssim'].must_equal ["Bar", "Hennepin County", "Lakes", "Minnesota"]
    end

    describe 'when a field mapping produces an error' do
      it "raises an error along with the field mapping configuration" do
          records = [{
                      'id' => 'foo/5123',
                      'has_children' => true
                  }]

          mappings = [{dest_path: 'has_children', origin_path: 'has_children', formatters: [StripFormatter]}]

          oai_endpoint = 'example.com'
          oai_request_klass = Minitest::Mock.new
          oai_request_obj = Minitest::Mock.new
          oai_request_klass.expect :new, oai_request_obj, [base_uri: oai_endpoint]
          oai_request_obj.expect :sets, { 'foo' => { bar: 'ba' } }, []

          transformation =  Transformer.new(cdm_records: records, field_mappings: mappings, cache_klass: FakeCache, oai_request_klass: oai_request_klass)
          err = ->{ transformation.records }.must_raise RuntimeError
          err.message.must_equal 'Mapping Error:{:dest_path=>"has_children", :origin_path=>"has_children", :formatters=>[CDMBL::StripFormatter]} Error:undefined method `strip\' for true:TrueClass'
      end
    end
  end
end