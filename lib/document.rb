require 'rubygems'
require 'mongo'

require "document/serialization"
require "document/persistence"

module LightMongo
  module Document
    include Serialization

    def self.included(klass)
      klass.class_eval("
        include Persistence
      ")
    end
  end
end