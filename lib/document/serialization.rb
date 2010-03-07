module LightMongo
  module Document
    module Serialization
      class <<self
        def from_hash(hash, object)
          hash.each_pair do |attribute_key, attribute_value|
            if attribute_value.is_a?(Hash) and attribute_value.has_key?('_class_name')
              embedded_hash = attribute_value
              klass = embedded_hash.delete('_class_name')
              attribute_value = from_hash(embedded_hash, Kernel.const_get(klass).new)
            end

            object.instance_variable_set('@'+attribute_key.to_s, attribute_value)
          end
      
          return object
        end
        
        def to_hash(object)
          recursively_hashed_object = {}
          object.instance_variables.each do |attribute_name|
            new_hash_key = attribute_name.sub(/^@/, '')
            nested_object = object.instance_variable_get(attribute_name)
            recursively_hashed_object[new_hash_key] = recursively_hash_object(nested_object)
          end
          return recursively_hashed_object
        end
      
        def recursively_hash_object(object)
          # LightMongo::Document
          return object.export if persistable?(object)
          
          # Array
          if object.is_a?(Array)
            return object.map do |entry|
              recursively_hash_object(entry)
            end
          end
          
          # Other non-native object
          begin
            raise_unless_natively_embeddable(object)
          rescue Mongo::InvalidDocument => e
            klass_name = object.class.name
            hashed_object = to_hash(object)
            hashed_object['_class_name'] = klass_name
          end
          
          # We're left with a clean object or our
          # (presumably native) original object.
          return hashed_object || object
        end
        
        def raise_unless_natively_embeddable(object)
          BSON_RUBY.new.bson_type(object)
        end
        
        def persistable?(object)
          object.is_a?(LightMongo::Document) and object.respond_to?(:save)
        end
      end
      
      def initialize(params={})
        self.from_hash(params)
      end

      def to_hash
        Serialization.to_hash(self)
      end

      def from_hash(hash)
        Serialization.from_hash(hash, self)
      end
      
      def export
        return self unless self.class.include?(LightMongo::Document::Persistence)
        _id = self.save
        {'_class_name' => self.class.name, '_id' => _id}
      end
    end
  end
end