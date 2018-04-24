module CDMBL
  # Search an OAI ListSets field using a regular expression
  class RegexFilterCallback
    attr_reader :field, :pattern, :inclusive
    def initialize(field: 'setName', pattern: /.*/, inclusive: true)
      @field     = field
      @pattern   = pattern
      @inclusive = inclusive
    end

    def valid?(set: {})
      inclusive ? matches?(set) : !matches?(set)
    end

    def matches?(set)
      pattern.match?(set[field])
    end
  end
end
