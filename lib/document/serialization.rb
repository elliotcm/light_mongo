require File.dirname(__FILE__) + '/serialization/serializer'

module LightMongo
  def self.slow_serialization=(boolean)
    @@slow_serialization = boolean
  end
  
  def self.slow_serialization
    @@slow_serialization = nil unless defined?(@@slow_serialization)
    @@slow_serialization ||= false
  end

  def self.marshal_depth=(depth)
    @@marshal_depth = depth
  end
  
  def self.marshal_depth
    @@marshal_depth = nil unless defined?(@@marshal_depth)
    @@marshal_depth ||= 3
  end
  
  module Document
    module Serialization
      class <<self
        def from_hash(hash, object)
          hash.each_pair do |attribute_key, attribute_value|
            if attribute_value.is_a?(Hash) and attribute_value.has_key?('_class_name')
              if attribute_value.has_key?('_data')
                attribute_value = Marshal.load(attribute_value['_data'])
              else
                embedded_hash = attribute_value
                klass = embedded_hash.delete('_class_name')
                attribute_value = from_hash(embedded_hash, Kernel.const_get(klass).new)
              end
            end

            object.instance_variable_set('@'+attribute_key.to_s, attribute_value)
          end
      
          return object
        end
      
        def recursively_hash_object(object)
          # LightMongo::Document
          return object.export if persistable?(object)
        end
      end
      
      def initialize(params={})
        self.from_hash(params)
      end

      def to_hash(current_depth=0)
        Serializer.serialize(self, current_depth)
      end

      def from_hash(hash)
        Serialization.from_hash(hash, self)
      end
      
      def export
        return self unless self.class.include?(LightMongo::Document::Persistence)
        self.save
        {'_class_name' => self.class.name, '_id' => self.id}
      end
    end
  end
end