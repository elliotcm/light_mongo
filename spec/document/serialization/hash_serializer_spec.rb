require File.dirname(__FILE__) + '/../../../lib/light_mongo'

describe LightMongo::Document::Serialization::HashSerializer do
  HashSerializer = LightMongo::Document::Serialization::HashSerializer
  
  before(:each) do
    @current_depth = 0
  end

  describe ".serialize_object(object_to_serialize, current_depth)" do
    before(:each) do
      LightMongo.stub!(:database => mock(:database, :connection => nil), :slow_serialization => true)
      @test_class_collection = mock(:test_class_collection)
      Mongo::Collection.stub!(:new => @test_class_collection)
    end
    
    context "when a non-primitive" do
      context "non-LightMongo::Document object" do
        before(:each) do
          class Other
            attr_accessor :name
            def initialize
              @name = self.class.name + object_id.to_s
            end
          end
          
          @object = Other.new
        end
        
        it "hashifies the object" do
          HashSerializer.send(:serialize_object, @object, @current_depth).
            should == {'_class_name' => 'Other', 'name' => @object.name}
        end
      end
      
      context "LightMongo::Document object" do
        before(:each) do
          class TestClass
            include LightMongo::Document
          end
          
          @object = TestClass.new
          @test_class_collection.stub(:save => (@id = mock(:id)))
        end
        
        context "when below the top level" do
          before(:each) do
            @current_depth = 1
          end
          
          it "exports the object" do
            HashSerializer.send(:serialize_object, @object, @current_depth).
              should == {'_class_name' => 'TestClass', '_id' => @id}
          end
        end
        
        context "when at the top level" do
          before(:each) do
            @current_depth = 0
          end
          
          it "hashifies the object" do
            HashSerializer.should_receive(:hashify).with(@object, @current_depth)
            HashSerializer.send(:serialize_object, @object, @current_depth)
          end
        end
      end
    end
    
    context "when a primitive object" do
      before(:each) do
        @object = "test string"
      end
      
      it "returns the raw object" do
        HashSerializer.send(:serialize_object, @object, @current_depth).
          should == @object
      end
    end
  end

  describe ".dump(object, current_depth)" do
    context "when the object is a container" do
      before(:each) do
        
        @sub_object_1 = mock(:sub_object_1)
        @sub_object_2 = mock(:sub_object_2)
        
        LightMongo::Document::Serialization::Serializer.
          stub!(:serialize).
          with(@sub_object_1, anything).
          and_return(@serial_1 = mock(:serial_1))
        LightMongo::Document::Serialization::Serializer.
          stub!(:serialize).
          with(@sub_object_2, anything).
          and_return(@serial_2 = mock(:serial_2))
      end

      context "and more specifically an Array" do
        before(:each) do
          @object = [@sub_object_1, @sub_object_2]
        end
      
        it "iterates over the array, serializing the contents." do
          HashSerializer.dump(@object).should == [@serial_1, @serial_2]
        end
      
        it "notifies the generic Serializer of the new depth." do
          LightMongo::Document::Serialization::Serializer.should_receive(:serialize).with(@sub_object_1, @current_depth + 1)
          HashSerializer.dump(@object, @current_depth)
        end
      
        it "returns an array." do
          HashSerializer.dump(@object).should be_an(Array)
        end
      end
    
      context "and more specifically a Hash" do
        before(:each) do
          @object = {
            :sub_object_1 => @sub_object_1,
            :sub_object_2 => @sub_object_2
          }
        end
      
        it "iterates over the hash, serializing the contents but retaining the keys." do
          HashSerializer.dump(@object).should == {:sub_object_1 => @serial_1, :sub_object_2 => @serial_2}
        end
      
        it "notifies the generic Serializer of the new depth." do
          LightMongo::Document::Serialization::Serializer.should_receive(:serialize).with(@sub_object_1, @current_depth + 1)
          HashSerializer.dump(@object, @current_depth)
        end
      
        it "returns a Hash." do
          HashSerializer.dump(@object).should be_an(Hash)
        end
      end
    end
    
    context "when the object is a custom object" do
      before(:each) do
        class TestClass; end
        @object = TestClass.new
      end
      
      it "passes off to the object serializer" do
        HashSerializer.should_receive(:serialize_object).with(@object, @current_depth)
        HashSerializer.dump(@object, @current_depth)
      end
    end
  end
end
