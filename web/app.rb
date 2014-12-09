require 'aws-sdk'
require 'gems'
require 'logger'
require 'net/scp'
require 'net/ssh'
require 'pmap'
require 'sequel'
require 'sinatra/base'

require_relative 'lib/aws'
require_relative 'lib/ci'
require_relative 'lib/helpers'
require_relative 'lib/models'
require_relative 'lib/packages'

class RubyStats < Sinatra::Base
	configure :development do
		require 'flamegraph'
		require 'rack-mini-profiler'
		use Rack::MiniProfiler
	end

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

	get '/build_logs/:category/:package' do
		erb :build_logs, locals: { category: params[:category], package: params[:package] }
	end
end
