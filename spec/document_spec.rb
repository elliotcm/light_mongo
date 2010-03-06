require File.dirname(__FILE__) + '/../lib/document'

describe LightMongo::Document do
  it "loads the serialization module" do
    class TestClass
      include LightMongo::Document
    end
    
    TestClass.should include(LightMongo::Document::Serialization)
  end
end
