#!/bin/bash
# Instalation script for application servers

# Version 
# 12/27/2021 
# 1/3/2022 - change start of squid after instaltion from restart -> start
#  add note for server app1
# delete proxy entry fron dnf file
# update envirement proxy values
# add mc
#

##################
#Parameters 
##################

SUPORTPASS="OciSupp0rt6758)"
ROOTPASS="Edchjuy784576&"

#########
#disable firewall
systemctl disable firewalld
systemctl stop firewalld

#Create user and set support user 
groupadd -g 1099 support
useradd -u 1099 -g 1099 support
mkdir -p /home/support/.ssh
echo  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEKd3NF56oAnOJMRGmGd/XLia2lSP6CHzXVW2adHhqo0znA8F6D3EBFAGyBPkp9N+6lfPVNNTdkRaxAdn6Lcy1aHQCTjCL1jbtbZHc3/nD5tIAeZuqb5c3uurHTRaqQSYxGvkSbBtFJfOEbatvO110VS7oE58CvEuAZTdE1czGQB/lg8xdnDvWcXDxyNvmYA8AdbwXAf/26KqIaawkTpE5VTdL1Ud2M81vnBHI5AwANZugdYiw2Y1ztKhScLSHdGtvx8nR409kk1NcDKliI6IZa9Z5Ox4WQlZiGsoy6uQ13CYEm4B+F8qg2OWE7yoLqxxnnj539q6FIozGo8A/jdDvnemdG6B7xaXeCWY4DesShpm/xacWUGfjVeSPU4NC/Appn5Y/G0AkNQ6359Ha8xT0Wep7LFUWMHaQWIGnL3hlgT+jwC88uIxwih8JM+O5HKprtnnEtlEBkuhRzcmT77DL14i8BFcNvLS2/BBlA+BYgCqR7ADD7K092xNt6aLQc6snkyGHI2OK9gLp9+/lWt/SvYX9cAVpPjaHNJ7quxH7PYQ/T3p3FwaPVSHg76fX0j/TMqevrjdG5lSsu+Mh44UsMfEymJJgP5LZSzzWPLM7Ol3BwbTRKhbsVzdaV+VVCtVgPPIY1n5vWwTsEfMtXEGaVVoOUftZgu/3+ZBwGCq/OQ== mariusz@mac" > /home/support/.ssh/authorized_keys
echo " " >> /home/support/.ssh/authorized_keys
chmod 700 /home/support/.ssh
chmod 640 /home/support/.ssh/authorized_keys
chown -R support:support /home/support
usermod -G adm support

#Chagne support user passwrod
echo ${SUPORTPASS} | passwd --stdin support

#Change root passwrod
echo ${ROOTPASS} | passwd --stdin root

#add sudo access to support user 
echo "support ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/050_support
#echo "support ALL=(ALL) ALL" > /etc/sudoers.d/050_support
chmod 440  /etc/sudoers.d/050_support

#If server is app1 - install squid proxy
# This server has to be setup first in group of 4 servers 

#delete proxy entry from dnf config file
sed -i '/^proxy=http/d' /etc/dnf/dnf.conf

echo "Hostname: $HOSTNAME"
if [[ "$HOSTNAME" == *"app1"* ]]; then
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
else 
  #Update dnf.conf file - add proxy line, All servers need to connect throw proxy server
  echo "proxy=http://10.10.1.11:3128" >>  /etc/dnf/dnf.conf
  echo "" >>  /etc/dnf/dnf.conf
  dnf -y update
  dnf install -y oraclelinux-release-el8
  dnf config-manager --set-enabled ol8_developer_EPEL
  dnf clean all 
fi


echo "Install required packages"
dnf install -y nginx php php-fpm php-mysqlnd php-json
dnf install -y wget sendmail mc htop tmux mc
dnf install -y rsync
dnf install -y clamav clamav-update 
dnf install -y perl-CPAN
dnf install -y perl-libwww-perl.noarch 
dnf install -y perl-LWP-Protocol-https.noarch 
dnf install -y perl-GDGraph 
dnf install -y perl-Math-BigInt.noarch


mkdir -p /data/www/default/htdocs
dnf module list php
dnf -y module reset php
dnf -y module enable php:7.4
dnf module list php

#If servers are app2 and app4 - install MySQL 

mv /usr/share/nginx/html/* /data/www/default/htdocs
rm -fr /usr/share/nginx/html
ln -s /data/www/default/htdocs /usr/share/nginx/html
rm -f /data/www/default/htdocs/index.html
echo "<html><body>site is up<br>" > /data/www/default/htdocs/test.html
echo $HOSTNAME >> /data/www/default/htdocs/test.html
echo "</body></html>" >> /data/www/default/htdocs/test.html

echo "1" > /data/www/default/htdocs/health-check.html
echo "<?php phpinfo(); ?>" > /data/www/default/htdocs/info.php
chown -R nginx:nginx /data/www/
#security
find /data/www -type d -exec chmod 750 {} \;
find /data/www -type f -exec chmod 640 {} \;

#Update selinux to allow nginx from different directory

#Update envirement 
 
echo "export PS1='\u@\h:\w\n#'" > /etc/profile.d/custom.sh
echo "export PATH=$PATH:$HOME/bin" >> /etc/profile.d/custom.sh
#SEt proxy servers in profile 
echo "export http_proxy=http://10.10.1.11:3128/" >> /etc/profile.d/custom.sh
echo "export https_proxy=http://10.10.1.11:3128/" >> /etc/profile.d/custom.sh
echo "export no_proxy=" >> /etc/profile.d/custom.sh
. /etc/profile 

#Install CSF
mkdir /root/install
cd /root/install 
wget -e https_proxy=10.10.1.11:3128  https://download.configserver.com/csf.tgz
tar xzvf csf.tgz

cd /root/install/csf
./install.sh

#update configuration
cd /etc/csf
cp csf.conf csf.conf.org
sed -i 's/TESTING = "1"/TESTING = "0"/g' csf.conf
sed -i 's/TCP_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995"/TCP_IN = "22,80,3306,3128"/g' csf.conf
sed -i 's/TCP_OUT = "20,21,22,25,53,80,110,113,443,587,993,995"/TCP_OUT = "25,53,80,113,443,3306,3128"/g' csf.conf
sed -i 's/UDP_IN = "20,21,53,80,443"/UDP_IN = ""/g' csf.conf
sed -i 's/UDP_OUT = "20,21,53,113,123"/UDP_OUT = "53,113,123"/g' csf.conf


#PHP configuration 
echo "#Enable mysqli extension" >> /etc/php.ini
echo "extension=mysqli" >> /etc/php.ini
sed -i 's/user = apache/user = nginx/g' /etc/php-fpm.d/www.conf
sed -i 's/group = apache/group = nginx/g' /etc/php-fpm.d/www.conf

#Update SElinux 
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
setenforce 0

#set local time 
timedatectl set-timezone America/New_York

#Update for SSH service 

sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 900/g' /etc/ssh/sshd_config 
sed -i 's/#ClientAliveCountMax 0/ClientAliveCountMax 10/g' /etc/ssh/sshd_config 
sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config 
#sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config 
#sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config 
sed -i 's/#MaxAuthTries 6/MaxAuthTries 6/g' /etc/ssh/sshd_config 
sed -i 's/#Banner none/Banner \/etc\/ssh\/banner.txt/g' /etc/ssh/sshd_config 
sed -i 's/#TCPKeepAlive yes/TCPKeepAlive yes/g' /etc/ssh/sshd_config 



echo "##################################################" > /etc/ssh/banner.txt
echo "This is private system only for authrorized users." >> /etc/ssh/banner.txt
echo "Logout if you are not authorized " >> /etc/ssh/banner.txt
echo "##################################################" >> /etc/ssh/banner.txt
echo " " >> /etc/ssh/banner.txt
echo " " >> /etc/ssh/banner.txt



#set services to start automaticly
chkconfig nginx on
chkconfig sendmail on
chkconfig php-fpm on

#Restart services 
#systemctl restart rsyslog
systemctl restart sendmail
systemctl restart php-fpm.service
systemctl restart nginx
systemctl restart sshd

echo " - csf"
csf -r
echo ""



service sshd restart


#Set service restart script 
mkdir /root/bin
chmod 700 /root/bin

SERVICESRESTART=/root/bin/restart_services.sh
touch ${SERVICESRESTART}
echo "#!/bin/bash" > ${SERVICESRESTART}
echo ". /etc/profile" >> ${SERVICESRESTART}
echo "#set sleep time that each server will restart services on different time" >> ${SERVICESRESTART}
echo "RN=`shuf -i 0-120 -n 1`" >> ${SERVICESRESTART}
echo 'sleep ${RN}' >> ${SERVICESRESTART}
echo "systemctl restart sendmail" >> ${SERVICESRESTART}
echo "systemctl restart php-fpm.service" >> ${SERVICESRESTART}
echo "systemctl restart nginx" >> ${SERVICESRESTART}
chmod 700 ${SERVICESRESTART}

#Setup root crontab"

mkdir /root/cron
ROOTCRONFILE=/root/cron/root.cron
echo "#Root crontab" > ${ROOTCRONFILE}
echo "# Update ClamAV virus definitions" >> ${ROOTCRONFILE}
echo "0 10 * * * /usr/bin/freshclam" >> ${ROOTCRONFILE}
echo "# AntiVirus scan." >> ${ROOTCRONFILE}
echo '0 11 * * * /usr/bin/clamscan --detect-pua -i -r /data --log="$HOME/.clamtk/history/$(date +\%b-\%d-\%Y).log" 2>/dev/null' >> ${ROOTCRONFILE}
echo '20 11 * * * /usr/bin/clamscan --detect-pua -i -r /home --log="$HOME/.clamtk/history/$(date +\%b-\%d-\%Y).log" 2>/dev/null' >> ${ROOTCRONFILE}
echo "# Daily update." >> ${ROOTCRONFILE}
echo "21 1 * * * /bin/dnf -y update" >> ${ROOTCRONFILE}
echo "# Daily rysnc file system between APP1 and remaining servers ." >> ${ROOTCRONFILE}
echo "55 0 * * * /root/bin/rsync_servers.sh" >> ${ROOTCRONFILE}
echo "# Daily Service restart." >> ${ROOTCRONFILE}
echo "0 1 * * * /root/bin/services.restart.sh" >> ${ROOTCRONFILE}
crontab ${ROOTCRONFILE}

#setup rsync script 
touch /root/bin/rsync_servers.sh 
chmod 700 /root/bin/rsync_servers.sh




date
date >> /tmp/instalation-script.txt
echo "Instalation script completed " >> /tmp/instalation-script.txt

#test website up
curl http://localhost/test.html

exit