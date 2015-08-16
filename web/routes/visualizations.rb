class RubyTinderbox < Sinatra::Base
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
