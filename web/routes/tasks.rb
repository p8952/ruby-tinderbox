class RubyTinderbox < Sinatra::Base
	get '/new_targets' do
		update_timestamp = Package.first[:update_timestamp]
		portage_timestamp = Package.first[:portage_timestamp]
		packages = []
		Package.each do |package|
			build_current = package.build_dataset.where(target: 'current').reverse_order(:timestamp).first
			next if build_current.nil?

			build_next = package.build_dataset.where(target: 'next').reverse_order(:timestamp).first
			next if build_next.nil?

			repoman_current = package.repoman_dataset.where(target: 'current').reverse_order(:timestamp).first
			next if repoman_current.nil?

			repoman_next = package.repoman_dataset.where(target: 'next').reverse_order(:timestamp).first
			next if repoman_next.nil?

			if repoman_current[:result] == 'passed' || repoman_current[:result] == 'partial' && repoman_next[:result] == 'passed' || repoman_next[:result] == 'partial'
				packages << [package, build_current, build_next, repoman_current, repoman_next]
			end
		end
		packages = packages.compact.sort_by { |package| package[0][:identifier] }
		erb :new_targets, locals: { packages: packages, update_timestamp: update_timestamp, portage_timestamp: portage_timestamp }
	end
end
