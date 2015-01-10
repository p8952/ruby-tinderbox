Vagrant.configure(2) do |config|
	config.vm.box = 'gentoo-amd64'
	config.vm.provision "shell", path: "conf/provision.sh"
	config.vm.provider :aws do |aws, override|
		config.vm.box_url = 'http://vagrant.p8952.info/gentoo-amd64-aws-1418910301.box'
		config.vm.synced_folder '.', '/vagrant', type: 'rsync', rsync__exclude: ['gentoo-x86/', 'web/'], :rsync_excludes => ['gentoo-x86/', 'web/']
		aws.instance_type = 't2.micro'
		aws.region = 'eu-west-1'
		aws.keypair_name = 'AWS-Key'
		override.ssh.username = 'ec2-user'
		override.ssh.private_key_path = '~/.ssh/AWS-Key.pem'
	end
end
