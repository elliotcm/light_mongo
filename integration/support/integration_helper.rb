require File.dirname(__FILE__) + '/../../lib/light_mongo'

LightMongo.database = 'light_mongo_test'

def db_teardown
  after(:each) do
    LightMongo.connection.drop_database(LightMongo.database.name)
  end
end
