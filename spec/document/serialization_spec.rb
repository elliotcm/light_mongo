require File.dirname(__FILE__) + '/../../lib/document'

describe LightMongo::Document::Serialization do
  before(:each) do
    LightMongo.stub!(:database => mock(:database, :connection => nil))

    class TestClass
      include LightMongo::Document
      attr_accessor :test_attribute
    end
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
      test_object_out = TestClass.new(@test_object_in.to_hash)
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
      test_object_out = TestClass.new(@test_object_in.to_hash)
      l1_embedded_object_out = test_object_out.test_attribute
      l2_embedded_object_out = l1_embedded_object_out.level_one_embedded_attribute
      l2_embedded_object_out.level_two_embedded_attribute.should == @l2_embedded_attribute
    end
  end

  def self.it_serialises_the_attribute
    it "correctly serialises the given attribute" do
      test_object_in = TestClass.new(:test_attribute => @attribute_value)
      test_object_out = TestClass.new(test_object_in.to_hash)
    
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
  
  describe "serializing nested Documents" do
    before(:each) do
      class Outer
        include LightMongo::Document
      end
      
      class Inner
        include LightMongo::Document
      end
      
      @inner = Inner.new
      @outer = Outer.new(:inner => @inner)
      
      @inner.stub!(:save => @inner.object_id)
      @outer.stub!(:save => @outer.object_id)
    end
    
    it "exports the inner documents" do
      @inner.should_receive(:export)
      @outer.to_hash
    end
  end
  
  describe "serializing objects containing arrays of non-native objects" do
    before(:each) do
      class Other
        attr_accessor :name
        def initialize
          @name = self.class.name + object_id.to_s
        end
      end
      @other_1 = Other.new
      @other_2 = Other.new
      
      class TestClass
        attr_accessor :objects
      end
      @test_object = TestClass.new(:objects => [@other_1, @other_2])
    end
    
    it "serialized the arrayed objects" do
      @test_object.to_hash['objects'].should == [
        {'_class_name' => 'Other', 'name' => @other_1.name},
        {'_class_name' => 'Other', 'name' => @other_2.name}
      ]
    end
  end
    
  describe "#export" do
    before(:each) do
      @test_object = TestClass.new

      @id = mock(:id)
      @test_object.stub!(:save => @id)
    end
    
    context "if Persistence has been included" do
      it "saves itself" do
        @test_object.should_receive(:save)
        @test_object.export
      end
      
      it "generates a hash of its class name and id" do
        @test_object.export.should == {'_class_name' => 'TestClass', '_id' => @id}
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
    it "parses a hash into instance attributes" do
      @test_object.from_hash(:test_attribute => 'Test value')
      @test_object.test_attribute.should == 'Test value'
    end
  end
end
