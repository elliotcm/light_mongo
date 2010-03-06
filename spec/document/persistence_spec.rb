require File.dirname(__FILE__) + '/../../lib/document'

describe LightMongo::Document::Persistence do
  before(:each) do
    @collection = mock(:collection)
    Mongo::Collection.stub!(:new).with(anything, 'TestClass').and_return(@collection)
    LightMongo.stub!(:database => mock(:database))

    class TestClass
      include LightMongo::Document
      attr_accessor :name
    end
  end
  
  describe "the module's inclusion" do
    it "sets up the collection on a class-level" do
      TestClass.send(:class_variable_get, :@@collection).should == @collection
    end
  end
  
  describe "#save" do
    xit "saves the Document to the collection for that class" do
      TestClass.new(:name).save
    end
  end
end
