require 'mongo'

module LightMongo
  module Document
    module Serialization
      
      class HashSerializer
        class <<self
          def dump(object_to_serialize, current_depth=0)
            case object_to_serialize
            when Array
              return serialize_array(object_to_serialize, current_depth)
            when Hash
              return serialize_hash(object_to_serialize, current_depth)
            else
              return serialize_object(object_to_serialize, current_depth)
            end
          end
        
          private
          def serialize_array(object_to_serialize, current_depth)
            object_to_serialize.map do |entry|
              Serializer.serialize(entry, current_depth + 1)
            end
          end

          def serialize_hash(object_to_serialize, current_depth)
            outbound_hash = {}
            object_to_serialize.each_pair do |key, entry|
              outbound_hash[key] = Serializer.serialize(entry, current_depth + 1)
            end
            outbound_hash
          end
          
          def serialize_object(object_to_serialize, current_depth)
            return object_to_serialize if natively_embeddable?(object_to_serialize)

            return object_to_serialize.export if object_to_serialize.is_a? LightMongo::Document and current_depth > 0
              

            return hashify(object_to_serialize, current_depth)
          end
          
          def hashify(object_to_serialize, current_depth)
            hashed_object = {'_class_name' => object_to_serialize.class.name}
            
            object_to_serialize.instance_variables.each do |attribute_name|
              new_hash_key = attribute_name.sub(/^@/, '')
              nested_object = object_to_serialize.instance_variable_get(attribute_name)
              hashed_object[new_hash_key] = Serializer.serialize(nested_object, current_depth + 1)
            end
            
            return hashed_object
          end
          
          def natively_embeddable?(object)
            begin
              raise_unless_natively_embeddable(object)
            rescue Mongo::InvalidDocument => e
              return false
            end
            
            return true
          end
          
          def raise_unless_natively_embeddable(object)
            BSON_RUBY.new.bson_type(object)
          end

        end
      end
      
    end
  end
end