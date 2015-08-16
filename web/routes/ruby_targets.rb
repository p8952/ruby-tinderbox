class RubyTinderbox < Sinatra::Base
	get '/' do
		redirect to('/ruby_targets')
	end

	get '/ruby_targets' do
		update_timestamp = Package.first[:update_timestamp]
		portage_timestamp = Package.first[:portage_timestamp]
		packages = Package.distinct(:sha1, :identifier).order(:identifier)
		erb :ruby_targets, locals: { packages: packages, update_timestamp: update_timestamp, portage_timestamp: portage_timestamp }
	end
end
