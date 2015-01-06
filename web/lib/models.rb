if ENV['RACK_ENV'] == 'test'
	DB =  Sequel.sqlite
	Sequel.extension :migration
	Sequel::Migrator.run(DB, 'db/migrations')
else
	DB = Sequel.connect(ENV['DATABASE_URL'], pool_timeout: 25)
end

class Package < Sequel::Model
end

class Build < Sequel::Model
end
