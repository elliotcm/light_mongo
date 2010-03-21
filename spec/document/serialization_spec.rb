require File.dirname(__FILE__) + '/../../lib/light_mongo'

describe LightMongo::Document::Serialization do
  before(:each) do
    LightMongo.stub!(:database => mock(:database, :connection => nil), :slow_serialization => true)
    @test_class_collection = mock(:test_class_collection)
    Mongo::Collection.stub!(:new => @test_class_collection)

    class TestClass
      include LightMongo::Document
      attr_accessor :test_attribute
    end
  end
    
  describe "#export" do
    before(:each) do
      @test_object = TestClass.new

      @id = mock(:id)
      @test_class_collection.stub!(:save => @id)
    end
    
    context "if Persistence has been included" do
      it "saves itself" do
        @test_object.should_receive(:save)
        @test_object.export
      end
      
      it "generates a hash of its class name, id, and embed status" do
        @test_object.export.should == {'_class_name' => 'TestClass', '_id' => @id, '_embed' => true}
      end
    end
    
    context "if Persistence hasn't been included" do
      before(:each) do
        class NoPersistence
          include LightMongo::Document::Serialization
        end
        @no_persistence = NoPersistence.new
      end
      
      it "returns self" do
        @no_persistence.export.should == @no_persistence
      end
    end
  end
  
  describe "#initialize(params)" do
    before(:each) do
      @test_value = mock(:test_value).to_s
    end

    context "when given a hash" do
      before(:each) do
        @params = {:test_attribute => @test_value}
      end
      
      it "converts the hash to attributes" do
        @test_object = TestClass.new(@params)
        @test_object.test_attribute.should == @test_value
      end
    end
  end

  describe "#from_hash(hash)" do
    before(:each) do
      @test_object = TestClass.new
    end

    it "parses a hash into instance attributes" do
      @test_object.from_hash(:test_attribute => 'Test value')
      @test_object.test_attribute.should == 'Test value'
    end
  end
end
