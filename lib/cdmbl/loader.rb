module CDMBL
  class Loader
    attr_reader :solr_client, :records, :deletable_ids

    def initialize(records: [],
                   deletable_ids: [],
                   solr_client: CDMBL::Solr)
      @solr_client   = solr_client
      @records       = records
      @deletable_ids = deletable_ids
    end

    def load!
      solr_client.delete deletable_ids unless deletable_ids.empty?
      solr_client.add records
    end
  end
end
