#########################
#
# repository
#
# OCI-ARM-VPS
#########################

Script is desing to install application to run Nginx, PHP, MySQL server on set of 4 servers in OCI Cloud.

Run below comands on respective servers as OPC user 
SErver name has should be name like 

somethingappX

...app1


##########
app1
##########
#!/bin/bash
export LOG=$HOME/log/cloud_init.log
export REPO_NAME=oci-arm-vps
export REPO_BRANCH=dev-2

####################################
# Main don't change below
####################################

mkdir $HOEM/log

date >> ${LOG}
echo "Start cloud init script " >> ${LOG}
REPO_URL="https://github.com/mantonik/${REPO_NAME}/archive/refs/heads/${REPO_BRANCH}.zip"
REPODIR=${HOME}/repository/${REPO}
cd ${HOME}
rm -rf * 
mkdir -p ${REPODIR}
cd ${REPODIR}
wget ${REPO_URL}
unzip ${REPO_BRANCH}.zip
cp -a ${REPO_NAME}-${REPO_BRANCH}/server-config/* ${HOME}/
cd ${HOME}
ls -l repository


#Execute instalation
sudo ./bin/01.install-server.sh >> ${LOG}
echo " Instalation completed"
exit

#################################################

For support requests allow SSH access from IP:  107.150.23.152

# on app1 servers set ntfs share drive which will be mounted on other server for instalation purpose.
# this way repository need to be sync only to single server app1 not rest of the servers.
#
# rclone for mounting remote drives like google drive for backup purpose.
#
#
#

#########
# Remove current instalation sever 
service mysqld stop 
dnf remove -y mysql-server
rm -rf /var/lib/mysql

rm -rf /share
dnf remove -y nginx php php-fpm php-mysqlnd php-json sendmail htop tmux mc rsync clamav clamav-update rclone setroubleshoot-server setools-console nfs-utils




#########

