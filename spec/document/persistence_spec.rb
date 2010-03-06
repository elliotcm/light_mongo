require File.dirname(__FILE__) + '/../../lib/document'

describe LightMongo::Document::Persistence do
  before(:each) do
    LightMongo.stub!(:database => mock(:database, :connection => nil))

    class TestClass
      include LightMongo::Document
      attr_accessor :name
    end
    @test_class_collection = mock(:test_class_collection)
    TestClass.send(:class_variable_set, :@@collection, @test_class_collection)
  end
  
  describe "the module's inclusion" do
    it "sets up the collection on a class-level" do
      TestClass.send(:class_variable_get, :@@collection).should == @test_class_collection
    end
  end
  
  describe "#save" do
    before(:each) do
      @test_object_hash = mock(:test_object_hash)
      @test_object = TestClass.new
      @test_object.stub!(:to_hash => @test_object_hash)
    end
    
    it "saves the Document to the collection for that class" do
      @test_class_collection.should_receive(:save).with(@test_object_hash)
      @test_object.save
    end
  end
end
