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
	ensure
		delete_instance(instance)
	end
end

def ci_update
	builds = DB[:builds]

	DB.transaction do
		Dir.glob('ci-logs/*/*') do |build|
			next if File.file?(build)

			build_array = build.split('/')
			identifier = "dev-ruby/#{build_array[1]}"
			package_id = Package.filter(identifier: identifier).first[:id]
			time = build_array[2]

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

			builds.insert(
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
end
