module LightMongo
  module Document
    module Serialization
      class HashSerializer
        def self.dump(object_to_serialize, current_depth=0)
          object_to_serialize.map do |entry|
            Serializer.serialize(entry, current_depth + 1)
          end
        end
      end
    end
  end
end