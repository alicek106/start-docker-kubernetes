FROM ubuntu:14.04
MAINTAINER alice_k106@naver.com
RUN apt-get update && apt-get install -y nfs-common \ 
	nfs-kernel-server \
	rpcbind
RUN mkdir /home/nfs_server && chmod 777 /home/nfs_server
ADD nfs-kernel-server /etc/defaults/nfs-kernel-server
ADD options /etc/modprobe.d/options 
ADD services /etc/services
ADD exports_example /etc/exports
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT /entrypoint.sh
