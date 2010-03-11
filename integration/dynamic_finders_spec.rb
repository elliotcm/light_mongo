require File.expand_path(File.dirname(__FILE__) + '/support/integration_helper')

LightMongo.slow_serialization = true

class Article
  include LightMongo::Document

  attr_reader :page_length
  index :title
  index :abstract, :as => :precis
end

describe 'Indexing an attribute' do
  before(:each) do
    @geology_article = Article.create(:title => 'Fluid Physics in Geology',
                                      :abstract => 'A study in geological fluid physics',
                                      :page_length => 367)
  end
  
  context "where an alias is not given" do
    it "creates a finder using the key name" do
      Article.find_by_title('Fluid Physics in Geology').first.should == @geology_article
    end
  end
  
  context "where an alias has been given" do
    it "creates a finder using the alias name" do
      Article.find_by_precis('A study in geological fluid physics').first.should == @geology_article
    end
  end
  
  db_teardown
end