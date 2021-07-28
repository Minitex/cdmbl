module CDMBL
  class OaiDeletables
    attr_reader :identifiers, :oai_record_klass, :oai_url, :prefix

    def initialize(identifiers: [],
                   prefix: '',
                   oai_url:,
                   oai_record_klass: OaiGetRecord)
      @identifiers      = identifiers
      @prefix           = prefix
      @oai_url          = oai_url
      @oai_record_klass = oai_record_klass
    end

    def deletables
      OaiClient.persistent(oai_url) do |oai_client|
        identifiers.select do |id|
          !oai_record_klass.new(
            oai_client: oai_client,
            identifier: to_oai_id(id)
          ).record_exists?
        end
      end
    end

    private

    def to_oai_id(id)
      collection, id = id.split(':')
      "#{prefix}#{collection}/#{id}"
    end
  end
end
