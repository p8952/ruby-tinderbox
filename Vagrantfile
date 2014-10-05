Vagrant.configure(2) do |config|
	config.vm.box = "gentoo-amd64"
	config.vm.box_url = "http://vagrant.p8952.info/31-JuL-2014-Gentoo-AMD64.box"
	config.vm.provider :aws do |aws, override|
		aws.instance_type = "t2.micro"
		aws.region = "eu-west-1"
		aws.keypair_name = "AWS-Key"
		override.ssh.username = "ec2-user"
		override.ssh.private_key_path = "~/.ssh/AWS-Key.pem"
	end
end
