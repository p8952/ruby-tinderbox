require 'logger'
require 'sequel'
require 'sinatra/base'

class RubyStats < Sinatra::Base

	DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://db/database.sqlite3', :loggers => [Logger.new($stdout)])
	packages = DB[:packages]

	get '/' do
		redirect to('/ruby_targets')
	end

	get '/ruby_targets' do
		erb :ruby_targets, :locals => {:packages => packages}
	end

	get '/outdated_gems' do
		erb :outdated_gems, :locals => {:packages => packages}
	end

	get '/build_status' do
		erb :build_status, :locals => {:packages => packages}
	end

end
