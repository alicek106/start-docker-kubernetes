#!/bin/bash -xe

KUBERNETES_VERSION="${kubernetes_version}"
KUBERNETES_CNI_VERSION="${kubernetes_cni_version}"

cat > /tmp/master.yaml << '__EOF_KUBEADM_SPEC'
${master_config}
__EOF_KUBEADM_SPEC

apt-get update
apt-get install -y apt-transport-https curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >/etc/apt/sources.list.d/kubernetes.list

wget -qO- get.docker.com | sh


if [ "$KUBERNETES_VERSION" = "latest" ]
then
  apt-get install -y kubelet kubeadm kubectl
else
  apt-get install -y kubelet=$KUBERNETES_VERSION \
    kubeadm=$KUBERNETES_VERSION \
    kubectl=$KUBERNETES_VERSION
fi

if [ "$KUBERNETES_CNI_VERSION" = "latest" ]
then
  apt-get install -y kubernetes-cni
else
  apt-get install -y kubernetes-cni=$KUBERNETES_CNI_VERSION
fi

# Set hostname for cloud provider
hostnamectl set-hostname $(curl http://169.254.169.254/latest/meta-data/local-hostname)

# Run kubeadm
kubeadm init \
  --config /tmp/master.yaml

# Prepare kubeconfig file for download to local machine
sudo mkdir -p /root/.kube
sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config
sudo chown root:root /root/.kube/config
