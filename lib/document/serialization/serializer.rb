require File.dirname(__FILE__) + '/hash_serializer'

module LightMongo
  module Document
    module Serialization
      class Serializer
        attr_accessor :depth
        
        class <<self
          def deserialize(object_to_deserialize)
            return array_deserialize(object_to_deserialize) if object_to_deserialize.is_a?(Array)
            if object_to_deserialize.is_a?(Hash)
              if object_to_deserialize.has_key?('_data')
                return Marshal.load(object_to_deserialize['_data'])
              end

              if object_to_deserialize.has_key?('_class_name')
                class_name = object_to_deserialize.delete('_class_name')

                if !object_to_deserialize.has_key?('_id')
                  object = Object.const_get(class_name).new
                  object_to_deserialize.each_pair do |attr_name, attr_value|
                    object.instance_variable_set '@'+attr_name, attr_value
                  end
                  
                  return object
                end

                if object_to_deserialize.has_key?('_embed') and object_to_deserialize['_embed'] == true
                  return Object.const_get(class_name).find(object_to_deserialize['_id']).first
                end
              end
              
              return hash_deserialize(object_to_deserialize)
            end
            
            return object_to_deserialize
          end
        
          def serialize(object_to_serialize, depth=0)
            serializer = Serializer.new(object_to_serialize, depth)
            return serializer.hash_serialize if LightMongo.slow_serialization or depth < LightMongo.marshal_depth
            serializer.marshal
          end
          
          def array_deserialize(array)
            array.map do |entry|
              deserialize(entry)
            end
          end
          
          def hash_deserialize(hash)
            deserialized_hash = {}
            hash.each_pair do |key, value|
              deserialized_hash[key] = deserialize(value)
            end
            return deserialized_hash
          end
        end
        
        def initialize(object_to_serialize, depth=0)
          @object_to_serialize = object_to_serialize
          @depth = depth
        end
        
        def marshal
          {'_data' => Marshal.dump(@object_to_serialize)}
        end

        def hash_serialize
          HashSerializer.dump(@object_to_serialize, @depth)
        end
      end
    end
  end
end