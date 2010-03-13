require File.dirname(__FILE__) + '/../../../lib/document/serialization'

Serialization = LightMongo::Document::Serialization
HashSerializer = Serialization::HashSerializer

describe HashSerializer do
  describe ".dump(object, current_depth)" do
    context "when the object is an Array" do
      before(:each) do
        @current_depth = 0
        
        @object = [
          @sub_object_1 = mock(:sub_object_1),
          @sub_object_2 = mock(:sub_object_2)
        ]
        
        Serialization::Serializer.
          stub!(:serialize).
          with(@sub_object_1, anything).
          and_return(@serial_1 = mock(:serial_1))
        Serialization::Serializer.
          stub!(:serialize).
          with(@sub_object_2, anything).
          and_return(@serial_2 = mock(:serial_2))
      end
      
      it "iterates over the array, serializing the contents." do
        HashSerializer.dump(@object).should == [@serial_1, @serial_2]
      end
      
      it "notifies the generic Serializer of the new depth." do
        Serialization::Serializer.should_receive(:serialize).with(@sub_object_1, @current_depth + 1)
        HashSerializer.dump(@object, @current_depth)
      end
      
      it "returns an array." do
        HashSerializer.dump(@object).should be_an(Array)
      end
    end
    
  end
  
  xit "deep runs a hash" do
    pending
  end
  
  xit "deep runs any custom object" do
    pending
  end
  
  xit "employs a Serializer on any attributes which are containers of some sort" do
    pending
  end
  
  xit "does a simple copy of any non-container attributes into the outbound container" do
    pending
  end
  
  xit "does a post-serialization copy of any container attributes into the outbound container" do
    pending
  end
end
