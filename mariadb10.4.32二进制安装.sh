#!/bin/bash

##安装相关依赖
yum -y install libaio numactl-libs

wget https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-10.4.32/bintar-linux-glibc_214-x86_64/mariadb-10.4.32-linux-glibc_214-x86_64.tar.gz --no-check-certificate


id mysql || useradd -r -M -s /sbin/nologin mysql

tar xzfv mariadb-10.4.32-linux-glibc_214-x86_64.tar.gz 

mv mariadb-10.4.32-linux-glibc_214-x86_64 /usr/local/mysql

mkdir -p /usr/local/mysql/{data,logs}
chown -R mysql.mysql /usr/local/mysql

echo 'PATH=/usr/local/mysql/bin:$PATH' > /etc/profile.d/mysql.sh
source /etc/profile.d/mysql.sh

[ -f /etc/my.cnf.bak ] || cp /etc/my.cnf{,.bak}
cat >/etc/my.cnf <<EE
[mysqld]
#basedir=/usr/local/mysql
datadir=/usr/local/mysql/data
socket=/usr/local/mysql/data/mysql.sock
#Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
#Settings user and group are ignored when systemd is used.
#If you need to run mysqld under a different user or group,
#customize your systemd unit file for mariadb according to the
#instructions in http://fedoraproject.org/wiki/Systemd
 
[mysqld_safe]
log-error=/usr/local/mysql/logs/mariadb.log
pid-file=/usr/local/mysql/mariadb.pid
#include all files from the config directory
!includedir /etc/my.cnf.d
EE


##初始化数据库生成空密码
cd /usr/local/mysql/ && ./scripts/mysql_install_db --user=mysql --datadir=/usr/local/mysql/data
##启动MariaDB守护程序
cd /usr/local/mysql/ && ./bin/mysqld_safe --user=mysql --datadir=/usr/local/mysql/data &
##测试MariaDB守护程序
##cd /usr/local/mysql/mysql-test && perl mysql-test-run.pl

source /etc/profile.d/mysql.sh
##准备服务脚本和启动
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig --list mysqld

systemctl start mysqld.service

ln -s /usr/local/mysql/data/mysql.sock /tmp/mysql.sock



