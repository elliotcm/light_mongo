require File.dirname(__FILE__) + '/../../lib/light_mongo'

describe LightMongo::Document::Persistence do
  before(:all) do
    LightMongo.stub!(:database => mock(:database, :connection => nil))
    @test_class_collection = mock(:test_class_collection)
    Mongo::Collection.stub!(:new => @test_class_collection)

    class TestClass
      include LightMongo::Document
      attr_accessor :name
    end
  end
  
  describe "the module's inclusion" do
    it "sets up the collection on a class-level" do
      TestClass.collection.should == @test_class_collection
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
  
  describe ".create(params)" do
    before(:each) do
      @name = mock(:name)
      @test_object = TestClass.new(:name => @name)
      @test_object.stub!(:save)
      TestClass.stub!(:new).with(:name => @name).and_return(@test_object)
    end
    
    it "spawns a new Ruby object from the params" do
      TestClass.create(:name => @name).name.should == @name
    end
    
    it "saves the Ruby object to the database" do
      @test_object.should_receive(:save)
      TestClass.create(:name => @name)
    end
  end
  
  describe "#update!(params)" do
    before(:each) do
      @test_object = TestClass.new(:name => 'Test object')
      @test_object.stub!(:save => (@result = mock(:result)))
    end

    def update_object
      @test_object.update! :name => (@name = mock(:name))
    end
    
    it "updates the object's state" do
      update_object
      @test_object.name.should == @name
    end
    
    it "saves the object" do
      @test_object.should_receive(:save)
      update_object
    end
    
    it "returns the result of the save" do
      update_object.should == @result
    end
  end

  describe "#update(params)" do
    before(:each) do
      @test_object = TestClass.new(:name => 'Test object')
    end

    def update_object
      @test_object.update :name => (@name = mock(:name))
    end
    
    it "updates the object's state" do
      update_object
      @test_object.name.should == @name
    end
    
    it "returns the object" do
      update_object.should == @test_object
    end
  end

  describe "#delete!" do
    before(:each) do
      @test_object = TestClass.new(:_id => (@id = mock(:id)), :name => 'Test object')
    end

    it "removes the object" do
      @test_class_collection.should_receive(:remove).with(:_id => @id)
      @test_object.delete!
    end
    
    it "returns the result of the remove" do
      @test_class_collection.stub!(:remove => (@result = mock(:result)))
      @test_object.delete!.should == @result
    end
    
    it "erases the document's id" do
      @test_object.id.should == @id

      @test_class_collection.stub!(:remove => true)
      @test_object.delete!
      @test_object.id.should be_nil
    end
  end
  
  describe "#id" do
    before(:each) do
      @id = mock(:id)
      @test_object = TestClass.new(:_id => @id)
    end
    
    it "delegates to the Mongo _id" do
      @test_object.id.should == @id
    end
  end
  
  describe "#==(other)" do
    before(:each) do
      @id = mock(:id)
      @object_1 = TestClass.new(:_id => @id)
      @object_2 = TestClass.new(:_id => @id)
    end

    it "compares on id" do
      @object_1.should == @object_2
    end
  end
  
  describe ".find_by_<index>(value)" do
    before(:each) do
      @test_class_collection.stub!(:create_index)
      TestClass.index(:name)
      @name = mock(:name)
      @id = mock(:id)
      
      @bson_hash = {:class_name => 'TestClass', :name => @name, :_id => @id}
    end
    
    it "finds all objects which match the given index pattern" do
      @test_class_collection.should_receive(:find).with(:name => @name).and_return([@bson_hash])
      test_object = TestClass.find_by_name(@name).first
      test_object.id.should == @id
      test_object.name.should == @name
      test_object.class.should == TestClass
    end
  end
  
  describe ".find(query=nil)" do
    context "when passed a string" do
      before(:each) do
        @query = "4bae6ac37bc7693598000001"
        Mongo::ObjectID.stub!(:from_string).with(@query).and_return(oid = mock(:oid))
        @test_class_collection.stub!(:find_one).with(oid).and_return(results = mock(:results))
        TestClass.stub!(:new).with(results).and_return(@TestObject = mock(:TestObject))
      end
      
      it "does a single-record lookup using the string as an ID" do
        TestClass.find(@query).should == @TestObject
      end
    end
    
    context "when passed an OID" do
      before(:each) do
        @query = Mongo::ObjectID.from_string("4bae6ac37bc7693598000001")
        @test_class_collection.stub!(:find_one).with(@query).and_return(results = mock(:results))
        TestClass.stub!(:new).with(results).and_return(@TestObject = mock(:TestObject))
      end
      
      it "does a single-record lookup using the ID" do
        TestClass.find(@query).should == @TestObject
      end
    end
    
    context "when passed anything else" do
      before(:each) do
        @query = mock(:query)
        @test_class_collection.stub!(:find).with(@query).and_return([results = mock(:results)])
        TestClass.stub!(:new).with(results).and_return(@TestObject = mock(:TestObject))
      end
      
      it "does a multi-record lookup on the query" do
        TestClass.find(@query).should == [@TestObject]
      end
    end
  end
  
  describe ".index(key, :as => (name | nil))" do
    def self.it_sets_up_the_index_verbatim
      it "sets up the index with key #{@key} and name #{@name}" do
        @test_class_collection.should_receive(:create_index).with(@key)
        set_up_class(@key, @name)
        TestClass.should respond_to(('find_by_'+@name.to_s).to_sym)
      end
    end
    
    def set_up_class(key, name=nil)
      TestClass.index(key, :as => name)

      @indexable_object = TestClass.new(:top_level_attribute => 'test')
    end
    
    context "when given no key" do
      it "creates no index and no method" do
        @test_class_collection.should_not_receive(:create_index)
        set_up_class(nil)
        set_up_class('')
        TestClass.should_not respond_to(:find_by_)
      end
    end
    
    context "when the given key is usable as a method name" do
      before(:each) do
        @key = :top_level_attribute
      end
      
      context "and no name is provided" do
        it "uses the key as the lookup name" do
          @test_class_collection.should_receive(:create_index).with(@key)
          set_up_class(@key)
          TestClass.should respond_to(('find_by_'+@key.to_s).to_sym)
        end
      end
      
      context "and a name is provided" do
        before(:each) do
          @name = :environment
        end
        
        it_sets_up_the_index_verbatim
      end
    end
    
    context "when the given key is unusuable as a method name" do
      before(:each) do
        @key = 'top_level_attribute.sub_attribute'
      end
      
      context "and no name is provided" do
        it "adds an index on the key" do
          @test_class_collection.should_receive(:create_index).with(@key)
          set_up_class(@key)
        end
        
        it "does not create a method using the key" do
          @test_class_collection.stub(:create_index)
          set_up_class(@key)
          TestClass.should_not respond_to(('find_by_'+@key.to_s).to_sym)
        end
      end
      
      context "and a name is provided" do
        before(:each) do
          @name = :sub_environment
        end
        
        it_sets_up_the_index_verbatim
      end
    end
  end
  
  describe ".viable_method_name(method_name)" do
    context "contains only alphanums and underscores" do
      it "is valid" do
        TestClass.viable_method_name('_jkdsf328_32').should be_true
      end
      
      context "and ends in an exclamation mark" do
        it 'is valid' do
          TestClass.viable_method_name('_jkdsf328_32!').should be_true
        end
      end

      context "and ends in an question mark" do
        it 'is valid' do
          TestClass.viable_method_name('_jkdsf328_32?').should be_true
        end
      end
    end
    
    context "contains a non [alphanum_!?] anywhere" do
      it "is invalid" do
        TestClass.viable_method_name('_jkdsf328_32*').should be_false
        TestClass.viable_method_name('_jkdsf^328_32').should be_false
      end
    end
    
    context "contains a [!?] anywhere but the end" do
      it "is invalid" do
        TestClass.viable_method_name('_jkds!f328_32').should be_false
        TestClass.viable_method_name('_jkds?f328_32').should be_false
      end
    end
  end

end
