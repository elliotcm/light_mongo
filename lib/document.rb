require 'rubygems'
require 'mongo'

require "document/serialization"
require "document/persistence"

module LightMongo
  module Document
    include Serialization
    include Persistence
  end
end