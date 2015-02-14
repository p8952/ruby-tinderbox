DB = Sequel.connect(ENV['DATABASE_URL'], max_connections: 12, pool_timeout: 60)
DB.extension :pg_hstore

class Package < Sequel::Model
end

class Build < Sequel::Model
end

class Repoman < Sequel::Model(:repomans)
end

class Timestamp < Sequel::Model
end
