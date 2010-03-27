require File.dirname(__FILE__) + '/../../lib/document/active_model_compliance'

ActiveModelCompliance = LightMongo::Document::ActiveModelCompliance

class ActiveModelComplianceTest
  include LightMongo::Document::ActiveModelCompliance
end

describe ActiveModelCompliance do
  before(:each) do
    @model = ActiveModelComplianceTest.new
  end
  
  describe "#valid?" do
    it "responds to #valid?" do
      @model.should respond_to(:valid?)
    end
    
    it "always returns true" do
      @model.valid?.should be_true
    end
  end
  
  describe "#new_record?" do
    it "responds to #new_record?" do
      @model.should respond_to(:new_record?)
    end
    
    context "when the object has an id" do
      before(:each) do
        @model.instance_variable_set(:@_id, mock(:id))
      end
      
      it "is false" do
        @model.new_record?.should be_false
      end
    end

    context "when the object has no id" do
      before(:each) do
        @model.instance_variable_set(:@_id, nil)
      end
      
      it "is true" do
        @model.new_record?.should be_true
      end
    end
  end

  describe "#destroyed?" do
    it "responds to #destroyed?" do
      @model.should respond_to(:destroyed?)
    end
    
    context "when the object has an id" do
      before(:each) do
        @model.instance_variable_set(:@_id, mock(:id))
      end
      
      it "is false" do
        @model.destroyed?.should be_false
      end
    end

    context "when the object has no id" do
      before(:each) do
        @model.instance_variable_set(:@_id, nil)
      end
      
      it "is true" do
        @model.destroyed?.should be_true
      end
    end
  end
end
