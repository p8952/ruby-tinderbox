class RubyTinderbox < Sinatra::Base
	get '/outdated_gems' do
		update_timestamp = Package.first[:update_timestamp]
		portage_timestamp = Package.first[:portage_timestamp]
		packages = Package.distinct(:category, :name).order(:category, :name, Sequel.desc(:version), Sequel.desc(:revision)).exclude(gem_version: 'nil')
		erb :outdated_gems, locals: { packages: packages, update_timestamp: update_timestamp, portage_timestamp: portage_timestamp  }
	end
end
