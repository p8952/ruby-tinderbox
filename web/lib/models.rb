DB = Sequel.connect(ENV['DATABASE_URL'], pool_timeout: 25)

class Package < Sequel::Model
	one_to_many :builds
end

class Build < Sequel::Model
end
