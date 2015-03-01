def update_packages
	packages_txt = `python3 lib/packages.py`
	packages_txt.lines.peach do |line|
		category, name, version, revision, slot, amd64_keyword, r19_target, r20_target, r21_target, r22_target = line.split(' ')
		identifier = category + '/' + name + '-' + version + (revision == 'r0' ? '' : "-#{revision}")
		gem_version = Gems.info(name)['version']
		gem_version = 'nil' if gem_version.nil?
		# ebuild = "/usr/portage/#{category}/#{name}/#{identifier.split('/')[1]}.ebuild"
		# ebuild_hash = Digest::MD5.hexdigest(File.read(ebuild))
		Package.find_or_create(
			category: category,
			name: name,
			version: version,
			revision: revision,
			slot: slot,
			amd64_keyword: amd64_keyword,
			identifier: identifier,
			gem_version: gem_version,
			r19_target: r19_target,
			r20_target: r20_target,
			r21_target: r21_target,
			r22_target: r22_target
		)
	end

	Package.peach(8) do |package|
		if packages_txt.include?("#{package[:category]} #{package[:name]} #{package[:version]} #{package[:revision]} #{package[:slot]} #{package[:amd64_keyword]} #{package[:r19_target]} #{package[:r20_target]} #{package[:r21_target]} #{package[:r22_target]}")
			package.update(dependencies: `python3 lib/deps.py #{package[:identifier]}`)
		else
			package.delete
		end
	end

	update_timestamp = Time.now.to_i
	portage_timestamp = File.read('/usr/portage/metadata/timestamp.x').split.first
	Package.dataset.update(update_timestamp: update_timestamp)
	Package.dataset.update(portage_timestamp: portage_timestamp)
end
