#!/bin/bash
# Script for OCI-ARM-CSP
##############################
# Instalation script for application servers

# Version 
# 12/27/2021 
# 1/3/2022 - change start of squid after instaltion from restart -> start
#  add note for server app1
# delete proxy entry fron dnf file
# update envirement proxy values
# add mc
# add coments to install mysql on app2,4
# add a variable for supportsshkey
# fixif condition fo rapp2, app4
# 1/8/2022 Mariusz - add reference to scripts which will perform isntalation
#   fix name of the sshd_config file
# 1/9/2022 Add selinux handling
# 1/12 - add share export and mount share from other servers.
# 1/15 - add installing MySQL server
# 2/5 - update oci cli installer to run without interaction
#       add rsa key generation, sharing and copy on ap2,3,4 to authrorized keys
# 2/5/22 udpate mysql instalation script path to full path, set to run at app2 and app4
# 2/13 - add change permission to root/ id_rsa files 
# 2/20 - add mysql instalation check 
#       - add else for installing mysql
# 3/6/22 update for VPS instalation 
#
#
#
##################
#Parameters 
##################
version=20220306.01

set -x
#export SUPORTPASS="OciSupp0rt6758)"
#export ROOTPASS="Edchjuy784576)"
export TIMEZONE=America/New_York
#SUPPORTPUBKEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEKd3NF56oAnOJMRGmGd/XLia2lSP6CHzXVW2adHhqo0znA8F6D3EBFAGyBPkp9N+6lfPVNNTdkRaxAdn6Lcy1aHQCTjCL1jbtbZHc3/nD5tIAeZuqb5c3uurHTRaqQSYxGvkSbBtFJfOEbatvO110VS7oE58CvEuAZTdE1czGQB/lg8xdnDvWcXDxyNvmYA8AdbwXAf/26KqIaawkTpE5VTdL1Ud2M81vnBHI5AwANZugdYiw2Y1ztKhScLSHdGtvx8nR409kk1NcDKliI6IZa9Z5Ox4WQlZiGsoy6uQ13CYEm4B+F8qg2OWE7yoLqxxnnj539q6FIozGo8A/jdDvnemdG6B7xaXeCWY4DesShpm/xacWUGfjVeSPU4NC/Appn5Y/G0AkNQ6359Ha8xT0Wep7LFUWMHaQWIGnL3hlgT+jwC88uIxwih8JM+O5HKprtnnEtlEBkuhRzcmT77DL14i8BFcNvLS2/BBlA+BYgCqR7ADD7K092xNt6aLQc6snkyGHI2OK9gLp9+/lWt/SvYX9cAVpPjaHNJ7quxH7PYQ/T3p3FwaPVSHg76fX0j/TMqevrjdG5lSsu+Mh44UsMfEymJJgP5LZSzzWPLM7Ol3BwbTRKhbsVzdaV+VVCtVgPPIY1n5vWwTsEfMtXEGaVVoOUftZgu/3+ZBwGCq/OQ== mariusz@mac"
#########

export DT=`date +%Y%m%d`

#disable firewall
systemctl disable firewalld
systemctl stop firewalld

#Create user and set support user 
groupadd -g 1099 support
useradd -u 1099 -g 1099 support
usermod -G adm support

#Chagne support user passwrod
#echo ${SUPORTPASS}
#echo ${SUPORTPASS} | passwd --stdin support

#Change root passwrod
#echo ${ROOTPASS}
#echo ${ROOTPASS} | passwd --stdin root

#add sudo access to support user 

#Add required directory
mkdir /var/log/audit.d
touch /var/log/audit.d/audit.log

mkdir ~/log

#delete proxy entry from dnf config file
sed -i '/^proxy=http/d' /etc/dnf/dnf.conf


echo "Execute configuration for app1 server"
#Oracle Linux

dnf -y update
dnf install -y oraclelinux-release-el8
dnf config-manager --set-enabled ol8_developer_EPEL
dnf clean all 

echo "This is app1 servers, install squid."
dnf -y install squid
chkconfig squid on
echo "Restart squid"
systemctl stop squid
systemctl start squid

#Update dnf.conf file - add proxy line
echo "proxy=http://10.10.1.11:3128" >>  /etc/dnf/dnf.conf
echo "" >>  /etc/dnf/dnf.conf

echo "Install required packages"
dnf install -y nginx php php-fpm php-mysqlnd php-json sendmail htop tmux mc rsync clamav clamav-update rclone setroubleshoot-server setools-console nfs-utils

#Setup web folder structure
mkdir -p /data/www/default/htdocs
dnf module list php
dnf -y module reset php
#set php 7.4 as default 
dnf -y module enable php:7.4
dnf module list php

#Add user opc to nginx group
usermod -G opc nginx

#PHP configuration 
echo "#Enable mysqli extension" >> /etc/php.ini
echo "extension=mysqli" >> /etc/php.ini
sed -i 's/user = apache/user = nginx/g' /etc/php-fpm.d/www.conf
sed -i 's/group = apache/group = nginx/g' /etc/php-fpm.d/www.conf


#If servers are app2 and app4 - install MySQL 
#mv /usr/share/nginx/html/* /data/www/default/htdocs
rm -fr /usr/share/nginx/html
ln -s /data/www/default/htdocs /usr/share/nginx/html
rm -f /data/www/default/htdocs/index.html

#Backup original configuration 
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.${DT}

#set local time
echo "Set timezone to America/New_York" 
timedatectl set-timezone ${TIMEZONE}

#Execute rsync process
echo "Rsync server files"
/home/opc/bin/rsync_server.sh

#Set permissions for file system
echo "Set permissions"
/home/opc/bin/set_permissions.sh

#set root crontab 
echo "Set root crontab"
/home/opc/bin/update_root_cron.sh

#get latest clamav definition
echo "Pull latest clamav configuration"
/usr/bin/freshclam

#Set NFS share 
mkdir /share
chmod 755 /share
touch /share/$HOSTNAME.txt


#Create clamav log foler 
mkdir -p /share/log/clamav

#set services to start automaticly
echo "Set auto startup of applications"
chkconfig nginx on
chkconfig sendmail on
chkconfig php-fpm on

#Load policy
# https://www.nginx.com/blog/using-nginx-plus-with-selinux/
# crate policy for php-fm
# ausearch -c 'php-fpm' --raw | audit2allow -M my-phpfpm

#SET enforcing for current session
echo "Set SELINUX permission for nginx to serve from /data/www folder"
setenforce 1
#sealert -a /var/log/audit.d/audit.log 
semodule -i /etc/selinux/nginx.pp
semodule -i /etc/selinux/my-phpfpm.pp

setsebool httpd_can_network_connect on
setsebool httpd_use_nfs on

# Change partition size 
# Decrease /var/oled and add to /root 6GB

# restart services
echo "Restart services"
/home/opc/bin/restart_services.sh now

#Install MySQL on app2 and app4
echo "-----"
echo "If this is app2 or app4 install MySQL server"
echo "Install MySQL server "
/home/opc/bin/03.server-instalation-mysql.sh


# Install oci tools as root
echo "----" 
echo "Install OCI tools"
mkdir /root/install
cd /root/install
wget https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh
mv install.sh oci_install.sh
chmod 700 oci_install.sh
./oci_install.sh --accept-all-defaults
rm -f ./oci_install.sh

#bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh) --accept-all-defaults"


#Ceate rsa key for oci
mkdir ~/.oci
cd ~/.oci
#openssl genrsa -out ~/.oci/oci_api_key.pem -aes128 2048   
#no passphrase 
openssl genrsa -out ~/.oci/oci_api_key.pem 2048   
chmod go-rwx ~/.oci/oci_api_key.pem  
openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem 

#Install Certboot
echo "-----"
echo "Install Certboot"
python -m ensurepip --upgrade
get-pip.py
pip3 install certbot

#Create a root rsa key 
ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa_rsync  -q -N ""
cp ~/.ssh/id_rsa_rsync.pub /share/root_app1_id_rsa_rsync.pub
chown 600 ~/.ssh/*

date >> /tmp/instalation-script.txt
echo "Instalation script completed " >> /tmp/instalation-script.txt

#test website up
echo -e "\n-----"
echo "curl -v http://localhost/health-check.php"
echo "\n-----"
curl -v http://localhost/health-check.php

echo ""
echo "-----    Version 02.server-instalation-script-app.sh: ${version}    -----"
echo ""

exit

