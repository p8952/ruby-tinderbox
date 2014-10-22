require 'gems'
require 'logger'
require 'pmap'
require 'sequel'
require 'sinatra/base'
require_relative 'lib/models'
require_relative 'lib/update'

class RubyStats < Sinatra::Base

	packages = Package.order(:name, :slot)

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
