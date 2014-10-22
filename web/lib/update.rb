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

	packages = DB[:packages]

	Dir.glob('ci-logs/*') do |dir|
		next if File.file?(dir)
		identifier = File.basename(dir)
		puts Package
	end
end
