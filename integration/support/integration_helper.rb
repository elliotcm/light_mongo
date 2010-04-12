require File.dirname(__FILE__) + '/../../lib/light_mongo'

LightMongo.database = 'light_mongo_test'

Spec::Runner.configure do |config|
  config.append_after(:each) do
    LightMongo.connection.drop_database(LightMongo.database.name)
  end
end
