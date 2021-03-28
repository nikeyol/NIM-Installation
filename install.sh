#!/usr/bin/env bash

# change time zone
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
timedatectl set-timezone Asia/Shanghai
rm /etc/yum.repos.d/CentOS-Base.repo
cp /vagrant/yum/*.* /etc/yum.repos.d/
mv /etc/yum.repos.d/CentOS7-Base-163.repo /etc/yum.repos.d/CentOS-Base.repo

yum install -y curl wget jq envsubst awk bash getent grep gunzip less openssl sed tar base64 basename cat dirname head id mkdir numfmt sort tee net-tools

echo 'set host name resolution'
cat >> /etc/hosts <<EOF
172.17.10.201 NIM1
172.17.10.202 NIM2
172.17.10.203 NIM3
EOF

cat /etc/hosts

echo 'set nameserver'
echo "nameserver 8.8.8.8">/etc/resolv.conf
cat /etc/resolv.conf

echo 'disable swap'
swapoff -a
sed -i '/swap/s/^/#/' /etc/fstab

# disable firewall
setenforce 0


if [[ $1 -eq 1 ]]
then
# copy certificate
mkdir /etc/ssl/nginx
cp /vagrant/certificate/* /etc/ssl/nginx

# install the ca certificate dependency
yum install -y ca-certificates

# install n+ repo
wget -P /etc/yum.repos.d https://cs.nginx.com/static/files/nginx-plus-7.4.repo
yum install -y nginx-plus
systemctl enable nginx.service
service nginx start


# install nim agent
cp -f /vagrant/certificate/nginx-nim-repo.crt /etc/ssl/nginx/nginx-repo.crt
cp -f /vagrant/certificate/nginx-nim-repo.key /etc/ssl/nginx/nginx-repo.key
wget -P /etc/yum.repos.d https://cs.nginx.com/static/files/instance-manager.repo
curl -o /tmp/nginx_signing.key https://nginx.org/keys/nginx_signing.key
rpmkeys --import /tmp/nginx_signing.key

yum install -y nginx-agent

cp /vagrant/nimconfig/nginx-agent.conf /etc/nginx-agent/nginx-agent.conf

systemctl start nginx-agent
systemctl enable nginx-agent

fi
if [[ $1 -eq 2 ]]
then
# Copy repo file
cp /vagrant/repo/* /etc/yum.repos.d/
# Install N OSS
yum install -y nginx
yum install -y nginx-agent
# start N OSS
nginx 

# copy certificate
mkdir /etc/ssl/nginx
cp /vagrant/certificate/* /etc/ssl/nginx

# install the ca certificate dependency
yum install -y ca-certificates

# install nim agent
cp -f /vagrant/certificate/nginx-nim-repo.crt /etc/ssl/nginx/nginx-repo.crt
cp -f /vagrant/certificate/nginx-nim-repo.key /etc/ssl/nginx/nginx-repo.key
wget -P /etc/yum.repos.d https://cs.nginx.com/static/files/instance-manager.repo
curl -o /tmp/nginx_signing.key https://nginx.org/keys/nginx_signing.key
rpmkeys --import /tmp/nginx_signing.key

yum install -y nginx-agent

cp /vagrant/nimconfig/nginx-agent.conf /etc/nginx-agent/nginx-agent.conf

systemctl start nginx-agent
systemctl enable nginx-agent


fi

if [[ $1 -eq 3 ]]
then
# install NIM
mkdir /etc/ssl/nginx
cp /vagrant/certificate/nginx-nim-repo.crt /etc/ssl/nginx/nginx-repo.crt
cp /vagrant/certificate/nginx-nim-repo.key /etc/ssl/nginx/nginx-repo.key
yum install -y ca-certificates
wget -P /etc/yum.repos.d https://cs.nginx.com/static/files/instance-manager.repo
curl -o /tmp/nginx_signing.key https://nginx.org/keys/nginx_signing.key
rpmkeys --import /tmp/nginx_signing.key
yum install -y nginx-manager
# copy config file
mkdir -p /etc/nginx-manager/
cp /vagrant/nimconfig/* /etc/nginx-manager/
# enable NIM service
systemctl enable nginx-manager
# start NIM
systemctl start nginx-manager
fi
