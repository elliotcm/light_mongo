def db_teardown
  after(:each) do
    LightMongo.connection.drop_database(LightMongo.database.name)
  end
end