module LightMongo
  module Document
    
    module ActiveModelCompliance
      # Replace this with your own validations.
      def valid?
        true
      end
    end
    
  end
end