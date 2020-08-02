#!/bin/bash -xe

KUBERNETES_VERSION="${kubernetes_version}"
KUBERNETES_CNI_VERSION="${kubernetes_cni_version}"
HOSTNAME=$(curl http://169.254.169.254/latest/meta-data/local-hostname)

cat > /tmp/worker.yaml << '__EOF_KUBEADM_SPEC'
${worker_config}
__EOF_KUBEADM_SPEC

sed -i 's/NODE_HOSTNAME/'"$HOSTNAME"'/g' /tmp/worker.yaml

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

until $(curl --output /dev/null --silent --fail https://${apiserver_ip}:6443/healthz -k); do
    printf '.'
    sleep 5
done

echo "API Server is running!"

# Run kubeadm
kubeadm join \
  --config /tmp/worker.yaml
