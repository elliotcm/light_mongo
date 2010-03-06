require File.dirname(__FILE__) + '/../lib/document'

describe LightMongo::Document do
  before(:each) do
    Mongo::Collection.stub!(:new => mock(:collection))
    LightMongo.stub!(:database => mock(:database))

    class TestClass
      include LightMongo::Document
    end
  end

  it "loads the serialization module" do
    TestClass.should include(LightMongo::Document::Serialization)
  end
  
  it "loads the persistence module" do
    TestClass.should include(LightMongo::Document::Persistence)
  end
end
