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
      @@collection = nil
      def self.included(document_class)
        @@collection ||= Mongo::Collection.new(LightMongo.database, document_class.name)
      end
    end
  end
end
