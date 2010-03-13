require File.dirname(__FILE__) + '/../../../lib/light_mongo'

Serializer = LightMongo::Document::Serialization::Serializer

describe Serializer do
  before(:each) do
    @depth = 0
    @serializer = Serializer.new(@object = mock(:object), @depth)
    @serializer.stub!(:hash_serialize => (@hash_serialized_object = mock(:hash_serialized_object)))
    Serializer.stub!(:new).with(@object, anything).and_return(@serializer)
  end

  describe ".serialize(object)" do
    def self.it_creates_a_new_serializer_instance
      it "creates a new serializer instance" do
        Serializer.should_receive(:new).with(@object, @depth).and_return(@serializer)
        Serializer.serialize(@object, @depth)
      end
    end
    
    def self.it_hash_serializes_the_object
      it "hash-serializes the object." do
        @serializer.should_receive(:hash_serialize)
        Serializer.serialize(@object, @depth)
      end
    end
    
    def self.it_returns_the_hash_serialized_object
      it "returns the hash-serialized object." do
        Serializer.serialize(@object, @depth).should == @hash_serialized_object
      end
    end
    
    context "when above the marshalling depth threshold" do
      before(:each) do
        @depth = 1
      end
      
      it_creates_a_new_serializer_instance
      
      it_hash_serializes_the_object
      
      it "does not marshal the object." do
        @serializer.should_not_receive(:marshal)
        Serializer.serialize(@object, @depth)
      end
      
      it_returns_the_hash_serialized_object
    end
    
    context "when below the marshalling depth threshold" do
      before(:each) do
        @depth = 5
      end
      
      context "and marshalling is turned on" do
        before(:each) do
          LightMongo.slow_serialization = false
        end
        
        it_creates_a_new_serializer_instance
        
        it "marshals the object." do
          @serializer.should_receive(:marshal)
          Serializer.serialize(@object, @depth)
        end
        
        it "does not hash-serialize the object." do
          @serializer.should_not_receive(:hash_serialize)
          Serializer.serialize(@object, @depth)
        end
        
        it "returns the marshalled object." do
          @serializer.stub!(:marshal => (@marshalled_object = mock(:marshalled_object)))
          Serializer.serialize(@object, @depth).should == @marshalled_object
        end
      end
      
      context "but marshalling is turned off" do
        before(:each) do
          LightMongo.slow_serialization = true
        end

        it_creates_a_new_serializer_instance
        
        it_hash_serializes_the_object
        
        it_returns_the_hash_serialized_object
      end
    end
  end
end
