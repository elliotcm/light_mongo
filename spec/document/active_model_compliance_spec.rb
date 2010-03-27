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
end
