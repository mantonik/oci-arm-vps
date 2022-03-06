#!/bin/bash
# ./mysql_config.sh login 10.1.2.3 myuser mypass < /dev/null
#
# ./create_mysql_login_path.sh r3306 localhost root mypass < /dev/null
# ./create_mysql_login_path.sh r3306 localhost root mypass < /dev/null
#
# ./create_mysql_login_path.sh uapp2 10.10.1.12 user mypass < /dev/null
#
if [ $# -ne 4 ]; then
  echo "Incorrect number of input arguments: $0 $*"
  echo "Usage: $0 <login> <host> <username> <password>"
  echo "Example: $0 test 10.1.2.3 myuser mypassword"
  exit 1
fi

login=$1
host=$2
user=$3
pass=$4

if [ $host == "localhost" ]; then
  echo "Set password for localhost"
  unbuffer expect -c "
  spawn mysql_config_editor set --login-path=$login --socket=/var/lib/mysql/mysql.sock --user=$user --password
  expect -nocase \"Enter password:\" {send \"$pass\r\"; interact}
  "
else
  echo "Set login path for host: "${host}
  unbuffer expect -c "
  spawn mysql_config_editor set --login-path=$login --host=$host --user=$user --password
  expect -nocase \"Enter password:\" {send \"$pass\r\"; interact}
  "
fi