Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  #config.vm.box = "carlosefr/centos-7"
  (1..3).each do |i|
    config.vm.define "worker#{i}" do |worker|
      worker.vm.network "private_network", ip: "192.168.4.11#{i}"
      worker.vm.hostname = "worker#{i}"
      worker.vm.provision "shell", inline: "swapoff -a"
      worker.vm.provision "shell", path: "scripts/worker.sh"
      worker.vm.provision "shell", inline: $worker
      worker.vm.provider "virtualbox" do |v|
        v.memory = 1024
        v.cpus = 1
        end
      end
    end
    config.vm.define "controller" do |controller|
      controller.vm.network "private_network", ip: "192.168.4.110"
      controller.vm.hostname = "controller"
      controller.vm.provision "shell", inline: "swapoff -a"
      controller.vm.provision "shell", path: "scripts/controller.sh"
      controller.vm.provision "shell", inline: $controller
      controller.vm.provider "virtualbox" do |v|
        v.memory = 2048
        v.cpus = 1
        end
      end
    end

$worker = <<-SCRIPT
echo "I am provisioning..."
sudo yum install git curl vim wget bash-completion -y
git clone https://github.com/singularis/cka.git
cd cka
chmod +x setup-docker.sh 
sudo ./setup-docker.sh
chmod +x setup-kubetools.sh
sudo runuser -l vagrant -c 'sudo /home/vagrant/cka/setup-kubetools.sh'
usermod -aG docker vagrant
SCRIPT

$controller = <<-SCRIPT
echo "I am provisioning..."
sudo yum install git curl vim wget bash-completion -y
git clone https://github.com/singularis/cka.git
cd cka
chmod +x setup-docker.sh 
sudo ./setup-docker.sh
chmod +x setup-kubetools.sh
sudo runuser -l vagrant -c 'sudo /home/vagrant/cka/setup-kubetools.sh'
usermod -aG docker vagrant
kubeadm init
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kube cluster info
SCRIPT