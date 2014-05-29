Vagrant.configure(2) do |config|
	config.vm.box = "gentoo-amd64"
	config.vm.box_url = "http://vagrant.p8952.info/29-Apr-2014-Gentoo-AMD64.box"
	config.vm.provision "shell", inline: "cp /vagrant/res/make.conf /etc/portage/make.conf"
	config.vm.provision "shell", inline: "bash /vagrant/res/provision.sh"
end
