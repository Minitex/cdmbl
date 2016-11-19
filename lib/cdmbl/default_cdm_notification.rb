module CDMBL
  # An example callback
  class DefaultCdmNotification
    def self.call!(collection, id, endpoint)
      puts "A CONTENTdm API request notification: #{endpoint} #{collection}:#{id}"
    end
  end
end