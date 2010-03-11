LightMongo
==========
LightMongo is a lightweight Mongo object persistence layer for Ruby which makes use of Mongo's features rather than trying to emulate ActiveRecord.

Status
-----------------
LightMongo is only a few days old, so while most of the features demo'd below work, there's no strong integration testing yet, so I wouldn't use it for data you particularly care about until I release a gem.

Check out the development roadmap for an idea of my current priorities.

The problem
-----------
Developers occasionally encounter a domain which defies simple modelling in an ActiveRecord relational style, and look to some of the nosql databases for a solution.  They find Mongo, a document database, and feel it might provide the flexibility they need.  After a bit of research they pick out a persistence library which seems popular and well maintained.  It even emulates most of ActiveRecord's behaviour, style and relational philosophy.  Great!

Hang on a minute, wasn't it ActiveRecord's behaviour, style and relational philosophy they moved to Mongo to get away from?

The solution
------------
+ Ruby instances store their state in instance variables.  Why do we need to hide this in the persistence layer?
+ Ruby has quite the heap of array management operators.  Why do we need explicit relationships and relationship proxies?
+ Objects of the same class can perform a number of different roles or be related to other classes in lots of ways.  Why do we need to jump through complicated and restrictive hoops to do something we do in pure Ruby domains all the time?

Mongo is a flexible database.  We can make use of that flexibility to allow our persistence layer to make decisions on how to best serialise and deserialise our objects.  It's our responsibility to make sure our domain is correct.  It's the library's responsibility to store those domain objects.

We're Ruby developers.  Let's act like it.

An example
----------
    class Article
      include LightMongo::Document
    end
    
    geology_article = Article.new(:title => 'Fluid Physics in Geology', :abstract => 'Lorem ipsum dolor..')
    geology_article.save
    
    Article.find.first
    => #<Article:0x101647448 @_id="4b93c1e97bc7697187000001" @title="Fluid Physics in Geology" @abstract="Lorem upsum dolor...">

No tables.  No database.  Save your migrations for when you actually have some data to shift around.
    
Slightly more complex
---------------------
Plain Ruby objects stored in your Documents will be serialised along with the Document and embedded in the Mongo document.

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
    
    geology_article = Article.create(:title => 'Fluid Physics in Geology')
    comment = Comment.new
    comment.author_name = 'Dave'
    comment.text = "Cool article!"
    
    geology_article.comments << comment
    geology_article.save
    
    first_article = Article.find.first
    
    first_article.title
    => "Fluid Physics in Geology"
    
    first_article.comments
    => [#<Comment:0x101664138 @author_name="Dave" @text="Cool article!">]

Dynamic finders
---------------
It's not generally a good idea to do much searching on keys that haven't been indexed (as in most databases), so LightMongo will only set up dynamic finders for attributes you've asked to have indexed.  If you really want an unindexed finder, they're not difficult to write.

    class Article
      include LightMongo::Document
      attr_reader :page_length
      index :title
      index :abstract, :as => :precis
    end

    geology_article = Article.create(:title => 'Fluid Physics in Geology',
                                     :abstract => 'A study in geological fluid physics',
                                     :page_length => 367)
    
    Article.find_by_title('Fluid Physics in Geology').first == geology_article
    => true
    
    Article.find_by_precis('A study in geological fluid physics').first == geology_article
    => true
    
The aliasing option is not required, but is recommended if you want dynamic finders for indexed keys that can't be represented in a standard Ruby method name (for example, a finder will not be created for a complex multi-level Mongo key index.  See the Mongo manual for more information).

Cross-collection relationships
------------------------------
LightMongo uses its Document mixin to signify a collection, so if you embed a LightMongo::Document inside another LightMongo::Document, the serialisation engine will consider this a cross-collection relationship and behave accordingly.

    class Article
      include LightMongo::Document
      attr_reader :author
    end

    class Person
      include LightMongo::Document
    end
    
    dave = Person.new(:name => 'Dave')
    fluid_physics = Article.create(:title => 'Fluid Physics in Geology', :author => dave)
    
    Person.find.first
    => #<Person:0x101664138 @_id="4b93cf9397bc7697187000001" @name="Dave">
    
    Article.find.first.author == Person.find.first
    => true

Roadmap
-------
1. Improved testbed to allow stronger integration testing.
2. More intelligent and efficient object serialisation.
3. Proper deserialisation of cross-collection objects (currently they go in, don't come back out).
4. Nested hash serialisation.
4. Migrations (e.g. when you rename classes or modify their collection style).
5. Some kind of validations, perhaps.






