class RubyTinderbox < Sinatra::Base
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

	get '/build_status/:sha1' do
		package = Package.where(sha1: params[:sha1]).first
		builds = package.build_dataset.where(target: 'current').reverse_order(:timestamp)
		erb :'build/build_history', locals: { builds: builds }
	end

	get '/build_status/:sha1/:timestamp' do
		package = Package.where(sha1: params[:sha1]).first
		build = package.build_dataset.where(timestamp: params[:timestamp]).first
		erb :'build/build_logs', locals: { package: package, build: build }
	end
end
