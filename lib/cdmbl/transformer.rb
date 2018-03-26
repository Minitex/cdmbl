require 'json'
require 'titleize'

module CDMBL

  class Transformer
    attr_reader :cdm_records,
                :oai_sets,
                :field_mappings,
                :record_transformer
    def initialize(cdm_records: [],
                   oai_sets: {},
                   field_mappings: false,
                   record_transformer: RecordTransformer)
      @cdm_records        = cdm_records
      @oai_sets           = oai_sets
      @field_mappings     = mappings_init(field_mappings)
      @record_transformer = record_transformer
    end

    def records
      cdm_records.map { |record| to_solr(record) }.compact
    end

    private

    def mappings_init(mappings)
        (mappings) ? mappings : self.class.default_mappings
    end

    def to_solr(record)
      # Remove empty records (move this behavior to the CONTENTdm API gem) and
      # bail early on the transformation process
      if {'id' => record['id']} == record
        return nil
      else
        record_transformer.new(record: record.merge('oai_sets' => oai_sets),
                               field_mappings: field_mappings).transform!
      end
    end

    def self.default_mappings
      [
        {dest_path: 'location_llsi', origin_path: '/', formatters: [LocationFormatter]},
        {dest_path: 'id', origin_path: 'id', formatters: [StripFormatter, IDFormatter]},
        {dest_path: 'setspec_ssi', origin_path: '/', formatters: [AddSetSpecFormatter, SetSpecFormatter]},
        {dest_path: 'collection_name_ssi', origin_path: '/', formatters: [AddSetSpecFormatter, CollectionNameFormatter]},
        {dest_path: 'collection_name_tei', origin_path: '/', formatters: [AddSetSpecFormatter, CollectionNameFormatter]},
        {dest_path: 'collection_description_tesi', origin_path: '/', formatters: [AddSetSpecFormatter, CollectionDescriptionFormatter, FilterBadCollections]},
        {dest_path: 'parent_collection_name_ssi', origin_path: 'par', formatters: [StripFormatter]},
        {dest_path: 'parent_collection_name_tei', origin_path: 'par', formatters: [StripFormatter]},
        {dest_path: 'parent_collection_description_tei', origin_path: 'par', formatters: [StripFormatter]},
        {dest_path: 'title_tesi', origin_path: 'title', formatters: [StripFormatter]},
        {dest_path: 'title_ssi', origin_path: 'title', formatters: [StripFormatter]},
        {dest_path: 'title_sort', origin_path: 'title', formatters: [StripFormatter]},
        {dest_path: 'title_unstem_search', origin_path: 'title', formatters: [StripFormatter]},
        {dest_path: 'contributor_teim', origin_path: 'contri', formatters: [StripFormatter]},
        {dest_path: 'contributor_unstem_search', origin_path: 'contri', formatters: [StripFormatter]},
        {dest_path: 'contributor_ssim', origin_path: 'contri', formatters: [SplitFormatter, StripFormatter]},
        {dest_path: 'creator_tesi', origin_path: 'photog', formatters: [JoinFormatter, StripFormatter]},
        {dest_path: 'creator_unstem_search', origin_path: 'photog', formatters: [StripFormatter]},
        {dest_path: 'creator_ssim', origin_path: 'photog', formatters: [SplitFormatter, StripFormatter]},
        {dest_path: 'creator_sort', origin_path: 'photog', formatters: [StripFormatter]},
        {dest_path: 'description_tei', origin_path: 'descri', formatters: [StripFormatter]},
        {dest_path: 'description_ts', origin_path: 'descri', formatters: [StripFormatter]},
        {dest_path: 'dat_ssi', origin_path: 'dat', formatters: [StripFormatter]},
        {dest_path: 'dat_tesi', origin_path: 'dat', formatters: [StripFormatter]},
        {dest_path: 'dat_sort', origin_path: 'dat', formatters: [StripFormatter]},
        {dest_path: 'publishing_agency_tei', origin_path: 'publia', formatters: [StripFormatter]},
        {dest_path: 'publishing_agency_unstem_search', origin_path: 'publia', formatters: [StripFormatter]},
        {dest_path: 'publishing_agency_ssi', origin_path: 'publia', formatters: [StripFormatter]},
        {dest_path: 'dimensions_ssi', origin_path: 'dimens', formatters: [StripFormatter]},
        {dest_path: 'topic_teim', origin_path: 'genera', formatters: [StripFormatter, SplitFormatter, StripFormatter]},
        {dest_path: 'topic_ssim', origin_path: 'genera', formatters: [Titlieze, StripFormatter, SplitFormatter, StripFormatter]},
        {dest_path: 'topic_unstem_search', origin_path: 'genera', formatters: [StripSemicolonFormatter, StripFormatter]},
        {dest_path: 'type_ssi', origin_path: 'type', formatters: [Titlieze, StripSemicolonFormatter, StripFormatter]},
        {dest_path: 'type_tesi', origin_path: 'type', formatters: [Titlieze, StripSemicolonFormatter, StripFormatter]},
        {dest_path: 'physical_format_ssi', origin_path: 'physic', formatters: [StripSemicolonFormatter]},
        {dest_path: 'physical_format_tesi', origin_path: 'physic', formatters: [StripSemicolonFormatter]},
        {dest_path: 'formal_subject_unstem_search', origin_path: 'specif', formatters: [StripFormatter]},
        {dest_path: 'formal_subject_ssim', origin_path: 'specif', formatters: [Titlieze, StripFormatter, SplitFormatter, StripFormatter]},
        {dest_path: 'formal_subject_teim', origin_path: 'specif', formatters: [Titlieze, StripFormatter, SplitFormatter, StripFormatter]},
        {dest_path: 'subject_unstem_search', origin_path: 'subjec', formatters: [StripFormatter]},
        {dest_path: 'subject_teim', origin_path: 'subjec', formatters: [StripFormatter, SplitFormatter, StripFormatter]},
        {dest_path: 'subject_ssim', origin_path: 'subjec', formatters: [StripFormatter, SplitFormatter, StripFormatter]},
        {dest_path: 'keyword_unstem_search', origin_path: '/', formatters: [KeywordFormatter, Titlieze, UniqueFormatter, StripFormatter]},
        {dest_path: 'keyword_tesi', origin_path: '/', formatters: [KeywordFormatter, Titlieze, UniqueFormatter, JoinFormatter, StripFormatter]},
        {dest_path: 'keyword_ssim', origin_path: '/', formatters: [KeywordFormatter, Titlieze, UniqueFormatter, StripFormatter]},
        {dest_path: 'city_ssim', origin_path: 'city', formatters: [StripFormatter, SplitFormatter, StripFormatter]},
        {dest_path: 'city_unstem_search', origin_path: 'city', formatters: [StripFormatter]},
        {dest_path: 'district_ssi', origin_path: 'distri', formatters: [StripFormatter]},
        {dest_path: 'district_unstem_search', origin_path: 'distri', formatters: [StripFormatter]},
        {dest_path: 'county_ssim', origin_path: 'county', formatters: [Titlieze, StripFormatter, SplitFormatter, StripFormatter]},
        {dest_path: 'county_unstem_search', origin_path: 'county', formatters: [StripFormatter]},
        {dest_path: 'state_ssi', origin_path: 'state', formatters: [StripFormatter]},
        {dest_path: 'state_unstem_search', origin_path: 'state', formatters: [StripFormatter]},
        {dest_path: 'country_ssi', origin_path: 'countr', formatters: [StripFormatter]},
        {dest_path: 'country_unstem_search', origin_path: 'countr', formatters: [StripFormatter]},
        {dest_path: 'language_ssi', origin_path: 'langua', formatters: [StripFormatter]},
        {dest_path: 'language_unstem_search', origin_path: 'langua', formatters: [StripFormatter]},
        {dest_path: 'contributing_unstem_search', origin_path: 'contra', formatters: [StripFormatter]},
        {dest_path: 'contributing_organization_tesi', origin_path: 'contra', formatters: [StripFormatter]},
        {dest_path: 'contributing_organization_ssi', origin_path: 'contra', formatters: [Titlieze, StripFormatter]},
        {dest_path: 'contact_information_ssi', origin_path: 'contac', formatters: [StripFormatter]},
        {dest_path: 'rights_ssi', origin_path: 'righta', formatters: [StripFormatter]},
        {dest_path: 'local_identifier_ssi', origin_path: 'identi', formatters: [StripFormatter]},
        {dest_path: 'identifier_ssi', origin_path: 'resour', formatters: [StripFormatter]},
        {dest_path: 'project_ssi', origin_path: 'projec', formatters: [StripFormatter]},
        {dest_path: 'fiscal_sponsor_ssi', origin_path: 'fiscal', formatters: [StripFormatter]},
        {dest_path: 'publisher_ssi', origin_path: 'publis', formatters: [StripFormatter]},
        {dest_path: 'date_ssi', origin_path: 'date', formatters: [StripFormatter]},
        {dest_path: 'format_tesi', origin_path: 'format', formatters: [StripFormatter]},
        {dest_path: 'digspa_ssi', origin_path: 'digspa'},
        {dest_path: 'digspb_ssi', origin_path: 'digspb'},
        {dest_path: 'digspc_ssi', origin_path: 'digspc'},
        {dest_path: 'digspd_ssi', origin_path: 'digspd'},
        {dest_path: 'digspe_ssi', origin_path: 'digspe'},
        {dest_path: 'digspf_ssi', origin_path: 'digspf'},
        {dest_path: 'digspg_ssi', origin_path: 'digspg'},
        {dest_path: 'digsph_ssi', origin_path: 'digsph'},
        {dest_path: 'digspi_ssi', origin_path: 'digspi'},
        {dest_path: 'digspj_ssi', origin_path: 'digspj'},
        {dest_path: 'digspk_ssi', origin_path: 'digspk'},
        {dest_path: 'transcription_tesi', origin_path: 'transc', formatters: [StripFormatter]},
        {dest_path: 'translation_tesi', origin_path: 'transl', formatters: [StripFormatter]},
        {dest_path: 'fullrs_tesi', origin_path: 'fullrs', formatters: [StripFormatter]},
        {dest_path: 'find_ssi', origin_path: 'find', formatters: [StripFormatter]},
        {dest_path: 'dmaccess_ssi', origin_path: 'dmaccess', formatters: [StripFormatter]},
        {dest_path: 'dmimage_ssi', origin_path: 'dmimage', formatters: [StripFormatter]},
        {dest_path: 'dmcreated_ssi', origin_path: 'dmcreated', formatters: [StripFormatter]},
        {dest_path: 'dmmodified_ssi', origin_path: 'dmmodified', formatters: [StripFormatter]},
        {dest_path: 'dmoclcno_ssi', origin_path: 'dmoclcno', formatters: [StripFormatter]},
        {dest_path: 'restriction_code_ssi', origin_path: 'restrictionCode', formatters: [StripFormatter]},
        {dest_path: 'cdmfilesize_ssi', origin_path: 'cdmfilesize', formatters: [StripFormatter]},
        {dest_path: 'cdmfilesizeformatted_ssi', origin_path: 'cdmfilesizeformatted', formatters: [StripFormatter]},
        {dest_path: 'cdmprintpdf_is', origin_path: 'cdmprintpdf', formatters: [ToIFormatter]},
        {dest_path: 'cdmhasocr_is', origin_path: 'cdmhasocr', formatters: [ToIFormatter]},
        {dest_path: 'cdmisnewspaper_is', origin_path: 'cdmisnewspaper', formatters: [ToIFormatter]},
        {dest_path: 'image_uri_ssi', origin_path: 'image_uri', formatters: [StripFormatter]},
        {dest_path: 'record_type_ssi', origin_path: 'record_type', formatters: [StripFormatter]},
        {dest_path: 'geographic_feature_ssim', origin_path: 'geogra', formatters: [Titlieze, StripFormatter, SplitFormatter, StripFormatter]},
        {dest_path: 'geographic_feature_teim', origin_path: 'geogra', formatters: [StripFormatter]},
        {dest_path: 'geographic_feature_unstem_search', origin_path: 'geogra', formatters: [StripFormatter]},
        {dest_path: 'compound_objects_ts', origin_path: 'page', formatters: [ToJsonFormatter]},
        {dest_path: 'geonam_ssi', origin_path: 'geonam', formatters: [StripFormatter]},
        {dest_path: 'kaltura_audio_ssi', origin_path: 'audio', formatters: [StripFormatter]},
        {dest_path: 'kaltura_audio_playlist_ssi', origin_path: 'audioa', formatters: [StripFormatter]},
        {dest_path: 'kaltura_video_ssi', origin_path: 'video', formatters: [StripFormatter]},
        {dest_path: 'kaltura_video_playlist_ssi', origin_path: 'videoa', formatters: [StripFormatter]},
        {dest_path: 'coordinates_llsi', origin_path: 'geonam', formatters: [GeoNameID, GeoNameIDToJson, GeoNameToLocation]},
        {dest_path: 'placename_ssim', origin_path: 'geonam', formatters: [GeoNameID, GeoNameIDToJson, GeoNameToPlaceName]},
        {dest_path: 'placename_unstem_search', origin_path: 'geonam', formatters: [GeoNameID, GeoNameIDToJson, GeoNameToPlaceName]},
        {dest_path: 'table_ssim', origin_path: 'table', formatters: [StripFormatter, SplitFormatter, StripFormatter]},
        {dest_path: 'umedia_ssi', origin_path: 'umedia', formatters: [StripFormatter]}
      ]
    end
  end
end