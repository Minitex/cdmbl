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
      field_mappings.inject({}) do |dest_record, mapping|
        dest_record.merge(transform_field(record, mapping))
      end
    end

    private

    def transform_field(record, mapping)
      field_transformer.new(origin_path: mapping[:origin_path],
                            dest_path: mapping[:dest_path],
                            formatters: mapping[:formatters],
                            record: record).reduce
    end
    
   
  end
end