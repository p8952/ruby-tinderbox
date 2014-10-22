DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://db/database.sqlite3', :loggers => [Logger.new($stdout)])

class Package < Sequel::Model

end
