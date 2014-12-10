def update_packages
	`sudo emerge --sync`
	packages_txt = `python3 lib/packages.py`
	Package.map(&:delete)
	packages_txt.lines.each do |line|
		category, name, version, revision, slot, r19_target, r20_target, r21_target = line.split(' ')
		gem_version = Gems.info(name)['version']
		gem_version = 'nil' if gem_version.nil?
		Package.find_or_create(
			category: category,
			name: name,
			version: version,
			revision: revision,
			slot: slot,
			identifier: category + '/' + name + '-' + version + (revision == 'r0' ? '' : "-#{revision}"),
			gem_version: gem_version,
			r19_target: r19_target,
			r20_target: r20_target,
			r21_target: r21_target
		)
	end
end