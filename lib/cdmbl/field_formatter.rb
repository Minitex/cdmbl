module CDMBL
  class FieldFormatter
    attr_reader :value, :formatters
    def initialize(value: {}, formatters: [DefaultFormatter])
      @value      = value
      @formatters = formatters
    end

    def format!
      formatters.reduce(value) { |memo, formatter| formatter.format(memo) }
    end
  end

end