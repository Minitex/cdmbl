module CDMBL
  # An example callback
  class DefaultLoaderNotification
    def self.call!(ingestables, deletables)
      puts "A CONTENTdm API request notification: Loading #{ingestables.length} records and deleting #{deletables.length}"
    end
  end
end