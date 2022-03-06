#!/bin/bash
# #Script is executed as root user
# 1/16/2022 - add more comments to script. script didn't executed on app2 server 
#   fix if condition
#   remove server_id entry before adding new entry
# #Remvoe MySQL server first if neede d
# dnf remove mysql-server
# rm -rf /var/lib/mysql
# 2/20/2022 - add debug for create repusr



set +x 

LOGFILE=/root/log/mysql.setup.log

##################
# FUNCTION
##################
function mysql_create_repusr() {
  #set -x
  #mysql --login-path=r3306 -e "GRANT REPLICATION SLAVE, REPLICATION_SLAVE_ADMIN, SUPER, REPLICATION CLIENT ON *.* TO 'repusr'@'10.10.1.0/24' IDENTIFIED BY '${REPUSRMYQLP}';" 
  
  sed -e "s/REPUSRMYQLP/${REPUSRMYQLP}/g" /home/opc/sql/create.repusr.template.sql > /home/opc/sql/create.repusr.sql
  chown opc /home/opc/sql/create.repusr.sql
  ehco "----"
  cat  /home/opc/sql/create.repusr.sql
  echo ""
  #mysql --login-path=r3306 < /home/opc/sql/create.repusr.sql

  mysql -u root < /home/opc/sql/create.repusr.sql

  #echo "dipsplay master status as repusr"
  #mysql -u repusr -p${REPUSRMYQLP} -e "show master status \G"
  #echo ""

  MASTER_STATUS_FILE=/share/mysql_${HOSTNAME: -4}_master_status.txt
  mysql -u root -e "show master status;" > ${MASTER_STATUS_FILE}
  sed -e 's/\t/ /g' -i ${MASTER_STATUS_FILE}
  chmod 666 ${MASTER_STATUS_FILE}
  #set +x
  echo "Finish - mysql_create_repusr"
}

function update_mysql_root_password() {
  echo "Update MySQL Root Passowrd"
  
  export ROOTMYQL=`cat /mnt/share_app2/.my.p|grep root`
  export ROOTMYQLP=${ROOTMYQL:5}
  echo "----------------------------"
  echo "ROOTMYQLP: "${ROOTMYQLP}
  echo "----------------------------"
  mysql -u root -v -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOTMYQLP}';"
  echo "Display databases"
  mysql -u root -v -p${ROOTMYQLP} -e "show databases;"
  echo "MySQL root passwrod updated"

  #set login path
  set_root_login_path

  echo "Finish - update_mysql_root_password"
}


function set_root_login_path() {

  echo "Set Root login-path"
  export ROOTMYQL=`cat /mnt/share_app2/.my.p|grep root`
  export ROOTMYQLP=${ROOTMYQL:5}
  echo "Type root passwrod below: "${ROOTMYQLP}
  #mysql_config_editor set --login-path=r3306 -u root -p --socket=/var/lib/mysql/mysql.sock

  echo "Validate login path"
  mysql --login-path=r3306 -e "show databases;"
  
  echo "-------------------------------------"
  echo "Login to mysql server as root"
  echo "sudo -s"
  echo "mysql --login-path=r3306 "
  echo ""
  echo "Set login path if you change passwrod as to local server"
  echo "mysql_config_editor set --login-path=r3306 -u root -p --socket=/var/lib/mysql/mysql.sock"
  echo "-------------------------------------"
  echo "Finish - set_root_login_path"
}



##################
# Main
##################

echo "Install MySQL"
dnf install -y mysql-server 
#Update configuration of the server 
#sed -i '/^server-id=/d' /etc/my.cnf.d/mysql-server.cnf
#echo "server-id="${HOSTNAME: -1} >> /etc/my.cnf.d/mysql-server.cnf

#Copy configuration files 
cd /etc/my.cnf.d
\cp /etc/my.cnf.d/mysql-server.cnf.app /etc/my.cnf.d/mysql-server.cnf

echo "----"
echo "mysql-server.cnf file"
cat /etc/my.cnf.d/mysql-server.cnf

echo "Start MySQLD"
systemctl start mysqld

#Installing on server 2
#Generate root and usrrep passwrod and put files on share point and in root file 
# .private 
# .private/my.p
# root:PASSWORD
# repusr:PASSWORD

#Create random string for root and repusr
echo "Create .private folder to store root password"
mkdir ~/.private
chmod 700 ~/.private

#rm -f /share/.my.p

echo "Execute on app2 server"
echo "Generate root and repusr password"
ROOTMYQLP=`tr -dc A-Za-z0-9 </dev/urandom | head -c 20`
export ROOTMYQLP="${ROOTMYQLP:1:8}1Yk"
REPUSRMYQLP=`tr -dc A-Za-z0-9 </dev/urandom | head -c 20`
export REPUSRMYQLP="${REPUSRMYQLP:6:8}4hD"

echo "root:${ROOTMYQLP}" > ~/.private/.my.p
echo "repusr:${REPUSRMYQLP}" >> ~/.private/.my.p
chmod 400 ~/.private/.my.p

cp ~/.private/.my.p /share
chmod 666 /share/.my.p
cat /share/.my.p

#echo "Execute create repusr"
#mysql_create_repusr

#Update root passwrod for MySQL instance
echo "Update root passwrod for MySQL instance"
update_mysql_root_password


echo "MySQL server instalation completed"



#   mysql -u root -e "select user,host from mysql.user;"
#   mysql -u root -e "stop slave; start slave;show slave status\G;"
#   mysql -u root -e "show slave status\G;"
#   mysql -u repusr -p${REPUSRMYQLP} -h demoapp2
# mysql -u repusr -p${REPUSRMYQLP} -h demoapp4



