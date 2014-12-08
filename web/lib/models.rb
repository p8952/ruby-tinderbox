DB = Sequel.connect(ENV['DATABASE_URL'], pool_timeout: 25)

class Package < Sequel::Model
end

class Build < Sequel::Model
end
