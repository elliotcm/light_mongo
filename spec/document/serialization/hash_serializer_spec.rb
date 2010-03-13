require File.dirname(__FILE__) + '/../../../lib/document/serialization/hash_serializer'

HashSerializer = LightMongo::Document::Serialization::HashSerializer

describe HashSerializer do
  it "deep runs a hash" do
    pending
  end
  
  it "deep runs an array" do
    pending
  end
  
  it "deep runs any custom object" do
    pending
  end
  
  it "employs a Serializer on any attributes which are containers of some sort" do
    pending
  end
  
  it "does a simple copy of any non-container attributes into the outbound hash" do
    pending
  end
  
  it "does a post-serialization copy of any container attributes into the outbound hash" do
    pending
  end
end
