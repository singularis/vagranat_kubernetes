Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  #config.vm.box = "carlosefr/centos-7"
  (1..4).each do |i|
    config.vm.define "worker#{i}" do |worker|
      worker.vm.network "private_network", ip: "192.168.60.11#{i}"
      worker.vm.hostname = "worker#{i}"
      worker.vm.provision "shell", inline: "sudo swapoff -a"
      worker.vm.provision "shell", inline: $worker_ubuntu
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
      controller.vm.provision "shell", inline: "sudo swapoff -a"
      controller.vm.provision "shell", inline: $controller_ubuntu
      controller.vm.provision "shell", inline: $hosts
      controller.vm.provider "virtualbox" do |v|
        v.memory = 2048
        v.cpus = 2
        end
      end
    end

$worker_fedora = <<-SCRIPT
echo "I am provisioning..."
swapoff -a
echo 1 > /proc/sys/net/ipv4/ip_forward
modprobe br_netfilter
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables
sudo sysctl -p
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo yum install git curl vim wget bash-completion etcd -y
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
systemctl enable --now docker.service 
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

$controller_fedora = <<-SCRIPT
echo "I am provisioning..."
swapoff -a
systemctl mask dev-zram0.swap
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
echo 1 > /proc/sys/net/ipv4/ip_forward
modprobe br_netfilter
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables
sudo sysctl -p
sudo yum install git curl vim wget bash-completion -y
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
systemctl enable --now docker.service 
git clone https://github.com/singularis/cka.git
cd cka
chmod +x setup-kubetools.sh
sudo runuser -l vagrant -c 'sudo /home/vagrant/cka/setup-kubetools.sh'
usermod -aG docker vagrant
echo 'source <(kubectl completion bash)' >>~/.bashrc
kubectl completion bash >/etc/bash_completion.d/kubectl
kubeadm init --pod-network-cidr=192.168.60.0/16 --apiserver-advertise-address=192.168.60.110
sudo runuser -l vagrant -c 'mkdir -p $HOME/.kube'
sudo runuser -l vagrant -c 'sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config'
sudo runuser -l vagrant -c 'sudo chown $(id -u):$(id -g) $HOME/.kube/config'
export KUBECONFIG=/etc/kubernetes/admin.conf
sudo runuser -l vagrant -c 'kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"'
kubectl cluster-info 
SCRIPT


$worker_ubuntu  = <<-SCRIPT
echo "I am provisioning..."
swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo apt-get install git curl vim wget bash-completion etcd -y
sudo systemctl stop apparmor
sudo systemctl disable apparmor
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
systemctl enable --now docker.service 
git clone https://github.com/sandervanvugt/cka
systemctl disable --now firewalld
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get -y update 
sudo apt-get -y upgrade 
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
usermod -aG docker vagrant
echo 'source <(kubectl completion bash)' >>~/.bashrc
kubectl completion bash >/etc/bash_completion.d/kubectl
SCRIPT

$controller_ubuntu = <<-SCRIPT
echo "I am provisioning..."
swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo apt-get install git curl vim wget bash-completion -y
sudo systemctl stop apparmor
sudo systemctl disable apparmor
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
systemctl enable --now docker.service 
git clone https://github.com/sandervanvugt/cka
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get -y update 
sudo apt-get -y upgrade 
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
usermod -aG docker vagrant
echo 'source <(kubectl completion bash)' >>~/.bashrc
kubectl completion bash >/etc/bash_completion.d/kubectl
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc
kubeadm init --pod-network-cidr=192.168.60.0/16 --apiserver-advertise-address=192.168.60.110
sudo runuser -l vagrant -c 'mkdir -p $HOME/.kube'
sudo runuser -l vagrant -c 'sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config'
sudo runuser -l vagrant -c 'sudo chown $(id -u):$(id -g) $HOME/.kube/config'
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
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