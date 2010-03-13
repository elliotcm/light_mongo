require File.dirname(__FILE__) + '/../../../lib/document/serialization'

describe LightMongo::Document::Serialization::Serializer do
  before(:each) do
    @object = mock(:object)
  end
  
  describe ".serialize(object, current_depth)" do
    before(:each) do
      @depth = 0
      @serializer = LightMongo::Document::Serialization::Serializer.new(@object, @depth)
      @serializer.stub!(:hash_serialize => (@hash_serialized_object = mock(:hash_serialized_object)))
      LightMongo::Document::Serialization::Serializer.stub!(:new).with(@object, anything).and_return(@serializer)
    end

    def self.it_creates_a_new_serializer_instance
      it "creates a new serializer instance" do
        LightMongo::Document::Serialization::Serializer.should_receive(:new).with(@object, @depth).and_return(@serializer)
        LightMongo::Document::Serialization::Serializer.serialize(@object, @depth)
      end
    end
    
    def self.it_hash_serializes_the_object
      it "hash-serializes the object." do
        @serializer.should_receive(:hash_serialize)
        LightMongo::Document::Serialization::Serializer.serialize(@object, @depth)
      end
    end
    
    def self.it_returns_the_hash_serialized_object
      it "returns the hash-serialized object." do
        LightMongo::Document::Serialization::Serializer.serialize(@object, @depth).should == @hash_serialized_object
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
        LightMongo::Document::Serialization::Serializer.serialize(@object, @depth)
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
          LightMongo::Document::Serialization::Serializer.serialize(@object, @depth)
        end
        
        it "does not hash-serialize the object." do
          @serializer.should_not_receive(:hash_serialize)
          LightMongo::Document::Serialization::Serializer.serialize(@object, @depth)
        end
        
        it "returns the marshalled object." do
          @serializer.stub!(:marshal => (@marshalled_object = mock(:marshalled_object)))
          LightMongo::Document::Serialization::Serializer.serialize(@object, @depth).should == @marshalled_object
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
  
  describe "#marshal(object)" do
    it "marshals the object." do
      Marshal.should_receive(:dump).with(@object)
      LightMongo::Document::Serialization::Serializer.new(@object).marshal
    end
    
    it "returns the marshalled object." do
      Marshal.stub!(:dump).
        with(@object).
        and_return(marshalled_object = mock(:marshalled_object))
      LightMongo::Document::Serialization::Serializer.new(@object).marshal.should == marshalled_object
    end
  end

  describe "#hash_serialize(object, current_depth)" do
    before(:each) do
      @current_depth = mock(:current_depth)
    end
    
    it "serializes the object into a set of nested hashes." do
      LightMongo::Document::Serialization::HashSerializer.
        should_receive(:dump).with(@object, @current_depth)
      LightMongo::Document::Serialization::Serializer.new(@object, @current_depth).hash_serialize
    end
    
    it "returns the marshalled object." do
      LightMongo::Document::Serialization::HashSerializer.stub!(:dump).
        with(@object, @current_depth).
        and_return(hashed_object = mock(:hashed_object))
      LightMongo::Document::Serialization::Serializer.new(@object, @current_depth).hash_serialize.should == hashed_object
    end
  end
end
