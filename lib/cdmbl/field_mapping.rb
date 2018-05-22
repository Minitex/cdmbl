module CDMBL
  class FieldMapping
    attr_reader :config
    def initialize(config: {})
      @config = symbolize(config)
    end

    def origin_path
      config.fetch(:origin_path)
    end

    def dest_path
      config.fetch(:dest_path)
    end

    def formatters
      config.fetch(:formatters, [DefaultFormatter]).map do |formatter|
        formatter.is_a?(String) ? Object.const_get(formatter) : formatter
      end
    end

    private

    def symbolize(config)
      config.inject({}) { |memo, (k, v)| memo[k.to_sym] = v; memo }
    end
  end
end