def run_repoman(docker_image, num_of_packages)
	packages = []
	Package.order { [category, lower(name), version] }.each do |package|
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

		category = package[:category]
		name = package[:name]
		version = package[:version]
		revision = package[:revision] == 'r0' ? '' : "-#{package[:revision]}"

		packages << "#{category} #{name} #{version}#{revision} #{target} #{next_target}"
	end

	if num_of_packages == :all
		packages = packages
	else
		packages = packages.sample(num_of_packages)
	end

	packages = packages.uniq
	packages.each do |package|
		package = "'" + package + "'"
	end
	packages = packages.unshift('/ruby-tinderbox/repoman.sh')

	docker_container = docker_image.run(packages)
	docker_container.wait(36_000)

	tar = Tempfile.new('tar')
	File.open(tar, 'w') do |file|
		docker_container.copy('/ruby-tinderbox/repo-logs') do |chunk|
			file.write(chunk)
			puts chunk
		end
	end
	Archive::Tar::Minitar.unpack(tar, File.dirname(File.expand_path(File.dirname(__FILE__))))
	tar.close
	tar.unlink

	docker_container.delete
end

def update_repoman
	Dir.glob('repo-logs/*/*/*') do |repoman|
		repoman_array = repoman.split('/')
		package_id = "#{repoman_array[1]}/#{repoman_array[2]}"
		time = repoman_array[3]

		current_log = File.read("#{repoman}/current.txt") if File.exist?("#{repoman}/current.txt")
		next_log = File.read("#{repoman}/next.txt") if File.exist?("#{repoman}/next.txt")

		current_result = 'unknown'
		if current_log.include?('If everyone were like you, I\'d be out of business!')
			current_result = 'passed'
		elsif current_log.include?('You\'re only giving me a partial QA payment?')
			current_result = 'partial'
		elsif current_log.include?('Make your QA payment on time and you\'ll never see the likes of me.')
			current_result = 'failed'
		end

		next_result = 'unknown'
		if next_log.include?('If everyone were like you, I\'d be out of business!')
			next_result = 'passed'
		elsif next_log.include?('You\'re only giving me a partial QA payment?')
			next_result = 'partial'
		elsif next_log.include?('Make your QA payment on time and you\'ll never see the likes of me.')
			next_result = 'failed'
		end

		Repoman.find_or_create(
			package_id: package_id,
			time: time,
			current_result: current_result,
			current_log: current_log,
			next_result: next_result,
			next_log: next_log
		)
	end

	Package.order { [category, lower(name), version] }.each do |package|
		target = ''
		target = package[:r19_target] unless package[:r19_target] == 'nil'
		target = package[:r20_target] unless package[:r20_target] == 'nil'
		target = package[:r21_target] unless package[:r21_target] == 'nil'
		target = package[:r22_target] unless package[:r22_target] == 'nil'
		if target.empty?
			Repoman.where(package_id: package[:identifier]).delete
			next
		end

		next_target = ''
		next_target = 'ruby20' if target == 'ruby19'
		next_target = 'ruby21' if target == 'ruby20'
		next_target = 'ruby22' if target == 'ruby21'
		if next_target.empty?
			Repoman.where(package_id: package[:identifier]).delete
			next
		end
	end
end

def clear_repoman
	Repoman.map(&:delete)
end
