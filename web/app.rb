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

class RubyTinderbox < Sinatra::Base
	get '/' do
		redirect to('/ruby_targets')
	end

	get '/ruby_targets' do
		update_timestamp = Package.first[:update_timestamp]
		portage_timestamp = Package.first[:portage_timestamp]
		packages = Package.distinct(:sha1, :identifier).order(:identifier)
		erb :'package/ruby_targets', locals: { packages: packages, update_timestamp: update_timestamp, portage_timestamp: portage_timestamp }
	end

	get '/outdated_gems' do
		update_timestamp = Package.first[:update_timestamp]
		portage_timestamp = Package.first[:portage_timestamp]
		packages = Package.distinct(:category, :name).order(:category, :name, Sequel.desc(:version), Sequel.desc(:revision)).exclude(gem_version: 'nil')
		erb :'package/outdated_gems', locals: { packages: packages, update_timestamp: update_timestamp, portage_timestamp: portage_timestamp  }
	end

	get '/build_status' do
		update_timestamp = Build.order(:timestamp).last[:timestamp]
		portage_timestamp = Package.first[:portage_timestamp]
		builds = []
		Package.each do |package|
			builds << package.build_dataset.where(target: 'current').reverse_order(:timestamp).first
		end
		builds = builds.compact.sort_by { |build| build.package[:identifier] }
		erb :'build/build_status', locals: { builds: builds, update_timestamp: update_timestamp, portage_timestamp: portage_timestamp  }
	end

	get '/build_logs/:sha1/:timestamp' do
		package = Package.where(sha1: params[:sha1]).first
		build = package.build_dataset.where(timestamp: params[:timestamp]).first
		erb :'build/build_logs', locals: { package: package, build: build }
	end

	get '/build_history/:sha1' do
		package = Package.where(sha1: params[:sha1]).first
		builds = package.build_dataset.where(target: 'current').reverse_order(:timestamp)
		erb :'build/build_history', locals: { builds: builds }
	end

	get '/repoman_checks' do
		update_timestamp = Build.order(:timestamp).last[:timestamp]
		portage_timestamp = Package.first[:portage_timestamp]
		repomans = []
		Package.each do |package|
			repomans << package.repoman_dataset.where(target: 'current').reverse_order(:timestamp).first
		end
		repomans = repomans.compact.sort_by { |repoman| repoman.package[:identifier] }
		erb :'repoman/repoman_checks', locals: { repomans: repomans, update_timestamp: update_timestamp, portage_timestamp: portage_timestamp  }
	end

	get '/repoman_logs/:sha1/:timestamp' do
		package = Package.where(sha1: params[:sha1]).first
		repoman = package.repoman_dataset.where(timestamp: params[:timestamp]).first
		erb :'repoman/repoman_logs', locals: { package: package, repoman: repoman }
	end

	get '/repoman_history/:sha1' do
		package = Package.where(sha1: params[:sha1]).first
		repomans = package.repoman_dataset.where(target: 'current').reverse_order(:timestamp)
		erb :'repoman/repoman_history', locals: { repomans: repomans }
	end

	get '/new_targets' do
		update_timestamp = Package.first[:update_timestamp]
		portage_timestamp = Package.first[:portage_timestamp]
		packages = []
		Package.each do |package|
			build_current = package.build_dataset.where(target: 'current').reverse_order(:timestamp).first
			next if build_current.nil?

			repoman_current = package.repoman_dataset.where(target: 'current').reverse_order(:timestamp).first
			next if repoman_current.nil?

			repoman_next = package.repoman_dataset.where(target: 'next').reverse_order(:timestamp).first
			next if repoman_next.nil?

			if repoman_current[:result] == 'passed' && repoman_next[:result] == 'passed'
				packages << [package, build_current, nil, repoman_current, repoman_next]
			end
		end
		packages = packages.compact.sort_by { |package| package[0][:identifier] }
		erb :'bumps/new_targets', locals: { packages: packages, update_timestamp: update_timestamp, portage_timestamp: portage_timestamp }
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
		succeeded = Build.distinct(:package_id).order(:package_id, Sequel.desc(:timestamp)).where(result: "succeeded\n").count
		failed = Build.distinct(:package_id).order(:package_id, Sequel.desc(:timestamp)).where(result: "failed\n").count
		timed_out = Build.distinct(:package_id).order(:package_id, Sequel.desc(:timestamp)).where(result: "timed out\n").count

		erb :'overview/visualizations', locals: {
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
