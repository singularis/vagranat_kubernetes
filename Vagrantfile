Vagrant.configure(2) do |config|
  #config.vm.box = "centos/7"
  config.vm.box = "carlosefr/centos-7"
	config.vm.define "controller" do |controller|
  (1..2).each do |i|
    config.vm.define "worker#{i}" do |node|
    config.vm.network "private_network", ip: "192.168.111.#{i+1}"
    config.vm.hostname = "worker#{i}"
    config.vm.provision "shell", inline: "swapoff -a"
    config.vm.provision "shell", path: "scripts/worker.sh"
    config.vm.provider "virtualbox" do |v|
      v.memory = 1024
      v.cpus = 1
        end
    end
  end
    controller.vm.network "private_network", ip: "192.168.111.1"
    controller.vm.hostname = "controller"
    config.vm.provision "shell", inline: "swapoff -a"
    controller.vm.provision "shell", path: "scripts/controller.sh"
    controller.vm.provider "virtualbox" do |v|
    	v.memory = 2048
    	v.cpus = 2
    	end
    end
end