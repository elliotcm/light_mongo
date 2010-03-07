require 'rubygems'
require 'mongo'

def require_document(lib)
  require File.dirname(__FILE__) + "/document/" + lib
end

require_document 'serialization'
require_document 'persistence'

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