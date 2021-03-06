def update_packages(ci_image)
	cmd = %w(/ruby-tinderbox/packages.py)
	ci_container = Docker::Container.create(
		Cmd: cmd,
		Image: ci_image.id
	)
	ci_container.start
	ci_container.wait(36_000)
	packages_txt = ci_container.streaming_logs(stdout: true)
	ci_container.delete

	packages_txt = packages_txt.lines.sort.uniq
	packages_txt.each do |line|
		next if line.empty?
		sha1, category, name, version, revision, slot, amd64_keyword, r20_target, r21_target, r22_target, r23_target = line.split(' ')

		identifier = category + '/' + name + '-' + version + (revision == 'r0' ? '' : "-#{revision}")

		gem_version = Gems.info(name)['version']
		gem_version = 'nil' if gem_version.nil?

		next_target = 'nil'
		next_target = 'ruby21' if r20_target == 'ruby20' && r21_target == 'nil'
		next_target = 'ruby22' if r21_target == 'ruby21' && r22_target == 'nil'
		next_target = 'ruby23' if r22_target == 'ruby22' && r23_target == 'nil'

		package = Package.find_or_create(
			sha1: sha1,
			category: category,
			name: name,
			version: version,
			revision: revision,
			slot: slot,
			identifier: identifier,
			amd64_keyword: amd64_keyword,
			r20_target: r20_target,
			r21_target: r21_target,
			r22_target: r22_target,
			r23_target: r23_target,
			next_target: next_target,
			gem_version: gem_version
		)
		deps = line.split(' ').drop(11).join.gsub(';', ' ')
		package.update(dependencies: deps)
	end

	Package.peach(8) do |package|
		unless packages_txt.find { |sha1| /^#{package[:sha1]}/ =~ sha1 }
			package.build.map(&:delete)
			package.repoman.map(&:delete)
			package.delete
		end
	end

	update_timestamp = Time.now.to_i
	portage_timestamp = File.read('/usr/portage/metadata/timestamp.x').split.first
	Package.dataset.update(update_timestamp: update_timestamp)
	Package.dataset.update(portage_timestamp: portage_timestamp)
end

def clear_packages
	Package.each do |package|
		package.build.map(&:delete)
		package.repoman.map(&:delete)
		package.delete
	end
end
