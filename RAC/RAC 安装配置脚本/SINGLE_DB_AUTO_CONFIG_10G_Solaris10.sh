#!/bin/bash

###################################################################################
## 0. System Check
###################################################################################

# bash
# export LANG=C

echo "###################################################################################"
echo "0. System Check"
echo 
echo "memory info"
/usr/sbin/prtconf | grep "Memory size"


echo
echo
echo "swap info"
/usr/sbin/swap -s

echo
echo
echo "tmp info"
df -h /tmp

echo
echo
echo "disk info"
df -h

echo
echo
echo "cpu info"
/bin/isainfo -kv

echo
echo
echo "kernel info"
uname -a

echo
echo
echo "release info"
cat /etc/release

echo "###################################################################################"
echo
echo
echo

###################################################################################
## 1. �رն���ķ�����߲���ϵͳ���ܺͰ�ȫ��
##	  ���ݻ�������Ҫ�Զ���
###################################################################################

echo "###################################################################################"
echo "1. �رն���ķ�����߲���ϵͳ���ܺͰ�ȫ��"
echo
# svcs |grep online �鿴��ǰ���з���
# svcs |grep offline �鿴��ǰֹͣ����
# svcs |grep inetd �鿴inetd ����״̬

# svcadm disable svc:/network/smtp:sendmail

echo
echo "###################################################################################"
echo
echo
echo

###################################################################################
## 2. ��װ����ϵͳ�����
## 		SUNWsprox ���Ѿ��� SUNWsprot �滻
##		�����װĿ¼Ϊ����Ŀ¼ /cdrom/sol_10_113_x86/Solaris_10/Product
###################################################################################

pkginfo -i SUNWarc SUNWbtool SUNWhea SUNWlibm SUNWlibms SUNWsprot \
 SUNWsprox SUNWtoo SUNWi1of SUNWi1cs SUNWi15cs SUNWxwfnt

# pkgadd -d ./ SUNWi1cs
# pkgadd -d ./ SUNWi15cs
# pkgadd -d ./ SUNWsprot

echo
echo "###################################################################################"
echo
echo
echo

###################################################################################
## 2. ��װ����ϵͳ������
## 		SUNWsprox ���Ѿ��� SUNWsprot �滻
##		�����װĿ¼Ϊ����Ŀ¼ /cdrom/sol_10_113_x86/Solaris_10/Product
###################################################################################

patchadd -p | grep 147440

echo
echo "###################################################################################"
echo
echo
echo


###################################################################################
## 3. ���� oracle �û�����װĿ¼
###################################################################################

echo "###################################################################################"
echo "4. ���� oracle �û�����װĿ¼"
echo

echo "����oracle�û�����"
/usr/sbin/groupadd -g 3000 oinstall
/usr/sbin/groupadd -g 3001 dba

mkdir -p /export/home/oracle
chown oracle:oinstall /export/home/oracle

/usr/sbin/useradd -u 3000 -g oinstall -G dba -d /export/home/oracle -s /usr/bin/bash oracle
passwd -r files oracle

echo
echo "����oracle��װĿ¼"

mkdir -p /oracle/app/oracle
chown -R oracle:oinstall /oracle/

chmod -R 755 /oracle/


echo
echo "�༭oracle�û���������"

cp /export/home/oracle/.bash_profile /export/home/oracle/.bash_profile.bak

cat >> /home/oracle/.bash_profile << "EOF"
#########################################
export PS1='[\u@\h:$PWD]$ '
export LANG=C
set -o vi

export ORACLE_BASE=/oracle/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/10.2.0/db_1
export ORACLE_SID=

export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"

export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:/usr/sbin:/sbin:$PATH

umask 022
EOF
echo

###################################################################################
## 4. �޸Ĳ���ϵͳ�ں˲���
###################################################################################

echo "###################################################################################"
echo "5. �޸Ĳ���ϵͳ�ں˲���"
echo

cp /etc/system /etc/system.bak

cat >> /etc/system << "EOF"

***********************************************************************************
* change for oracle install

set shmsys:share_page_table=1
set noexec_user_stack=1
set pg_contig_disable=1
set semsys:seminfo_semmni=128
set semsys:seminfo_semmsl=256
set shmsys:shminfo_shmmax=4294967296
set shmsys:shminfo_shmmni=100
set maxuprc=16384
set rlim_fd_cur=65536
set rlim_fd_max=65536

EOF
echo
echo

cp /etc/project /etc/project.bak

projadd -U oracle user.oracle
projmod -a -K 'project.max-stack-size=(basic,10240k,deny),(privileged,32768k,deny)' user.oracle
projmod -a -K 'project.max-file-descriptor=(basic,1024,deny),(privileged,65536,deny)' user.oracle
projmod -a -K 'project.max-lpws=(basic,2048,deny),(privileged,16384,deny)' user.oracle
projmod -a -K 'project.max-shm-memory=(privileged,4g,deny)' user.oracle
projmod -a -K 'project.max-shm-ids=(privileged,1000,deny)' user.oracle
projmod -a -K 'project.max-sem-ids=(privileged,1000,deny)' user.oracle
projmod -a -K 'project.max-sem-nsems=(privileged,4200,deny)' user.oracle
projmod -a -K 'project.max-address-space=(privileged,4g,deny)' user.oracle

echo
echo

echo "###################################################################################"
echo
echo
echo

###################################################################################
## 5. ��Ĭ��װ
###################################################################################

7.1 ��װ10.2.0.1���
[oracle@oradb:/export/home/oracle]$ cd /oracle/database/database/response
[oracle@oradb:/oracle/database/database/response]$ cp enterprise.rsp ~

[oracle@oradb:/export/home/oracle]$ cd /oracle/database/database

$ ./runInstaller -ignoreSysPrereqs -silent \
-responseFile /export/home/oracle/enterprise.rsp \
ORACLE_HOME=/oracle/app/oracle/product/10.2.0/db_1 \
ORACLE_HOME_NAME=OraDb10g_home1 \
n_configurationOption=3

# /oracle/app/oracle/oraInventory/orainstRoot.sh
# /oracle/app/oracle/product/10.2.0/db_1/root.sh

7.2 ��װ10.2.0.5������
[oracle@oradb:/export/home/oracle]$ cd /oracle/PSR/Disk1/response
[oracle@oradb:/oracle/PSR/Disk1/response]$ cp patchset.rsp ~

[oracle@oradb:/export/home/oracle]$ cd /oracle/PSR/Disk1

$ ./runInstaller -ignoreSysPrereqs -silent \
-responseFile /export/home/oracle/patchset.rsp \
ORACLE_HOME=/oracle/app/oracle/product/10.2.0/db_1 \
ORACLE_HOME_NAME=OraDb10g_home1 \
DECLINE_SECURITY_UPDATES=true

7.3 ��װ����PSU
$ mv $ORACLE_HOME/OPatch $ORACLE_HOME/OPatch.bak
$ mv ./OPatch/ $ORACLE_HOME

$ sqlplus -v
$ opatch lsinv

$ unzip p20299014_10205_Solaris86-64.zip -d ./PSU
$ cd PSU/20299014
$ opatch apply	-> Do you wish to remain uninformed of security issues ([Y]es, [N]o) [N]:  Y
$ opatch lsinv

7.4 ��Ĭ��������
$ cd /oracle/database/database/response
$ cp netca.rsp ~
$ netca /silent /responsefile /export/home/oracle/netca.rsp 
$ lsnrctl status

7.5 ��Ĭ����
$ cd $ORACLE_HOME
$ find ./ -name General_Purpose.dbc
./assistants/dbca/templates/General_Purpose.dbc

$ cp ./assistants/dbca/templates/General_Purpose.dbc ~
$ cd ~

$ dbca -silent -createDatabase \
-templateName General_Purpose.dbc \
-gdbname skydb -sid skydb \
-sysPassword oracle -systemPassword oracle \
-datafileDestination /oracle/app/oracle/oradata/ \
-storageType FS -characterSet ZHS16GBK -nationalCharacterSet AL16UTF16 \
-sampleSchema false \
-memoryPercentage 30 -databaseType OLTP -emConfiguration NONE

###################################################################################
## 6. �������ݿ����
###################################################################################
alter system set "_gby_hash_aggregation_enabled"=FALSE scope=spfile sid='*';
alter system set "_gc_affinity_time"=0 scope=spfile sid='*';
alter system set "_gc_undo_affinity"=FALSE scope=spfile sid='*';
alter system set "_optim_peek_user_binds"=FALSE scope=spfile sid='*';
alter system set "_optimizer_mjc_enabled"=FALSE scope=spfile sid='*';
alter system set "_undo_autotune"=FALSE scope=spfile sid='*';
alter system set sga_max_size=40g scope=spfile sid='*';
alter system set sga_target=40g scope=spfile sid='*';
alter system set pga_aggregate_target=10g scope=spfile sid='*';
alter system set db_files=1000 scope=spfile sid='*';
alter system set processes=8000 scope=spfile sid='*';
alter system set open_cursors=1000 scope=spfile sid='*';
alter system set session_cached_cursors=300 scope=spfile sid='*';
alter system set undo_retention=3600;  
