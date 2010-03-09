require File.expand_path(File.dirname(__FILE__) + '/integration_helper')
require File.dirname(__FILE__) + '/../lib/light_mongo'

LightMongo.database = 'light_mongo_test'

describe 'Integration tests' do
  db_teardown
  
  before(:each) do
    class Integration
      include LightMongo::Document
    end
  end

  after(:all) do
    Integration.find.should be_empty
  end

  it "tears down the database after each run" do
    Integration.create :name => 'Database teardown example'
    Integration.find.first.should be_a(Integration)
  end
end