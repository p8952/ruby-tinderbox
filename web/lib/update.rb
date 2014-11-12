def package_update()

	`sudo emerge --sync`
	packages_txt = `python3 lib/packages.py`
	packages = DB[:packages]
	packages.delete

	DB.transaction do
		packages_txt.lines.peach do |line|
			category, name, version, revision, slot, r19_target, r20_target, r21_target = line.split(' ')
			gem_version = Gems.info(name)['version']
			packages.insert(
				:category => category,
				:name => name,
				:version => version,
				:revision => revision,
				:slot => slot,
				:identifier => category + '/' + name + '-' + version + (revision == "r0" ? "" : "-#{revision}"),
				:gem_version => gem_version,
				:r19_target => r19_target,
				:r20_target => r20_target,
				:r21_target => r21_target,
			)
		end
	end
end

def ci_update()

	builds = DB[:builds]

	DB.transaction do
		Dir.glob('ci-logs/*/*') do |build|
			next if File.file?(build)

			build_array = build.split('/')
			identifier = "dev-ruby/#{build_array[1]}"
			package_id = Package.filter(:identifier => identifier).first[:id]
			time = build_array[2]

			if File.exists?("#{build}/succeeded")
				result = 'succeeded'
			elsif File.exists?("#{build}/failed")
				result = 'failed'
				emerge_info = File.read("#{build}/emerge-info") if File.exists?("#{build}/emerge-info")
				emerge_pqv = File.read("#{build}/emerge-pqv") if File.exists?("#{build}/emerge-pqv")
				build_log = File.read("#{build}/build.log") if File.exists?("#{build}/build.log")
				environment = File.read("#{build}/environment") if File.exists?("#{build}/environment")
			elsif File.exists?("#{build}/timedout")
				result = 'timed out'
			end

			next unless builds.where(:package_id => package_id, :time => time).nil?

			builds.insert(
				:package_id => package_id,
				:time => time,
				:result => result,
				:emerge_info => emerge_info,
				:emerge_pqv => emerge_pqv,
				:build_log => build_log,
				:environment => environment,
			)
		end
	end

end
