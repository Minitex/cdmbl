module CDMBL
  # An example callback
  class DefaultCompletedCallback
    def self.call!(*)
      puts "A callback task"
    end
  end
end
