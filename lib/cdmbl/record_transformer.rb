module CDMBL
  class RecordTransformer
    attr_reader :record, :field_mappings, :field_transformer
    def initialize(record: {},
                   field_mappings: [],
                   field_transformer: FieldTransformer)
      @record            = record
      @field_mappings    = field_mappings
      @field_transformer = field_transformer
    end

    def transform!
      field_mappings.inject({}) do |dest_record, field_mapping|
        dest_record.merge(transform_field(record, field_mapping))
      end
    end

    private

    def transform_field(record, field_mapping)
      field_transformer.new(field_mapping: field_mapping,
                            record: record).reduce
    end
  end
end
