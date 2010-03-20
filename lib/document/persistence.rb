module LightMongo
  # Connection and database getters/setters hoofed from jnunemaker's MongoMapper
  def self.connection
    @@connection ||= Mongo::Connection.new
  end

  def self.connection=(new_connection)
    @@connection = new_connection
  end
  
  def self.database=(name)
    @@database = nil
    @@database_name = name
  end
 
  def self.database
    unless defined?(@@database_name) and !Util.blank?(@@database_name)
      raise 'You forgot to set the default database name: LightMongo.database = "foobar"'
    end
 
    @@database ||= LightMongo.connection.db(@@database_name)
  end
  
  module Document
    module Persistence
      def self.included(document_class)
        document_class.extend ClassMethods
        document_class.collection = Mongo::Collection.new(LightMongo.database, document_class.name)
      end
      
      def collection
        self.class.collection
      end
      
      def save
        @_id = collection.save(self.to_hash)
      end
      
      def id
        @_id
      end
      
      def ==(other)
        self.id == other.id
      end

      
      module ClassMethods
        attr_accessor :collection

        def create(params)
          new_object = new(params)
          new_object.save
          return new_object
        end
        
        def index(key_name, options={})
          return if Util.blank?(key_name)
          
          method_name = 'find_by_'+(options[:as] or key_name).to_s
          if viable_method_name(method_name)
            (class << self; self; end).class_eval do
              define_method method_name.to_sym do |value|
                collection.find(key_name.to_sym => value).map{|bson_hash| new(bson_hash)}
              end
            end
          end
          
          collection.create_index(key_name)
        end
        
        def find(query=nil)
          query = {'_id' => query} unless query.nil? or query.is_a?(Hash)
          collection.find(query).map{|bson_hash| new(bson_hash)}
        end
        
        def viable_method_name(method_name)
          method_name =~ /^\w+[!?]?$/
        end
      end
      
    end
  end
end
