require File.dirname(__FILE__) + '/../../lib/document'

describe LightMongo::Document::Serialization do
  class TestClass
    include LightMongo::Document
    attr_accessor :test_attribute
  end
  
  before(:each) do
    @test_object = TestClass.new
  end

  context "when given an embeddable object" do
    class EmbeddableClass
      attr_accessor :embedded_attribute
    end
    
    before(:each) do
      @embedded_object_in = EmbeddableClass.new
      @embedded_object_in.embedded_attribute = @embedded_attribute = mock(:embedded_attribute).to_s
      @test_object_in = TestClass.new(:test_attribute => @embedded_object_in)
    end
    
    it "recursively serialises the object" do
      test_object_out = TestClass.new(@test_object_in.to_bson)
      embedded_object_out = test_object_out.test_attribute
      embedded_object_out.embedded_attribute.should == @embedded_attribute
    end
  end

  context "when given a doubly embeddable object" do
    class LevelOneEmbeddableClass
      attr_accessor :level_one_embedded_attribute
    end
    
    class LevelTwoEmbeddableClass
      attr_accessor :level_two_embedded_attribute
    end
    
    before(:each) do
      @l1_embedded_object_in = LevelOneEmbeddableClass.new
      @l2_embedded_object_in = LevelTwoEmbeddableClass.new
      
      @l2_embedded_object_in.level_two_embedded_attribute = @l2_embedded_attribute = mock(:embedded_attribute).to_s
      @l1_embedded_object_in.level_one_embedded_attribute = @l2_embedded_object_in
      
      @test_object_in = TestClass.new(:test_attribute => @l1_embedded_object_in)
    end
    
    it "recursively serialises the object" do
      test_object_out = TestClass.new(@test_object_in.to_bson)
      l1_embedded_object_out = test_object_out.test_attribute
      l2_embedded_object_out = l1_embedded_object_out.level_one_embedded_attribute
      l2_embedded_object_out.level_two_embedded_attribute.should == @l2_embedded_attribute
    end
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
      BSON.should_receive(:serialize).with(hash_including('test_attribute' => 'Test value'))
      @test_object.to_bson
    end
    
    it "encodes the class name in the BSON" do
      BSON.should_receive(:serialize).with(hash_including('_class_name' => 'TestClass'))
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
