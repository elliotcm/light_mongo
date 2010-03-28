require File.dirname(__FILE__) + '/../../../lib/document/serialization'

Serializer = LightMongo::Document::Serialization::Serializer

describe Serializer do
  before(:each) do
    @object = mock(:object)
  end
  
  describe ".array_deserialize(object)" do
    before(:each) do
      @object = [
        @ivar1 = mock(:ivar1),
        @ivar2 = mock(:ivar2)
      ]
    end

    it "map-deserializes each element in the array" do
      Serializer.should_receive(:deserialize).with(@ivar1).
        and_return(desel_ivar1 = mock(:desel_ivar1))
        
      Serializer.should_receive(:deserialize).with(@ivar2).
        and_return(desel_ivar2 = mock(:desel_ivar2))
        
      Serializer.send(:array_deserialize, @object).
        should == [desel_ivar1, desel_ivar2]
    end
  end
  
  describe ".hash_deserialize(object)" do
    before(:each) do
      @object = {
        :ivar1 => (@ivar1 = mock(:ivar1)),
        :ivar2 => (@ivar2 = mock(:ivar2))
      }
    end

    it "map-deserializes each element in the hash" do
      Serializer.should_receive(:deserialize).with(@ivar1).
        and_return(desel_ivar1 = mock(:desel_ivar1))
        
      Serializer.should_receive(:deserialize).with(@ivar2).
        and_return(desel_ivar2 = mock(:desel_ivar2))

      Serializer.send(:hash_deserialize, @object).
        should == {:ivar1 => desel_ivar1, :ivar2 => desel_ivar2}
    end
  end
  
  describe ".deserialize(object)" do
    context "when the object is an array" do
      before(:each) do
        @object = []
      end
      
      it "deserializes the array" do
        Serializer.should_receive(:array_deserialize).with(@object).
          and_return(desel_array = mock(:desel_array))
          
        Serializer.deserialize(@object).should == desel_array
      end
    end
    
    context "when the object is a hash" do
      before(:each) do
        @object = {}
      end
      
      context "and nothing more" do
        it "deserializes the hash" do
          Serializer.should_receive(:hash_deserialize).with(@object)
          Serializer.deserialize(@object)
        end
      end
      
      context "and a Marshal dump" do
        before(:each) do
          @marshal_dump = mock(:marshal_dump)
          @object['_data'] = @marshal_dump
        end
        
        it "unmarshals the dump" do
          Marshal.should_receive(:load).with(@marshal_dump).
            and_return(unmarshalled_data = mock(:unmarshalled_data))
            
          Serializer.deserialize(@object).should == unmarshalled_data
        end
      end
      
      context "and a LightMongo::Document" do
        before(:each) do
          class TestClass
          end
          
          @id = mock(:id)
          @object = {'_id' => @id, '_class_name' => 'TestClass', '_embed' => true}
        end
        
        it "recovers the linked document" do
          TestClass.stub!(:find).with(@id).and_return(test_instance = mock(:test_instance))
          
          Serializer.deserialize(@object).should == test_instance
        end
      end
    end
    
    context "when the object is anything else" do
      before(:each) do
        @object = 3
      end
      
      it "returns the object unharmed" do
        Serializer.deserialize(@object).should == @object
      end
    end
  end
  
  describe ".serialize(object, current_depth)" do
    before(:each) do
      @depth = 0
      @serializer = Serializer.new(@object, @depth)
      @serializer.stub!(:hash_serialize => (@hash_serialized_object = mock(:hash_serialized_object)))
      Serializer.stub!(:new).with(@object, anything).and_return(@serializer)
    end

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
  
  describe "#marshal(object)" do
    it "marshals the object." do
      Marshal.should_receive(:dump).with(@object)
      Serializer.new(@object).marshal
    end
    
    it "returns the marshalled object." do
      Marshal.stub!(:dump).
        with(@object).
        and_return(marshalled_object = mock(:marshalled_object))
      Serializer.new(@object).marshal.should == {'_data' => marshalled_object}
    end
  end

  describe "#hash_serialize(object, current_depth)" do
    before(:each) do
      @current_depth = mock(:current_depth)
    end
    
    it "serializes the object into a set of nested hashes." do
      LightMongo::Document::Serialization::HashSerializer.
        should_receive(:dump).with(@object, @current_depth)
      Serializer.new(@object, @current_depth).hash_serialize
    end
    
    it "returns the marshalled object." do
      LightMongo::Document::Serialization::HashSerializer.stub!(:dump).
        with(@object, @current_depth).
        and_return(hashed_object = mock(:hashed_object))
      Serializer.new(@object, @current_depth).hash_serialize.should == hashed_object
    end
  end
end
