DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://db/database.sqlite3', :loggers => [Logger.new($stdout)])

class Package < Sequel::Model
	one_to_many :builds
end

class Build < Sequel::Model
	many_to_one :package
end
