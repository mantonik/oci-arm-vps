#!/bin/bash 
# 
# 1/8/2022 add delete local repository before pulling from repo
# v 1.2 delete full repository folder before uploading new files
# v 1.3 rsync_server
# v 1.6 add restart services
# 1.7 - enable rsync and restart
# 1.8 use bin/.env file for parameters to have them common 
#

#Script will sync from repository to local 
version=1.8

. ~/bin/.env
# Delete repo folder
rm -rf ${REPODIR}
mkdir -p ${REPODIR}
cd ${REPODIR}

wget ${REPO_URL}

unzip ${REPO_BRANCH}.zip
cp -a ${REPO_NAME}-${REPO_BRANCH}/server-config/* ${HOME}/

cd ${HOME}
ls -l

echo "-----------------------"
echo "Execute Rsync Server"
sudo /home/opc/bin/rsync_server.sh

echo "-----------------------"
echo "Execute Restart Server"
sudo /home/opc/bin/restart_services.sh now

echo "---------------------------------------"
echo "Version update_repository : ${version}"
echo "---------------------------------------"