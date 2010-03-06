require File.dirname(__FILE__) + '/../lib/document'

describe LightMongo::Document do
  class TestClass
    include LightMongo::Document
  end

  it "loads the serialization module" do
    TestClass.should include(LightMongo::Document::Serialization)
  end
  
  it "loads the repository module" do
    TestClass.should include(LightMongo::Document::Repository)
  end
end
