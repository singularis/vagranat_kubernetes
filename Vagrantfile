Vagrant.configure("2") do |config|
  config.vm.box = "fedora/35-cloud-base"
  #config.vm.box = "carlosefr/centos-7"
  (1..3).each do |i|
    config.vm.define "worker#{i}" do |worker|
      worker.vm.network "private_network", ip: "192.168.60.11#{i}"
      worker.vm.hostname = "worker#{i}"
      worker.vm.provision "shell", inline: "swapoff -a"
      worker.vm.provision "shell", inline: $worker
      worker.vm.provision "shell", inline: $hosts
      worker.vm.provider "virtualbox" do |v|
        v.memory = 1024
        v.cpus = 1
        end
      end
    end
    config.vm.define "controller" do |controller|
      controller.vm.network "private_network", ip: "192.168.60.110"
      controller.vm.hostname = "controller"
      controller.vm.provision "shell", inline: "swapoff -a"
      controller.vm.provision "shell", inline: $controller
      controller.vm.provision "shell", inline: $hosts
      controller.vm.provider "virtualbox" do |v|
        v.memory = 2048
        v.cpus = 2
        end
      end
    end

$worker = <<-SCRIPT
echo "I am provisioning..."
sudo yum install git curl vim wget bash-completion etcd -y
git clone https://github.com/singularis/cka.git
cd cka
chmod +x setup-docker.sh 
sudo ./setup-docker.sh
chmod +x setup-kubetools.sh
sudo runuser -l vagrant -c 'sudo /home/vagrant/cka/setup-kubetools.sh'
usermod -aG docker vagrant
echo 'source <(kubectl completion bash)' >>~/.bashrc
kubectl completion bash >/etc/bash_completion.d/kubectl
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
echo 'source <(kubectl completion bash)' >>~/.bashrc
kubectl completion bash >/etc/bash_completion.d/kubectl
kubeadm init --pod-network-cidr=192.168.4.0/16 --apiserver-advertise-address=192.168.4.110
sudo runuser -l vagrant -c 'sudo mkdir -p /home/vagrant/.kube'
sudo runuser -l vagrant -c 'sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube'
sudo runuser -l vagrant -c 'sudo chown $(id -u):$(id -g)  /home/vagrant/.kube/config'
sudo kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
kubectl cluster-info 
SCRIPT

$hosts = <<-SCRIPT
cat >> /etc/hosts << EOF
{
192.168.60.110 contorl.example.com control
192.168.60.111 worker1.example.com worker1
192.168.60.112 worker2.example.com worker2
192.168.60.111 worker3.example.com worker3
  }
EOF
SCRIPT
