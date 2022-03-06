[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
log-error=/var/log/mysql/mysqld.log
pid-file=/run/mysqld/mysqld.pid

auto_increment_increment=10
auto_increment_offset=2
server-id=2
max_connect_errors=1000000000

#end