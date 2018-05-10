require 'test_helper'

module CDMBL

  describe Transformer do
    let(:cdm_records) { [{'title' => 'The Three-Body Problem'}] }
    let(:record_transformer) { Minitest::Mock.new }
    let(:record_transformer_object) { Minitest::Mock.new }
    let(:field_mappings) {
      [
        {dest_path: 'id', origin_path: 'id', formatters: [StripFormatter, IDFormatter]},
        {dest_path: 'compound_objects_ts', origin_path: 'page', formatters: [ToJsonFormatter]},
        {dest_path: 'transcription_tesi', origin_path: 'transc', formatters: [StripFormatter]},
        {dest_path: 'record_type', origin_path: 'record_type', formatters: []},
        {dest_path: 'parent_id', origin_path: 'parent_id', formatters: []}
      ]
    }

    it "transforms kaltura media metadata" do
      records = [{
                    'id' => 'foo/123',
                    'audioa' => '0_sdfsdf',
                    'audio' => '0_eenv',
                    'video' => '0_w3vvA'
                }]
      transformation = Transformer.new(cdm_records: records).records.first
      transformation['kaltura_audio_ssi'].must_equal '0_eenv'
      transformation['kaltura_video_ssi'].must_equal '0_w3vvA'
      transformation['kaltura_audio_playlist_ssi'].must_equal '0_sdfsdf'
    end

    it 'transforms table of contents data' do
      records = [{
              'id' => 'foo/123',
              'table' => "First Item; Second Item; \nThird Item"
          }]
      transformation = Transformer.new(cdm_records: records).records.first
      transformation['table_ssim'].must_equal ["First Item", "Second Item", "Third Item"]
    end

    it "enriches from GeoNames service" do
      records = [{
                    'id' => 'foo/123',
                    'geonam' => 'http://sws.geonames.org/5024729/'
                }]
        transformation = Transformer.new(cdm_records: records).records.first
        transformation['coordinates_llsi'].must_equal '46.78111,-92.11806'

        transformation = Transformer.new(cdm_records: records).records.first
        transformation['placename_ssim'].must_equal ["City of Duluth", "Saint Louis County"]
    end

    it "creates a composite keyword field" do
      records = [{
                    'id' => 'foo/123',
                    'genera' => 'Minnesota;Lakes',
                    'specif' => 'Hennepin County',
                    'subjec' => 'Bar'
                }]
        transformation = Transformer.new(cdm_records: records).records.first
        transformation['keyword_ssim'].must_equal ["Bar", "Hennepin County", "Lakes", "Minnesota"]
    end



    describe 'when a record is a compound' do
      describe 'and extract_compounds is unset' do
        it "simply uses the records provided" do
          records = [{
                        'id' => 'foo/5123',
                        'page' => [{'id' => 'blah/3245', 'transc' => 'OHAI CHEEZEBURGER'}]
                    }]
            transformation = Transformer.new(cdm_records: records, field_mappings: field_mappings).records
            transformation.must_equal([{"id"=>"foo:5123", "compound_objects_ts"=>"[{\"id\":\"blah/3245\",\"transc\":\"OHAI CHEEZEBURGER\"}]","record_type"=>"primary"}])
        end
      end
      describe 'and extract_compounds is set to true (we want to unpack the compounds)' do
        it "simply uses the records provided" do
          records = [{
                        'id' => 'foo/5123',
                        'page' => [{'id' => 'blah/3245', 'transc' => 'OHAI CHEEZEBURGER'}]
                    }]
            transformation = Transformer.new(cdm_records: records, extract_compounds: true, field_mappings: field_mappings).records
            transformation.must_equal([
              {"id"=>"foo:5123", "compound_objects_ts"=>"[{\"id\":\"blah/3245\",\"transc\":\"OHAI CHEEZEBURGER\",\"parent_id\":\"foo/5123\",\"record_type\":\"secondary\"}]","record_type"=>"primary"},
              {"id"=>"blah:3245", "transcription_tesi"=>"OHAI CHEEZEBURGER","record_type"=>"secondary","parent_id"=>"foo/5123"}
            ])
        end
      end
    end


  end
end