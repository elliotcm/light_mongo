require File.dirname(__FILE__) + '/../lib/document'

describe LightMongo::Document do
  class TestClass
    include LightMongo::Document
    attr_accessor :test_attribute
  end
  
  before(:each) do
    @test_object = TestClass.new
  end

  def self.it_serialises_the_attribute
    it "correctly serialises the given attribute" do
      test_object_in = TestClass.new(:test_attribute => @attribute_value)
      test_object_out = TestClass.new(test_object_in.to_bson)
    
      test_object_out.test_attribute.should == test_object_in.test_attribute
    end
  end
  
  context "when given a string" do
    before(:each) do
      @attribute_value = mock(:test_value).to_s
    end
    
    it_serialises_the_attribute
  end

  context "when given an integer" do
    before(:each) do
      @attribute_value = mock(:test_value).object_id
    end
    
    it_serialises_the_attribute
  end

  context "when given a float" do
    before(:each) do
      @attribute_value = mock(:test_value).object_id.to_f
    end
    
    it_serialises_the_attribute
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

    context "when given a BSON string" do
      before(:each) do
        @params = BSON.serialize({:test_attribute => @test_value})
      end
      
      it "converts the BSON to attributes" do
        @test_object = TestClass.new(@params)
        @test_object.test_attribute.should == @test_value
      end
    end
  end
  
  describe "#to_bson" do
    before(:each) do
      @test_object.test_attribute = 'Test value'
    end
    
    it "exports all attributes as BSON" do
      BSON.should_receive(:serialize).with({'test_attribute' => 'Test value'})
      @test_object.to_bson
    end
  end
  
  describe "#from_bson(bson)" do
    it "parses BSON into instance attributes" do
      @test_object.from_bson(BSON.serialize({"test_attribute" => "Test value"}))
      @test_object.test_attribute.should == 'Test value'
    end
  end
  
  describe "#from_hash(hash)" do
    it "parses a hash into instance attributes" do
      @test_object.from_hash(:test_attribute => 'Test value')
      @test_object.test_attribute.should == 'Test value'
    end
  end
end
