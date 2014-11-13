def ci_run(num_of_packages)

	packages = []

	Package.each do |package|
		packages << File.basename(package[:identifier])
	end

	unless num_of_packages == 0
		packages = packages.sample(num_of_packages)
	end

	begin
		ec2 = AWS::EC2.new(:ec2_endpoint => 'ec2.eu-west-1.amazonaws.com')
		ami_id = ec2.images.tagged('genstall').to_a.sort_by(&:name).last.id
		key_pair = ec2.key_pairs.create("ruby-sdk-#{Time.now.to_i}")

		instance = ec2.instances.create(
			:image_id => ami_id,
			:instance_type => 't2.micro',
			:count => 1,
			:security_groups => 'default',
			:key_pair => key_pair
		)

		begin
			sleep 5
			Net::SSH.start(instance.ip_address, 'ec2-user', :key_data => [key_pair.private_key]) do |ssh|
				ssh.exec!('uname -a') do |ch, stream, data|
					puts data
				end
			end
		rescue SystemCallError, Timeout::Error => e
			puts e
			retry
		end

		file_path = File.dirname(File.dirname(File.expand_path(File.dirname(__FILE__))))

		Net::SCP.start(instance.ip_address, 'ec2-user', :key_data => [key_pair.private_key]) do |scp|
			scp.upload!(file_path + '/conf', '/home/ec2-user', :recursive => true)
			scp.upload!(file_path + '/tinder.sh', '/home/ec2-user/tinder.sh')
		end

		Net::SSH.start(instance.ip_address, 'ec2-user', :key_data => [key_pair.private_key]) do |ssh|
			ssh.exec!('sudo /home/ec2-user/conf/provision.sh') do |ch, stream, data|
				puts data
			end
			ssh.exec!('sudo /home/ec2-user/tinder.sh ' + packages.join(' ')) do |ch, stream, data|
				puts data
			end
		end

		Net::SCP.start(instance.ip_address, 'ec2-user', :key_data => [key_pair.private_key]) do |scp|
			scp.download!('/home/ec2-user/ci-logs', file_path + '/web', :recursive => true)
		end

	rescue => e
		puts e
	ensure
		instance.delete
		key_pair.delete
	end

end
