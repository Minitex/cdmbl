module CDMBL
  # This class has been named in a way that makes it hard to pronounce
  class OAIFilter
    attr_reader :headers
    def initialize(headers: [])
      @headers = headers
    end

    def updatables
      headers.reject { |record| record['status'] == 'deleted' }
    end

    def deletables
      headers.select { |record| record['status'] == 'deleted' }
    end
  end
end