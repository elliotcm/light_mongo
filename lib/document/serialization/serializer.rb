module LightMongo
  module Document
    module Serialization
      class Serializer
        attr_accessor :depth
        
        def self.serialize(object_to_serialize, depth=0)
          serializer = Serializer.new(object_to_serialize, depth)
          return serializer.hash_serialize if LightMongo.slow_serialization or depth < LightMongo.marshal_depth
          serializer.marshal
        end
        
        def initialize(object_to_serialize, depth=0)
          @object_to_serialize = object_to_serialize
          @depth = depth
        end
        
        def marshal
          Marshal.dump(@object_to_serialize)
        end

        def hash_serialize
          
        end
      end
    end
  end
end