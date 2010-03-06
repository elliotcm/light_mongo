require 'rubygems'
require 'mongo'

require "document/serialization"
require "document/repository"

module LightMongo
  module Document
    include Serialization
    include Repository
  end
end