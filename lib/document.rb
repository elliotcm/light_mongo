require 'rubygems'
require 'mongo'

module LightMongo
  module Document
    def initialize(params={})
      self.from_hash(params) if params.is_a?(Hash)
      self.from_bson(params) if params.is_a?(ByteBuffer)
    end
    
    def to_bson
      BSON.serialize(self.to_hash)
    end
    
    def to_hash
      attr_hash = {}
      instance_variables.each do |_attribute|
        attr_hash[_attribute.sub(/^@/, '')] = self.instance_variable_get(_attribute)
      end
      attr_hash
    end
    
    def from_bson(bson)
      bson_hash = BSON.deserialize(bson)
      self.from_hash(bson_hash)
    end
    
    def from_hash(hash)
      hash.each_pair do |_attribute, _value|
        self.instance_variable_set('@'+_attribute.to_s, _value)
      end
    end
  end
end