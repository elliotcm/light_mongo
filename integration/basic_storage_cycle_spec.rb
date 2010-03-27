require File.expand_path(File.dirname(__FILE__) + '/support/integration_helper')

class Article
  include LightMongo::Document
end

describe 'The basic storage cycle' do
  before(:each) do
    @geology_params = {
      :title => (@title = 'Fluid Physics in Geology'),
      :abstract => (@abstract = 'Lorem ipsum dolor..')
    }
  end
  
  it "creates and reads." do
    Article.create(@geology_params)
    stored_article = Article.find.first
    stored_article.instance_variable_get('@title').should == @title
    stored_article.instance_variable_get('@abstract').should == @abstract
  end
  
  db_teardown
end