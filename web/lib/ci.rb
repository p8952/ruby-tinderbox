def run_ci(docker_image, num_of_packages)
	packages = []
	Package.order { [category, lower(name), version] }.each do |package|
		packages << package[:identifier]
	end

	if num_of_packages == :all
		packages = packages
	elsif num_of_packages == :untested
		packages = []
		Package.exclude(tested: true).order { [category, lower(name), version] }.each do |package|
			packages << package[:identifier]
			next if [
				'virtual/rubygems',
				'dev-ruby/rake',
				'dev-ruby/rspec',
				'dev-ruby/rspec-core',
				'dev-ruby/rdoc'
			].include?("#{package[:category]}/#{package[:name]}")
			Package.where(Sequel.like(
				:dependencies,
				"#{package[:category]}/#{package[:name]} %",
				"% #{package[:category]}/#{package[:name]} %",
				"% #{package[:category]}/#{package[:name]}"
			)).each do |rdep|
				packages << rdep[:identifier]
			end
		end
	else
		packages = packages.sample(num_of_packages)
	end

	packages = packages.uniq
	packages.each do |package|
		docker_container = docker_image.run("/ruby-tinderbox/tinder.sh #{package}")
		docker_container.wait(36_000)

		tar = Tempfile.new('tar')
		File.open(tar, 'w') do |file|
			docker_container.copy('/ruby-tinderbox/ci-logs') do |chunk|
				file.write(chunk)
			end
		end
		Archive::Tar::Minitar.unpack(tar, File.dirname(File.expand_path(File.dirname(__FILE__))))
		tar.close
		tar.unlink

		docker_container.delete
	end

	update_timestamp = Time.now.to_i
	portage_timestamp = File.read('/usr/portage/metadata/timestamp.x').split.first
	Build.dataset.update(update_timestamp: update_timestamp)
	Build.dataset.update(portage_timestamp: portage_timestamp)
end

def update_ci
	Dir.glob('ci-logs/*/*/*') do |build|
		build_array = build.split('/')
		package_id = "#{build_array[1]}/#{build_array[2]}"
		time = build_array[3]

		if File.exist?("#{build}/succeeded")
			result = 'succeeded'
		elsif File.exist?("#{build}/failed")
			result = 'failed'
		elsif File.exist?("#{build}/timedout")
			result = 'timed out'
		end

		emerge_info = File.read("#{build}/emerge-info") if File.exist?("#{build}/emerge-info")
		emerge_pqv = File.read("#{build}/emerge-pqv") if File.exist?("#{build}/emerge-pqv")
		build_log = File.read("#{build}/build.log") if File.exist?("#{build}/build.log")
		gem_list = File.read("#{build}/gem-list") if File.exist?("#{build}/gem-list")

		Build.find_or_create(
			package_id: package_id,
			time: time,
			result: result,
			emerge_info: emerge_info,
			emerge_pqv: emerge_pqv,
			build_log: build_log,
			gem_list: gem_list
		)
	end
	Build.each do |build|
		Package.where(identifier: build[:package_id]).update(tested: true)
	end
end

def clear_ci
	Build.map(&:delete)
end
