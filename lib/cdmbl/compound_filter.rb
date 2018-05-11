module CDMBL
  # Takes a list of record id/collection data, uses CompoundLookup to
  # identifiy records with large numbers of compounds and sorts them
  # into a large and a small heap
  class CompoundFilter
    attr_reader :record_ids,
                :max_compounds,
                :cdm_endpoint,
                :compound_lookup_klass
    def initialize(record_ids: [],
                   max_compounds: 10,
                   cdm_endpoint: '',
                   compound_lookup_klass: CompoundLookup)
      @record_ids            = record_ids
      @max_compounds         = max_compounds
      @cdm_endpoint          = cdm_endpoint
      @compound_lookup_klass = compound_lookup_klass
    end

    def filter(large: true)
      ids(records.select { |record| record[:large] == large })
    end

    private

    def ids(records)
      records.map { |record| record[:id] }
    end

    def records
      @records ||= record_ids.map do |identifier|
        {
          large: count(*identifier) >= max_compounds,
          id: identifier
        }
      end
    end

    def count(collection, id)
      compound_lookup_klass.new(cdm_endpoint: cdm_endpoint,
                                collection: collection,
                                id: id).count
    end
  end
end
