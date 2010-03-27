module LightMongo
  module Document
    
    module ActiveModelCompliance
      # Replace this with your own validations.
      def valid?
        true
      end

      # There is currently no useful difference
      # between a new record and a destroyed record.
      # 
      # As such, these methods are essentially synonymous.
      def new_record?
        @_id.nil?
      end

      def destroyed?
        @_id.nil?
      end
    end
    
  end
end