require 'json'
require 'titleize'

module CDMBL
  class Transformer
    attr_reader :cdm_records,
                :oai_sets,
                :field_mappings,
                :extract_compounds,
                :record_transformer
    def initialize(cdm_records: [],
                   oai_sets: {},
                   field_mappings: false,
                   extract_compounds: false,
                   record_transformer: RecordTransformer)
      @cdm_records = cdm_records.map do |record|
        record.merge('record_type' => 'primary')
      end
      @oai_sets           = oai_sets
      @field_mappings     = field_mappings
      @extract_compounds  = extract_compounds
      @record_transformer = record_transformer
    end

    def records
      raw_records.map { |record| to_solr(record) }.compact
    end

    private

    def raw_records
      extract_compounds == false ? cdm_records : cdm_records.concat(compounds)
    end

    # The 'page' key holds the children of a given record
    def compounds
      # Get all the records with compounds
      cdm_records.reject do |record|
        record['page'].nil?
        # Get just the compound data
      end.map do |record|
        record['page'].map do |page|
          # Associate each compound child with its parent
          page.merge!('parent_id' => record['id'], 'record_type' => 'secondary')
        end
      end.flatten
    end

    def mappings
      field_mappings.map { |config| FieldMapping.new(config: config) }
    end

    def to_solr(record)
      # Remove empty records (move this behavior to the CONTENTdm API gem) and
      # bail early on the transformation process
      if {'id' => record['id']} == record
        return nil
      else
        record_transformer.new(record: record.merge('oai_sets' => oai_sets),
                               field_mappings: mappings).transform!
      end
    end
  end
end