Vagrant.configure(2) do |config|
	config.vm.box = 'gentoo-amd64'

	config.vm.provider :virtualbox do |vbox|
		vbox.cpus = 2
		vbox.memory = 2048
	end

	config.vm.provider :aws do |aws, override|
		config.vm.box_url = 'https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box'
		config.vm.synced_folder '.', '/vagrant', type: 'rsync', rsync__exclude: ['gentoo-x86/', 'web/'], :rsync_excludes => ['gentoo-x86/', 'web/']
		aws.ami = 'ami-a355d3d4'
		aws.instance_type = 't2.micro'
		aws.region = 'eu-west-1'
		aws.keypair_name = 'AWS-Key'
		override.ssh.username = 'ec2-user'
		override.ssh.private_key_path = '~/.ssh/AWS-Key.pem'
	end

	config.vm.provision "shell", path: "conf/provision.sh"
end
