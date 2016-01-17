def run_ci(volume_container, ci_image, ci_type, num_of_packages)
	packages = generate_package_list(ci_type, num_of_packages)

	packages.peach(8) do |package|
		package = package.split(' ')
		identifier = package[0]
		next_target = package[1]

		if ci_type == 'build'
			cmd = %W(/ruby-tinderbox/tinder.sh #{identifier} #{next_target})
		elsif ci_type == 'repoman'
			cmd = %W(/ruby-tinderbox/repoman.sh #{identifier} #{next_target})
		end
		ci_container = Docker::Container.create(
			Cmd: cmd,
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

def generate_package_list(ci_type, num_of_packages)
	packages = []
	Package.each do |package|
		packages << package[:identifier]
	end

	if num_of_packages == 'all'
		packages = packages
	elsif num_of_packages == 'untested' && ci_type == 'repoman'
		packages = packages
	elsif num_of_packages == 'untested' && ci_type == 'build'
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
		puts ci_type
		puts num_of_packages
		exit
	end

	packages_with_targets = []
	packages.uniq.each do |package|
          package = Package.where(identifier: package).first
	  packages_with_targets << "#{package[:identifier]} #{package[:next_target]}"
	end

	packages_with_targets
end

def update_build(log_path)
	Dir.glob(log_path) do |build|
		begin
			build_array = build.split('/')
			build_array.shift(1) if build_array[1] == 'test-logs'
			sha1 = build_array[1]
			timestamp = build_array[2]

			result = File.read("#{build}/current/result").strip if File.exist?("#{build}/current/result")
			emerge_info = File.read("#{build}/current/emerge-info") if File.exist?("#{build}/current/emerge-info")
			emerge_pqv = File.read("#{build}/current/emerge-pqv") if File.exist?("#{build}/current/emerge-pqv")
			build_log = File.read("#{build}/current/build.log") if File.exist?("#{build}/current/build.log")
			gem_list = File.read("#{build}/current/gem-list") if File.exist?("#{build}/current/gem-list")

			result_next_target = File.read("#{build}/next_target/result").strip if File.exist?("#{build}/next_target/result")
			emerge_info_next_target = File.read("#{build}/next_target/emerge-info") if File.exist?("#{build}/next_target/emerge-info")
			emerge_pqv_next_target = File.read("#{build}/next_target/emerge-pqv") if File.exist?("#{build}/next_target/emerge-pqv")
			build_log_next_target = File.read("#{build}/next_target/build.log") if File.exist?("#{build}/next_target/build.log")
			gem_list_next_target = File.read("#{build}/next_target/gem-list") if File.exist?("#{build}/next_target/gem-list")

			package = Package.where(sha1: sha1).first
			unless package.nil?
				package.add_build(
					Build.find_or_create(
						timestamp: timestamp,
						result: result,
						emerge_info: emerge_info,
						emerge_pqv: emerge_pqv,
						build_log: build_log,
						gem_list: gem_list,
						result_next_target: result_next_target,
						emerge_info_next_target: emerge_info_next_target,
						emerge_pqv_next_target: emerge_pqv_next_target,
						build_log_next_target: build_log_next_target,
						gem_list_next_target: gem_list_next_target
					)
				)
			end
		rescue => e
			puts "ERROR: #{e}"
			next
		end
	end
end

def update_repoman(log_path)
	Dir.glob(log_path) do |repoman|
		begin
			repoman_array = repoman.split('/')
			repoman_array.shift(1) if repoman_array[1] == 'test-logs'
			sha1 = repoman_array[1]
			timestamp = repoman_array[2]

			log = File.read("#{repoman}/current/repoman_log") if File.exist?("#{repoman}/current/repoman_log")
			log_next_target = File.read("#{repoman}/next_target/repoman_log") if File.exist?("#{repoman}/next_target/repoman_log")

			result = 'unknown'
			if log.include?('If everyone were like you, I\'d be out of business!')
				result = 'passed'
			elsif log.include?('You\'re only giving me a partial QA payment?')
				result = 'partial'
			elsif log.include?('Make your QA payment on time and you\'ll never see the likes of me.')
				result = 'failed'
			end

			result_next_target = 'unknown'
			unless log_next_target.nil?
				if log_next_target.include?('If everyone were like you, I\'d be out of business!')
					result_next_target = 'passed'
				elsif log_next_target.include?('You\'re only giving me a partial QA payment?')
					result_next_target = 'partial'
				elsif log_next_target.include?('Make your QA payment on time and you\'ll never see the likes of me.')
					result_next_target = 'failed'
				end
			end

			package = Package.where(sha1: sha1).first
			unless package.nil?
				package.add_repoman(
					Repoman.find_or_create(
						timestamp: timestamp,
						result: result,
						log: log,
						result_next_target: result_next_target,
						log_next_target: log_next_target
					)
				)
			end
		rescue => e
			puts "ERROR: #{e}"
			next
		end
	end
end

def clear_build
	Build.map(&:delete)
end

def clear_repoman
	Repoman.map(&:delete)
end
