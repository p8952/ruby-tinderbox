class RubyTinderbox < Sinatra::Base
	get '/repoman_checks' do
		update_timestamp = Build.order(:timestamp).last[:timestamp]
		portage_timestamp = Package.first[:portage_timestamp]
		repomans = []
		Package.each do |package|
			repomans << package.repoman_dataset.where(target: 'current').reverse_order(:timestamp).first
		end
		repomans = repomans.compact.sort_by { |repoman| repoman.package[:identifier] }
		erb :repoman_checks, locals: { repomans: repomans, update_timestamp: update_timestamp, portage_timestamp: portage_timestamp  }
	end

	get '/repoman_checks/:sha1' do
		package = Package.where(sha1: params[:sha1]).first
		repomans = package.repoman_dataset.where(target: 'current').reverse_order(:timestamp)
		erb :repoman_checks_sha1, locals: { repomans: repomans }
	end

	get '/repoman_checks/:sha1/:timestamp' do
		package = Package.where(sha1: params[:sha1]).first
		repoman = package.repoman_dataset.where(timestamp: params[:timestamp]).first
		erb :repoman_checks_sha1_timestamp, locals: { package: package, repoman: repoman }
	end
end
