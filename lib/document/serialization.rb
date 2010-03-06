module LightMongo
  module Document
    module Serialization
      class <<self
        def to_hash(object)
          attr_hash = {}
          object.instance_variables.each do |_attribute|
            _attribute_key = _attribute.sub(/^@/, '')
            _attribute_value = object.instance_variable_get(_attribute)
        
            begin
              BSON_RUBY.new.bson_type(_attribute_value)
            rescue Mongo::InvalidDocument => e
              _attribute_value = to_bson(_attribute_value)
            end
        
            attr_hash[_attribute_key] = _attribute_value
          end
          return attr_hash
        end
      
        def from_hash(hash, object)
          hash.each_pair do |attribute_key, attribute_value|
            if attribute_value.is_a?(ByteBuffer)
              deserialized_hash = BSON.deserialize(attribute_value)
              klass = deserialized_hash.delete('_class_name')
              attribute_value = from_hash(deserialized_hash, Kernel.const_get(klass).new)
            end

            object.instance_variable_set('@'+attribute_key.to_s, attribute_value)
          end
      
          return object
        end

        def to_bson(object)
          object.instance_variable_set('@_class_name', object.class.name) unless object.class.include?(LightMongo::Document)
          BSON.serialize(to_hash(object))
        end
    

        def from_bson(bson, object)
          from_hash(BSON.deserialize(bson), object)
        end

      end
      
      def initialize(params={})
        self.from_hash(params) if params.is_a?(Hash)
        self.from_bson(params) if params.is_a?(ByteBuffer)
      end

      def to_hash
        Serialization.to_hash(self)
      end
      
      def to_bson
        Serialization.to_bson(self)
      end
      
      def from_hash(hash)
        Serialization.from_hash(hash, self)
      end
      
      def from_bson(bson)
        Serialization.from_bson(bson, self)
      end
    end
  end
end