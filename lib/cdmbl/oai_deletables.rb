require 'sidekiq'
module CDMBL
  class OaiDeletables
    attr_reader :identifiers, :oai_record_klass, :oai_client, :prefix
    def initialize(identifiers: [],
                   prefix: '',
                   oai_client: OaiClient.new,
                   oai_record_klass: OaiGetRecord)
      @identifiers       = identifiers
      @prefix            = prefix
      @oai_client        = oai_client
      @oai_record_klass  = oai_record_klass
    end

    def deletables
      identifiers.select do |id|
        record_missing? to_oai_id(id)
      end
    end

    private

    def to_oai_id(id)
      "#{prefix}#{collection(id)}/#{id(id)}"
    end

    def id(id)
      id_parts(id).last
    end

    def collection(id)
      id_parts(id).first
    end

    def id_parts(id)
      id.split(':')
    end

    def record_missing?(identifier)
      !oai_record_klass.new(oai_client: oai_client,
                           identifier: identifier).record_exists?
    end
  end
end