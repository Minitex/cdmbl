module CDMBL
  # An example callback
  class DefaultCallback
    def self.call!(solr_client)
      puts "A callback task"
    end
  end
end