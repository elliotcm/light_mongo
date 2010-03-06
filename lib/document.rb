require 'rubygems'
require 'mongo'

require 'document/serialization'

module LightMongo
  module Document
    include Serialization
  end
end