require File.expand_path(File.dirname(__FILE__) + '/support/integration_helper')

LightMongo.slow_serialization = true

class Article
  include LightMongo::Document
  attr_reader :author
end

class Person
  include LightMongo::Document
end

describe 'Embedding a LightMongo::Document within another LightMongo::Document' do
  before(:each) do
    @dave = Person.new(:name => 'Dave')
    @geology_article = Article.create(:title => 'Fluid Physics in Geology', :author => @dave)
  end
  
  it "allows independent access to the embedded document via its collection." do
    Person.find.first.should == @dave
  end
  
  it "retains a reference to the embedded document in its container document." do
    Article.find.first.author.should == @dave
  end
end