def run_repoman(ci_image, num_of_packages)
	packages = []
	Package.each do |package|
		target = ''
		target = package[:r19_target] unless package[:r19_target] == 'nil'
		target = package[:r20_target] unless package[:r20_target] == 'nil'
		target = package[:r21_target] unless package[:r21_target] == 'nil'
		target = package[:r22_target] unless package[:r22_target] == 'nil'
		next if target.empty?

		next_target = ''
		next_target = 'ruby20' if target == 'ruby19'
		next_target = 'ruby21' if target == 'ruby20'
		next_target = 'ruby22' if target == 'ruby21'
		next if next_target.empty?

		packages << "#{package[:identifier]} #{target} #{next_target}"
	end

	if num_of_packages == 'all'
		packages = packages
	elsif num_of_packages.is_a?(Integer)
		packages = packages.sample(num_of_packages)
	else
		puts 'ERROR: Invalid value for NUM_OF_PACKAGES'
		exit
	end

	packages = packages.uniq
	packages.peach(8) do |package|
		package = package.split(' ')
		identifier = package[0]
		current_target = package[1]
		next_target = package[2]
		ci_container = Docker::Container.create(
			Cmd: %W[/ruby-tinderbox/repoman.sh #{identifier} #{current_target} #{next_target}],
			Image: ci_image.id
		)
		ci_container.start
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

			Package.where(sha1: sha1).first.add_repoman(
				Repoman.find_or_create(
					timestamp: timestamp,
					target: target,
					result: result,
					log: log
				)
			)
		rescue => e
			puts "ERROR: #{e}"
			next
		end
	end
end

def clear_repoman
	Repoman.map(&:delete)
end
