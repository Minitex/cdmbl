module CDMBL
  module DefaultFilterSetCallback
    def valid?(set: {})
      true
    end
  end

  class FilteredSetSpecs
    attr_reader :oai_base_url,
                :oai_client,
                :callback

    def initialize(oai_base_url: :missing_oai_base_url,
                   oai_client: OaiClient,
                   callback: CDMBL::DefaultSetFilterCallback.new)
      @oai_base_url = oai_base_url
      @oai_client   = oai_client
      @callback     = callback
    end

    def set_specs
      filtered_sets.map { |set| set['setSpec'] }
    end

    def filtered_sets
      @filtered_sets ||= sets.select do |set|
        callback.valid?(set: set)
      end
    end

    private

    def sets
      @sets ||= list_sets['OAI_PMH']['ListSets']['set']
    end

    def list_sets
      @list_sets ||= oai_client.new(base_url: oai_base_url).request('verb=ListSets')
    end
  end
end