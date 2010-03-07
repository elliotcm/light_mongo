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
    unless defined?(@@database_name) and !@@database_name.blank?
      raise 'You forgot to set the default database name: LightMongo.database = "foobar"'
    end
 
    @@database ||= LightMongo.connection.db(@@database_name)
  end
  
  module Document
    module Persistence
      def self.included(document_class)
        document_class.class_eval("extend ClassMethods")
        document_class.collection = Mongo::Collection.new(LightMongo.database, document_class.name)
      end
      
      module ClassMethods
        def collection=(collection)
          @@collection = collection
        end
      
        def collection
          @@collection
        end
        
        def index(hash)
          key_name = hash[:key]
          return if key_name.blank?
          
          method_name = 'find_by_'+(hash[:name] or key_name).to_s
          if viable_method_name(method_name)
            (class << self; self; end).class_eval %{
              def #{method_name}(value)
                collection.find(:#{key_name} => value).map{|bson_hash| new(bson_hash)}
              end
            }
          end
          
          collection.create_index(key_name)
        end
        
        def viable_method_name(method_name)
          method_name =~ /^\w+[!?]?$/
        end
      end
      
      def collection
        self.class.collection
      end
      
      def save
        collection.save(self.to_hash)
      end
      
      def id
        @_id
      end
    end
  end
end
