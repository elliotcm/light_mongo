require File.expand_path(File.dirname(__FILE__) + '/support/integration_helper')

LightMongo.slow_serialization = true

class Article
  include LightMongo::Document

  attr_accessor :title, :comments

  def initialize(*args)
    @comments = []
    super
  end
end

class Comment
  attr_accessor :author_name, :text
end

describe 'Embedding a Ruby object within your LightMongo::Document' do
  before(:each) do
    @geology_article = Article.create(:title => (@title = 'Fluid Physics in Geology'))

    @comment = Comment.new
    @comment.author_name = 'Dave'
    @comment.text = "Cool article!"
    
    @geology_article.comments << @comment
    @geology_article.save
  end
  
  it "is represented as embedded MongoDB documents and eager restored." do
    pending
    stored_article = Article.find.first
    stored_article.title.should == @title
    
    stored_comment = stored_article.comments.first
    stored_comment.author_name.should == @comment.author_name
    stored_comment.text.should == @comment.text
  end
  
  db_teardown
end