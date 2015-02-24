require 'archive/tar/minitar'
require 'docker'
require 'gems'
require 'logger'
require 'net/scp'
require 'net/ssh'
require 'pmap'
require 'sequel'
require 'sinatra/base'

require_relative 'lib/ci'
require_relative 'lib/helpers'
require_relative 'lib/models'
require_relative 'lib/packages'
require_relative 'lib/repoman'

class RubyTinderbox < Sinatra::Base
	get '/' do
		redirect to('/ruby_targets')
	end

	get '/ruby_targets' do
		update_timestamp = Package.first[:update_timestamp]
		portage_timestamp = Package.first[:portage_timestamp]
		packages = Package.order { [category, lower(name), version, revision] }.to_hash_groups(:identifier)
		erb :ruby_targets, locals: { packages: packages, update_timestamp: update_timestamp, portage_timestamp: portage_timestamp }
	end

	get '/outdated_gems' do
		update_timestamp = Package.first[:update_timestamp]
		portage_timestamp = Package.first[:portage_timestamp]
		packages = Package.distinct(:category, :name).order(:category, :name, Sequel.desc(:version), Sequel.desc(:revision)).exclude(gem_version: 'nil')
		erb :outdated_gems, locals: { packages: packages, update_timestamp: update_timestamp, portage_timestamp: portage_timestamp  }
	end

	get '/build_status' do
		update_timestamp = Build.order(:time).last[:time]
		portage_timestamp = Package.first[:portage_timestamp]
		builds = Build.distinct(:package_id).order(:package_id, Sequel.desc(:time))
		erb :build_status, locals: { builds: builds, update_timestamp: update_timestamp, portage_timestamp: portage_timestamp  }
	end

	get '/build_history/:category/:package' do
		builds = Build.where(package_id: params[:category] + '/' + params[:package]).reverse_order(:time)
		erb :build_history, locals: { builds: builds }
	end

	get '/build_logs/:category/:package/:time' do
		build = Build.where(package_id: params[:category] + '/' + params[:package], time: params[:time]).first
		erb :build_logs, locals: { build: build }
	end

	get '/repoman_checks' do
		update_timestamp = Repoman.order(:time).last[:time]
		portage_timestamp = Package.first[:portage_timestamp]
		repomans = Repoman.distinct(:package_id).order(:package_id, Sequel.desc(:time))
		erb :repoman_checks, locals: { repomans: repomans, update_timestamp: update_timestamp, portage_timestamp: portage_timestamp  }
	end

	get '/repoman_logs/:category/:package/:time' do
		repomans = Repoman.where(package_id: params[:category] + '/' + params[:package], time: params[:time]).first
		erb :repoman_logs, locals: { repomans: repomans }
	end

	get '/repoman_history/:category/:package' do
		repomans = Repoman.where(package_id: params[:category] + '/' + params[:package]).reverse_order(:time)
		erb :repoman_history, locals: { repomans: repomans }
	end

	get '/visualizations' do
		# Timestamps
		update_timestamp = Package.first[:update_timestamp]
		portage_timestamp = Package.first[:portage_timestamp]

		# Ruby Targets
		ruby_1_9_amd64 = Package.where(r19_target: 'ruby19', amd64_keyword: 'amd64').count
		ruby_1_9__amd64 = Package.where(r19_target: 'ruby19', amd64_keyword: '~amd64').count
		ruby_2_0_amd64 = Package.where(r20_target: 'ruby20', amd64_keyword: 'amd64').count
		ruby_2_0__amd64 = Package.where(r20_target: 'ruby20', amd64_keyword: '~amd64').count
		ruby_2_1_amd64 = Package.where(r21_target: 'ruby21', amd64_keyword: 'amd64').count
		ruby_2_1__amd64 = Package.where(r21_target: 'ruby21', amd64_keyword: '~amd64').count
		ruby_2_2_amd64 = Package.where(r22_target: 'ruby22', amd64_keyword: 'amd64').count
		ruby_2_2__amd64 = Package.where(r22_target: 'ruby22', amd64_keyword: '~amd64').count

		# Outdated Gems
		uptodate = []
		outdated = []
		Package.distinct(:category, :name).reverse_order(:category, :name, :version).exclude(gem_version: 'nil').each { |p| uptodate << p if p[:version] >= p[:gem_version] }
		Package.distinct(:category, :name).reverse_order(:category, :name, :version).exclude(gem_version: 'nil').each { |p| outdated << p if p[:version] < p[:gem_version] }

		# Build Status
		succeeded = Build.distinct(:package_id).order(:package_id, Sequel.desc(:time)).where(result: 'succeeded').count
		failed = Build.distinct(:package_id).order(:package_id, Sequel.desc(:time)).where(result: 'failed').count
		timed_out = Build.distinct(:package_id).order(:package_id, Sequel.desc(:time)).where(result: 'timed out').count

		erb :visualizations, locals: {
			portage_timestamp: portage_timestamp,
			update_timestamp: update_timestamp,
			ruby_1_9_amd64: ruby_1_9_amd64,
			ruby_1_9__amd64: ruby_1_9__amd64,
			ruby_2_0_amd64: ruby_2_0_amd64,
			ruby_2_0__amd64: ruby_2_0__amd64,
			ruby_2_1_amd64: ruby_2_1_amd64,
			ruby_2_1__amd64: ruby_2_1__amd64,
			ruby_2_2_amd64: ruby_2_2_amd64,
			ruby_2_2__amd64: ruby_2_2__amd64,
			uptodate: uptodate.count,
			outdated: outdated.count,
			succeeded: succeeded,
			failed: failed,
			timed_out: timed_out
		}
	end
end
