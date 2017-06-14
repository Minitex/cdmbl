module CDMBL
  # This class has been named in a way that makes it hard to pronounce
  class OAIFilter
    attr_reader :headers
    def initialize(headers: [])
      @headers = headers
    end

    def updatable_ids
      get_ids(find_mutatables_by { |id| id['status'] != 'deleted' })
    end

    def deletable_ids
      deletables.map { |deletable| deletable.join('/')}
    end

    private

    def deletables
      get_ids(find_mutatables_by { |id| id['status'] == 'deleted' })
    end

    def mutatables
      @mutables ||= headers.map do |header|
        header.merge(ids: extract_identifiers(header['identifier']))
      end.compact
    end

    # Get the local collection and id from an OAI namespaced identifier
    # e.g. oai:reflections.mndigital.org:p16022coll44/3
    def extract_identifiers(identifier)
      identifier.split(':').last.split('/')
    end

    def get_ids(header_items)
      header_items.map { |header| header[:ids] }
    end

    def find_mutatables_by
      mutatables.find_all { |id| yield(id) }
    end

  end
end