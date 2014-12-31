def ec2
	ec2 = AWS::EC2.new(
		access_key_id: ENV['AWS_ACCESS_KEY'],
		secret_access_key: ENV['AWS_SECRET_KEY'],
		region: 'eu-west-1'
	)
	ec2
end

def start_instance
	security_group = nil
	if ec2.security_groups.filter('group-name', 'ruby-tinderbox').first.nil?
		security_group = ec2.security_groups.create('ruby-tinderbox')
		security_group.authorize_ingress(:any, '0.0.0.0/0')
	else
		security_group = ec2.security_groups.filter('group-name', 'ruby-tinderbox').first
	end

	ami_id = ec2.images.tagged('genstall').to_a.sort_by(&:name).last.id
	key_pair = ec2.key_pairs.create("ruby-tinderbox-#{Time.now.to_i}")
	instance = ec2.instances.create(
		image_id: ami_id,
		instance_type: 't2.micro',
		count: 1,
		security_group_ids: security_group.id,
		key_pair: key_pair
	)
	instance.add_tag('ruby-tinderbox')
	sleep 5 while instance.status != :running

	begin
		Net::SSH.start(instance.ip_address, 'ec2-user', key_data: [key_pair.private_key])
	rescue SystemCallError, Timeout::Error => e
		puts e
		sleep 5
		retry
	end

	return instance, key_pair
end

def delete_instance(instance)
	return if instance.status != :running
	instance.key_pair.delete
	instance.delete
end
