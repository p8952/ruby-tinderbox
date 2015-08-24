class RubyTinderbox < Sinatra::Base
	get '/new_targets' do
		update_timestamp = Package.first[:update_timestamp]
		portage_timestamp = Package.first[:portage_timestamp]
		packages = []
		Package.each do |package|
			build = package.build_dataset.reverse_order(:timestamp).first
			next if build.nil? || build[:result] != 'succeeded' || build[:result_next_target] != 'succeeded'

			repoman = package.repoman_dataset.reverse_order(:timestamp).first
			next if repoman.nil? || repoman[:result] != 'passed' || repoman[:result_next_target] != 'passed'

			packages << [package, build, repoman]
		end
		packages = packages.compact.sort_by { |package| package[0][:identifier] }
		erb :new_targets, locals: { packages: packages, update_timestamp: update_timestamp, portage_timestamp: portage_timestamp }
	end
end
