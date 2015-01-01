def update_packages
	packages_txt = `python3 lib/packages.py`
	packages_txt.lines.peach do |line|
		category, name, version, revision, slot, amd64_keyword, r19_target, r20_target, r21_target = line.split(' ')
		identifier = category + '/' + name + '-' + version + (revision == 'r0' ? '' : "-#{revision}") + (slot == '0' ? '' : ":#{slot}")
		gem_version = Gems.info(name)['version']
		gem_version = 'nil' if gem_version.nil?
		#ebuild = "/usr/portage/#{category}/#{name}/#{identifier.split('/')[1].split(':')[0]}.ebuild"
		#ebuild_hash = Digest::MD5.hexdigest(File.read(ebuild))
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
		)
	end

	Package.each do |package|
		unless packages_txt.include?("#{package[:category]} #{package[:name]} #{package[:version]} #{package[:revision]}")
			package.delete
		end
	end
end
