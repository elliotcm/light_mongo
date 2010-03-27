module LightMongo
  module Document
    
    module ActiveModelCompliance
      # Replace this with your own validations.
      def valid?
        true
      end
      
      def new_record?
        @_id.nil?
      end
    end
    
  end
end