# Pulled with vigour from Rails 2.3.5
# and rewritten to be carbon neutral.
module LightMongo
  class Util
    def self.blank?(object)
      return true if object.is_a? NilClass
      return true if object.is_a? FalseClass
      return false if object.is_a? TrueClass
      return object.empty? if object.is_a? Array
      return object.empty? if object.is_a? Hash
      return object !~ /\S/ if object.is_a? String
      return false if object.is_a? Numeric
      return respond_to?(:empty?) ? empty? : !self
    end
    
    def self.present?(object)
      !blank?(object)
    end
  end
end
