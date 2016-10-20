module CDMBL
  # An example callback
  class DefaultOaiNotification
    def self.call!(solr_client)
      puts "An OAI callback task"
    end
  end
end