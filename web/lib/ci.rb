def run_ci(volume_container, ci_image, ci_type, num_of_packages)
	packages = generate_package_list(ci_type, num_of_packages)

	packages.peach(8) do |package|
		package = package.split(' ')
		identifier = package[0]
		current_target = package[1]
		next_target = package[2]

		if ci_type == 'build'
			cmd = %W[/ruby-tinderbox/tinder.sh #{identifier} #{current_target} #{next_target}]
		elsif ci_type == 'repoman'
			cmd = %W[/ruby-tinderbox/repoman.sh #{identifier} #{current_target} #{next_target}]
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

		target = 'unknown'
		target = package[:r19_target] unless package[:r19_target] == 'nil'
		target = package[:r20_target] unless package[:r20_target] == 'nil'
		target = package[:r21_target] unless package[:r21_target] == 'nil'
		target = package[:r22_target] unless package[:r22_target] == 'nil'

		next_target = 'unknown'
		next_target = 'ruby20' if target == 'ruby19'
		next_target = 'ruby21' if target == 'ruby20'
		next_target = 'ruby22' if target == 'ruby21'

		packages_with_targets << "#{package[:identifier]} #{target} #{next_target}"
	end

	packages_with_targets
end

def update_build
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

def update_repoman
	Dir.glob('ci-logs/*/*/repomans/*') do |repoman|
		begin
			repoman_array = repoman.split('/')
			sha1 = repoman_array[1]
			timestamp = repoman_array[4]
			target = repoman_array[2].sub('_target', '')

			log = File.read("#{repoman}/repoman_log")

			result = 'unknown'
			if log.include?('If everyone were like you, I\'d be out of business!')
				result = 'passed'
			elsif log.include?('You\'re only giving me a partial QA payment?')
				result = 'partial'
			elsif log.include?('Make your QA payment on time and you\'ll never see the likes of me.')
				result = 'failed'
			end

			package = Package.where(sha1: sha1).first
			unless package.nil?
				package.add_repoman(
					Repoman.find_or_create(
						timestamp: timestamp,
						target: target,
						result: result,
						log: log
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
