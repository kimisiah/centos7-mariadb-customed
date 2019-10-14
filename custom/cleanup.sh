#!/bin/bash -f 

### START OF TOKENS
#
# MARIADB_PORT = 3306
# MYSQL_ROOT_PASS
# MYSQL_ROOT_USER
# INIT_DB_SCRIPT_PATH = /tmp/secrets/.db-final-script
# MYSQL_DATA_EXISTS = false
#
### END OF TOKENS

cat <<EOF > /tmp/reset.sql
UPDATE mysql.user set password='' where user='root';
flush privileges;
quit;

EOF

timerStart=$SECONDS
timeOut=300
until [[ `netstat -tulpn | grep ##MARIADB_PORT## | grep LISTEN` ]];
  do
    echo "Waiting for port ##MARIADB_PORT##";
    sleep 2;
    
    if [[ $(( SECONDS - timerStart )) -gt $timeOut ]]; then \
      echo "Timeout has reached" && exit 1;
    fi

    if ##MYSQL_DATA_EXISTS##; then \
      if [[ -S /tmp/mysql.sock && -f /tmp/reset.sql ]]; then \
        echo "Resetting Root Password.." 
        mysql -u##MYSQL_ROOT_USER## -P0 --socket /tmp/mysql.sock -p##MYSQL_ROOT_PASS## < /tmp/reset.sql
        rm -f /tmp/reset.sql
        echo "Password has been resetted..."
      fi
    fi
    
  done
echo "Port ##MARIADB_PORT## has opened!"
rm -f /tmp/reset.sql

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
