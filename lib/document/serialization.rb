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
              klass_name = _attribute_value.class.name
              _attribute_value = to_hash(_attribute_value)
              _attribute_value['_class_name'] = klass_name
            end
        
            attr_hash[_attribute_key] = _attribute_value
          end
          return attr_hash
        end
      
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
    end
  end
end