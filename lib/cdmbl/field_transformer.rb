require 'hash_at_path'

module CDMBL
  class FieldTransformer
    attr_reader :field_value, :dest_path, :formatters, :formatter_klass
    def initialize(origin_path: '',
                   dest_path: '',
                   record: {},
                   formatters: [],
                   formatter_klass: FieldFormatter)
      @field_value     = compact(record.at_path(origin_path))
      @dest_path       = dest_path
      @formatters      = (!formatters.nil?) ? formatters : [DefaultFormatter]
      @formatter_klass = formatter_klass
    end

    def reduce
      (blank?(value)) ? {} : { "#{dest_path}" => value } 
    end

    def value
      @value ||= (!blank?(field_value)) ? transform_field : nil
    end

    private

    def compact(record)
      (record.respond_to?(:compact)) ? record.compact : record
    end

    # File activesupport/lib/active_support/core_ext/object/blank.rb, line 14
    def blank?(val)
      val.respond_to?(:empty?) ? !!val.empty? : !val
    end

    def transform_field
      formatter_klass.new(value: field_value, formatters: formatters).format!
    end
  end
end