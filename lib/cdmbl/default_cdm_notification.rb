module CDMBL
  # An example callback
  class DefaultCdmNotification
    def self.call!(collection, id, endpoint)
      puts "A CCONTENTdm API request notification"
    end
  end
end