#!/bin/bash

# remove comment if you want to enable debugging
#set -x

if [ -e /etc/redhat-release ] ; then
  REDHAT_BASED=true
fi

sudo useradd ubuntu
su ubuntu
cd ~

PACKER_VERSION="1.2.4"
# create new ssh key
[[ ! -f /home/ubuntu/.ssh/mykey ]] \
&& mkdir -p /home/ubuntu/.ssh \
&& ssh-keygen -f /home/ubuntu/.ssh/mykey -N '' \
&& chown -R ubuntu:ubuntu /home/ubuntu/.ssh 

# install packages
if [ ${REDHAT_BASED} ] ; then
  sudo yum -y update
  sudo yum install -y unzip wget git bashcompletion
  git clone https://github.com/sandervanvugt/kubernetes.git
  sudo cd kubernetes/
  sudo ./setup-docker.sh 
  sudo ./setup-kubetools.sh 
  kubeadm init
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  kubectl create -f https://docs.projectcalico.org/manifests/calico.yaml
else 
  sudo apt-get -y update
  sudo apt-get install -y unzip wget git bashcompletion
  sudo git clone https://github.com/sandervanvugt/kubernetes.git
  cd kubernetes/
  sudo ./setup-docker.sh 
  sudo ./setup-kubetools.sh 
  kubeadm init
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  kubectl create -f https://docs.projectcalico.org/manifests/calico.yaml
fi
# add docker privileges
usermod -G docker ubuntu

# clean up
if [ ! ${REDHAT_BASED} ] ; then
  apt-get clean
fi