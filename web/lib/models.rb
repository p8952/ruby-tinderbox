DB = Sequel.connect(ENV['DATABASE_URL'], max_connections: 12, pool_timeout: 60)

class Package < Sequel::Model
	one_to_many :build
	one_to_many :repoman
end

class Build < Sequel::Model
	many_to_one :package
end

class Repoman < Sequel::Model(:repomans)
	many_to_one :package
end
