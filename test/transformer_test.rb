require 'test_helper'

module CDMBL

  describe Transformer do
    let(:cdm_records) { [{'title' => 'The Three-Body Problem'}] }
    let(:record_transformer) { Minitest::Mock.new }
    let(:record_transformer_object) { Minitest::Mock.new }

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
        transformation['placename_ssim'].must_equal ["Duluth, City of", "Saint Louis County"]
    end
  end
end