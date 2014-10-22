def package_update()

	packages = DB[:packages]
	packages.delete
	packages_txt = `python3 lib/packages.py`

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
	builds.delete

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
			else
				result = 'unknown'
			end

			builds.insert(
				:package_id => package_id,
				:time => time,
				:result => result,
			)
		end
	end

end
