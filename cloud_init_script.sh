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

#https://github.com/mantonik/oci-arm-vps/archive/refs/heads/dev-2.zip
