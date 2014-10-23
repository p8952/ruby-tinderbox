require 'gems'
require 'logger'
require 'pmap'
require 'sequel'
require 'sinatra/base'
require_relative 'lib/helpers'
require_relative 'lib/models'
require_relative 'lib/update'

class RubyStats < Sinatra::Base

	get '/' do
		redirect to('/ruby_targets')
	end

	get '/ruby_targets' do
		erb :ruby_targets
	end

	get '/outdated_gems' do
		erb :outdated_gems
	end

	get '/build_status' do
		erb :build_status
	end

end
