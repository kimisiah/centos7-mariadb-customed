#!/bin/bash -f 

### START OF TOKENS
#
# MARIADB_PORT = 3306
# MYSQL_ROOT_PASS
# MYSQL_ROOT_USER
# INIT_DB_SCRIPT_PATH = /tmp/secrets/.db-final-script
#
### END OF TOKENS

until [[ `netstat -tulpn | grep ##MARIADB_PORT## | grep LISTEN` ]];
  do
    echo "Waiting for port ##MARIADB_PORT##";
    sleep 2;
  done
echo "Port ##MARIADB_PORT## has opened!"

/usr/bin/expect -c '
set MYSQL_SECURE_INSTALL_PASS "##MYSQL_ROOT_PASS##"
spawn mysql_secure_installation
expect ": $"
send "\r"
expect "Y/n] $"
send "Y\r"
expect "New password: $"
send "$MYSQL_SECURE_INSTALL_PASS\r"
expect "new password: $"
send "$MYSQL_SECURE_INSTALL_PASS\r"
expect "Y/n] $"
send "Y\r"
expect "Y/n] $"
send "Y\r"
expect "Y/n] $"
send "Y\r"
expect "Y/n] $"
send "Y\r"
expect "Y/n] $"
'

#Database Initialize
mysql -u##MYSQL_ROOT_USER## -p##MYSQL_ROOT_PASS## < ##INIT_DB_SCRIPT_PATH##