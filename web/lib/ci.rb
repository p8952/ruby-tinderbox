def run_ci(volume_container, ci_image, num_of_packages)
	packages = []
	Package.each do |package|
		packages << package[:identifier]
	end

	if num_of_packages == 'all'
		packages = packages
	elsif num_of_packages == 'untested'
		packages = []
		Package.each do |package|
			next if package.build.count > 0
			next if "#{package[:category]}/#{package[:name]}" == 'virtual/rubygems'
			next if "#{package[:category]}/#{package[:name]}" == 'dev-ruby/rake'
			next if "#{package[:category]}/#{package[:name]}" == 'dev-ruby/rspec'
			next if "#{package[:category]}/#{package[:name]}" == 'dev-ruby/rspec-core'
			next if "#{package[:category]}/#{package[:name]}" == 'dev-ruby/rdoc'

			packages << package[:identifier]
			Package.where(Sequel.like(
				:dependencies,
				"#{package[:category]}/#{package[:name]} %",
				"% #{package[:category]}/#{package[:name]} %",
				"% #{package[:category]}/#{package[:name]}"
			)).each do |rdep|
				packages << rdep[:identifier]
			end
		end
	elsif num_of_packages.is_a?(Integer)
		packages = packages.sample(num_of_packages)
	else
		puts 'ERROR: Invalid value for NUM_OF_PACKAGES'
		exit
	end

	packages = packages.uniq
	packages.each do |package|
		ci_container = Docker::Container.create(
			Cmd: %W[/ruby-tinderbox/tinder.sh #{package}],
			Image: ci_image.id
		)
		ci_container.start(VolumesFrom: volume_container.id)
		ci_container.wait(36_000)

		tar = Tempfile.new('tar')
		File.open(tar, 'w') do |file|
			ci_container.copy('/ruby-tinderbox/ci-logs') do |chunk|
				file.write(chunk)
			end
		end
		Archive::Tar::Minitar.unpack(tar, File.dirname(File.expand_path(File.dirname(__FILE__))))
		tar.close
		tar.unlink

		ci_container.delete
	end
end

def update_ci
	Dir.glob('ci-logs/*/*/builds/*') do |build|
		begin
			build_array = build.split('/')
			sha1 = build_array[1]
			timestamp = build_array[4]
			target = build_array[2].sub('_target', '')

			result = File.read("#{build}/result")
			emerge_info = File.read("#{build}/emerge-info") if File.exist?("#{build}/emerge-info")
			emerge_pqv = File.read("#{build}/emerge-pqv") if File.exist?("#{build}/emerge-pqv")
			build_log = File.read("#{build}/build.log") if File.exist?("#{build}/build.log")
			gem_list = File.read("#{build}/gem-list") if File.exist?("#{build}/gem-list")

			package = Package.where(sha1: sha1).first
			unless package.nil?
				package.add_build(
					Build.find_or_create(
						timestamp: timestamp,
						target: target,
						result: result,
						emerge_info: emerge_info,
						emerge_pqv: emerge_pqv,
						build_log: build_log,
						gem_list: gem_list
					)
				)
			end
		rescue => e
			puts "ERROR: #{e}"
			next
		end
	end
end

def clear_ci
	Build.map(&:delete)
end
