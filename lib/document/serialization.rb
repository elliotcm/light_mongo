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
      def initialize(params={})
        self.from_hash(params)
      end

      def to_hash(current_depth=0)
        Serializer.serialize(self, current_depth)
      end

      def from_hash(hash)
        Serializer.deserialize(hash).each_pair do |attr_name, attr_value|
          self.instance_variable_set '@'+attr_name.to_s, attr_value
        end
      end
      
      def export
        return self unless self.class.include?(LightMongo::Document::Persistence)
        self.save
        {'_class_name' => self.class.name, '_id' => self.id, '_embed' => true}
      end
    end
  end
end