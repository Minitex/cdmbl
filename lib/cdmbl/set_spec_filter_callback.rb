module CDMBL
  class SetSpecFilterCallback
    attr_reader :pattern, :inclusive
    def initialize(pattern: /.*/, inclusive: true)
      @pattern   = pattern
      @inclusive = inclusive
    end

    def valid?(set: {})
      (inclusive) ? matches?(set) : !matches?(set)
    end

    def matches?(set)
      pattern.match?(set['setSpec'])
    end
  end
end