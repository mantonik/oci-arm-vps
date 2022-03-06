#!/bin/bash
export LOG=/var/log/cloud_init.log
export REPO_NAME=oci-arp-vps
export REPO_BRANCH=dev-2

####################################
# Main don't change below
####################################
date >> ${LOG}

echo "Start cloud init script " >> ${LOG}
REPO_URL="https://github.com/mantonik/${REPO_NAME}/archive/refs/heads/${REPO_BRANCH}.zip"
REPODIR=${HOME}/repository/${REPO}
cd ${HOME}
rm -rf * 
mkdir -p ${REPODIR}
cd ${REPODIR}
wget ${REPO_URL}
unzip ${REPO}.zip
cp -a ${REPO_NAME}-${REPO_BRANCH}/server-config/* ${HOME}/
cd ${HOME}
ls -l
#Execute instalation
sudo ./bin/01.install-server-4app-2db.sh >> ${LOG}
echo " Instalation completed"
exit
