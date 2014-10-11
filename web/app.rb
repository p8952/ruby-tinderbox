require 'logger'
require 'sequel'
require 'sinatra/base'

class RubyStats < Sinatra::Base

	DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://db/database.sqlite3', :loggers => [Logger.new($stdout)])
	packages = DB[:packages]

	get '/' do
		erb :home, :locals => {:packages => packages}
	end

end
