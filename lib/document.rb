require 'rubygems'
require 'mongo'

module LightMongo
  module Document
    def initialize(params={})
      self.from_hash(params) if params.is_a?(Hash)
      self.from_bson(params) if params.is_a?(ByteBuffer)
    end
    
    def to_bson
      @_class_name = self.class.name
      BSON.serialize(self.to_hash)
    end
    
    def to_hash
      attr_hash = {}
      instance_variables.each do |_attribute|
        _attribute_key = _attribute.sub(/^@/, '')
        _attribute_value = self.instance_variable_get(_attribute)
        
        begin
          BSON_RUBY.new.bson_type(_attribute_value)
        rescue Mongo::InvalidDocument => e
          _attribute_value.extend(LightMongo::Document)
          _attribute_value = _attribute_value.to_bson
        end
        
        attr_hash[_attribute_key] = _attribute_value
      end
      return attr_hash
    end

    def from_bson(bson)
      self.from_hash(BSON.deserialize(bson))
    end
    
    def from_hash(hash, klass=nil)
      obj = (klass.nil? ? self : Kernel.const_get(klass).new)

      hash.each_pair do |attribute_key, attribute_value|
        if attribute_value.is_a?(ByteBuffer)
          deserialized_hash = BSON.deserialize(attribute_value)
          klass = deserialized_hash.delete('_class_name')
          attribute_value = from_hash(deserialized_hash, klass)
        end

        obj.instance_variable_set('@'+attribute_key.to_s, attribute_value)
      end
      
      return obj
    end
  end
end