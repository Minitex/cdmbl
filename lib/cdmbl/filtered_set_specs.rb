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
                   callback: DefaultSetFilterCallback.new)
      @oai_base_url = oai_base_url
      @oai_client   = oai_client
      @callback     = callback
    end

    def set_specs
      filtered.map {|set| set['setSpec']}
    end

    private

    def filtered
      sets.select do |set|
        callback.valid?(set: set)
      end
    end

    def sets
      @sets ||= list_sets['OAI_PMH']['ListSets']['set']
    end

    def list_sets
      @list_sets ||= oai_client.new(base_url: oai_base_url).request('verb=ListSets')
    end
  end
end