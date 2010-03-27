require 'rubygems'
require 'active_model/naming'

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
      
      def self.included(doc_class)
        doc_class.extend ActiveModel::Naming
      end
    end
    
  end
end