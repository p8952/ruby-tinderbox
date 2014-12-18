def run_ci(num_of_packages)
	packages = []
	Package.each do |package|
		packages << package[:identifier]
	end
	packages = packages.sample(num_of_packages) unless num_of_packages == 0

	begin
		instance, key_pair = start_instance
		file_path = File.dirname(File.dirname(File.expand_path(File.dirname(__FILE__))))

		Net::SCP.start(instance.ip_address, 'ec2-user', key_data: [key_pair.private_key]) do |scp|
			scp.upload!(file_path + '/conf', '/home/ec2-user', recursive: true)
			scp.upload!(file_path + '/tinder.sh', '/home/ec2-user/tinder.sh')
		end

		Net::SSH.start(instance.ip_address, 'ec2-user', key_data: [key_pair.private_key]) do |ssh|
			ssh.exec!('sudo /home/ec2-user/conf/provision.sh') do |_ch, _stream, data|
				puts data
			end
			ssh.exec!('sudo /home/ec2-user/tinder.sh ' + packages.join(' ')) do |_ch, _stream, data|
				puts data
			end
		end

		Net::SCP.start(instance.ip_address, 'ec2-user', key_data: [key_pair.private_key]) do |scp|
			scp.download!('/home/ec2-user/ci-logs', file_path + '/web', recursive: true)
		end
	rescue => e
		puts e
	ensure
		delete_instance(instance)
	end
end

def update_ci
	Dir.glob('ci-logs/*/*/*') do |build|
		build_array = build.split('/')
		package_id = "dev-ruby/#{build_array[2]}"
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
		environment = File.read("#{build}/environment") if File.exist?("#{build}/environment")

		Build.find_or_create(
			package_id: package_id,
			time: time,
			result: result,
			emerge_info: emerge_info,
			emerge_pqv: emerge_pqv,
			build_log: build_log,
			environment: environment
		)
	end
end

def clear_ci
	Build.map(&:delete)
end
