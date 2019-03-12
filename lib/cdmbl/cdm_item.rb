module CDMBL
  class CdmItem
    attr_reader :cdm_endpoint,
                :record,
                :collection,
                :id,
                :cdm_api_klass,
                :cdm_notification_klass

    def initialize(record: :MISSING_RECORD,
                   cdm_endpoint: :MISSING_ENDPOINT,
                   cdm_api_klass: CONTENTdmAPI::Item,
                   cdm_notification_klass: CDMBL::CdmNotification)
      @record                 = record
      @collection, @id        = record['id'].split(':')
      @cdm_endpoint           = cdm_endpoint
      @cdm_api_klass          = cdm_api_klass
      @cdm_notification_klass = cdm_notification_klass
    end

    def to_h
      @to_h ||= metadata.merge 'page' => page
    end

    private

    def page
      metadata.fetch('page', [])
              .each_with_index.map { |page, i| to_compound(page, i) }
    end

    def to_compound(page, i)
      page.merge!(
        # Child id is a combo of the page id and parent collection
        'id' => "#{collection}:#{page['pageptr']}",
        'parent_id' => record['id'],
        'record_type' => 'secondary',
        'child_index' => i
      )
    end

    def metadata
      cdm_notification_klass.call!(collection, id, cdm_endpoint)

      @metadata ||= cdm_api_klass.new(base_url: cdm_endpoint,
                                      collection: collection,
                                      id: id).metadata
                                 .merge('record_type' => 'primary')
    end
  end
end