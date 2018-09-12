#!/bin/bash

###################################################################################
## ���ĵ���� Red Hat Enterprise Linux Server release 6.X ��������ں� ���� 12C RAC ����Ĳ���
## 0. ������Ϣ���
## 1. �رն���ķ�����߲���ϵͳ���ܺͰ�ȫ��
## 2. ����Զ��ͼ�ν���(Xmanager��VNC)
## 3. ���ñ���YUMԴ����װ����ϵͳ������
## 4. �޸Ĳ���ϵͳ�ں˲���
## 5. ���ù���洢
## 6. ���� oracle �û�����װĿ¼
## 7. ��������ϵͳ�����޸���֤
## 8. ִ�� GI ��װ
## 9. ��װ GI 12.1.0.2 ����
## 10. ִ�����ݿⰲװ
## 11. ��װ���ݿ� 10.2.0.5 ����
## 12. ��װ PSU  ����
## 13. �ֹ�����
## 14. ��������
###################################################################################


###################################################################################
## 0. ������Ϣ���
###################################################################################

echo "###################################################################################"
echo "0. ������Ϣ���"
echo 
echo "memory info At least 4 GB of RAM"
grep MemTotal /proc/meminfo

echo
echo
echo "swap info"
grep SwapTotal /proc/meminfo

echo
echo
echo "tmp info at least 1 GB of space in the /tmp directory."
df -h /tmp

echo
echo
echo "disk info"
df -h

echo
echo
echo "cpu info"
grep "model name" /proc/cpuinfo

echo
echo
echo "kernel info"
uname -a

echo
echo
echo "system runlevel must be 3 or 5"
runlevel

echo
echo
echo "release info"
more /etc/redhat-release

RELEASE=`more /etc/redhat-release | awk '{print $1}'`

echo "###################################################################################"
echo
echo
echo

###################################################################################
## 1. �رն���ķ�����߲���ϵͳ���ܺͰ�ȫ��
##    ���ݻ�������Ҫ�Զ���
###################################################################################

echo "###################################################################################"
echo "1. �رն���ķ�����߲���ϵͳ���ܺͰ�ȫ��"
echo

chkconfig --level 2345 bluetooth off
chkconfig --level 2345 cups off
chkconfig --level 2345 ip6tables off
chkconfig --level 2345 iptables off
chkconfig --level 2345 irqbalance off
chkconfig --level 2345 pcscd off
chkconfig --level 2345 anacron off
chkconfig --level 2345 atd off
chkconfig --level 2345 auditd off
chkconfig --level 2345 avahi-daemon off
chkconfig --level 2345 avahi-dnsconfd off
chkconfig --level 2345 cpuspeed off
chkconfig --level 2345 gpm off
chkconfig --level 2345 hidd off
chkconfig --level 2345 mcstrans off
chkconfig --level 2345 microcode_ctl off
chkconfig --level 2345 netfs off
chkconfig --level 2345 nfslock off
chkconfig --level 2345 portmap off
chkconfig --level 2345 readahead_early off
chkconfig --level 2345 readahead_later off
chkconfig --level 2345 restorecond off
chkconfig --level 2345 rpcgssd off
chkconfig --level 2345 rhnsd off
chkconfig --level 2345 rpcidmapd off
chkconfig --level 2345 sendmail off
chkconfig --level 2345 setroubleshoot off
chkconfig --level 2345 smartd off
chkconfig --level 2345 xinetd off
chkconfig --level 2345 ntpd off

echo "Better tolerate network failures with NAS devices or NFS mounts"
chkconfig --level 2345 nscd on

echo
echo

echo "turn off selinux"
SELINUX=`grep ^SELINUX= /etc/selinux/config`

if [ $SELINUX != "SELINUX=disabled" ];then
    cp /etc/selinux/config /etc/selinux/config.bak
    sed -i 's/^SELINUX=/#SELINUX=/g' /etc/selinux/config
    sed -i '$a SELINUX=disabled' /etc/selinux/config
else
    echo "SELINUX is already disabled"
fi

echo
echo "###################################################################################"
echo
echo
echo

###################################################################################
## 2. ����Զ��ͼ�ν���(Xmanager��VNC)
##    ���ݻ�����ͬ����Ҫ�����ֹ����ã�����ʹ�� Xmanager - Passive �� VNC ��ʽ
###################################################################################

## | 2.1 ͨ�� xshell ��ʽ��¼
## |   �� Xmanager - Passive ���ߣ� ʹ�� Xshell ����Զ�̷�����
## 
## | #export DISPLAY=�ͻ���IP:0.0
## | #xclock

###################################################################################
## 3. ���ñ���YUMԴ����װ����ϵͳ������
## http://yum.oracle.com/repo/OracleLinux/OL6/latest/x86_64/
## http://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/
###################################################################################

echo "###################################################################################"
echo "3. ���ñ���YUMԴ����װ����ϵͳ������"
echo

mkdir -p /media/cdrom
mount /dev/cdrom /media/cdrom
cd /etc/yum.repos.d/
mkdir bak
mv *.repo ./bak/
> local.repo

# ע��RHEL��CENTOS��YUM���÷�ʽ������ͬ�����ݲ���ϵͳ���ж�Ӧ����
# --RHEL
# [RHEL]
# name = RHEL
# baseurl=file:///media/cdrom/Server/
# gpgcheck=0
# enabled=1
# 
# --CENTOS
# [CENTOS]
# name = CENTOS
# baseurl=file:///media/cdrom/
# gpgcheck=0
# enabled=1

cat >> local.repo << "EOF"
[LOCAL]
name=LOCAL
gpgcheck=0
enabled=1
EOF

echo
if [ $RELEASE = "CentOS" ];then
    sed -i '$a baseurl=file:\/\/\/media\/cdrom\/' local.repo
else
    sed -i '$a baseurl=file:\/\/\/media\/cdrom\/Server\/' local.repo
fi

echo
echo "install package"

#oracle Linux ֱ��ʹ��oracle-rdbms-server�����а�װ������ϵͳ�����ֹ���װ
if [ -f "/etc/oracle-release" ];then
    yum install -y oracle-database-server-12cR2-preinstall
else
    yum install -y bc binutils compat-libcap1 compat-libstdc++-33 compat-libstdc++-33.i686 e2fsprogs.x86_64 e2fsprogs-libs.x86_64 elfutils* gcc gcc-c++ glibc glibc.i686 glibc-devel glibc-devel.i686 ksh libaio libgcc.i686 libstdc++ libstdc++.i686 libstdc++-devel libstdc++-devel.i686 libaio libaio.i686 libaio-devel libaio-devel.i686 libXext libXext.i686 libXtst libXtst.i686 libX11 libX11.i686 libXau libXau.i686 libxcb libxcb.i686 libXi libXi.i686 libcap libgcc libstdc++ libstdc++-devel make net-tools.x86_64 nfs-utils sysstat smartmontools.x86_64 unixODBC unixODBC-devel
fi

--ϵͳ����
yum install cvuqdisk sysfsutils readline unzip tree sg3_utils pciutils psmisc bc numactl iptraf-ng sysfsutils lsscsi util-linux-ng iotop iperf iperf3 qperf dstat blktrace iproute dropwatch strace hdparm mdadm perf tuna hwloc valgrind powertop

echo "check install log /var/log/oracle-database-server-12cR2-preinstall/backup/timestamp/orakernel.log"

echo "finish package install"

echo
echo
echo "check package info"

rpm -q --qf '%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n' binutils compat-libcap1 compat-libstdc++-33 gcc gcc-c++ glibc glibc-devel ksh libaio libaio-devel libcap libgcc libstdc++ libstdc++-devel make sysstat

umount /dev/cdrom
eject

# ��װ rlwrap

echo
echo "###################################################################################"
echo
echo
echo

###################################################################################
## 4. �޸Ĳ���ϵͳ�ں˲���
###################################################################################

echo "###################################################################################"
echo "4.1 �޸�ssh����"
echo

vi ~/.ssh/config
Host * 
    ForwardX11 no
    
vi /etc/ssh/sshd_config
LoginGraceTime 0

echo "###################################################################################"
echo "4.2 �޸Ĳ���ϵͳ�ں˲���"
echo

cp /etc/sysctl.conf /etc/sysctl.conf.bak

cat >> /etc/sysctl.conf << "EOF"
###################################################################################
# change for oracle install

fs.file-max = 6815744
fs.aio-max-nr = 3145728

kernel.msgmni = 2878
kernel.msgmax = 8192
kernel.msgmnb = 65536
kernel.sem = 250 32000 100 142

kernel.shmmax=34359738368
kernel.shmmni=4096
kernel.shmall=16777216
#vm.nr_hugepages=16384	--���ڴ������ǿ�ҽ��鿪�� (GIMR+ASM+DB)
#kernel.sysrq = 1

net.core.rmem_default = 1048576
net.core.wmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_max = 1048576

net.ipv4.tcp_rmem=4096 262144 4194304
net.ipv4.tcp_wmem=4096 262144 4194304
net.ipv4.ip_local_port_range = 9000 65500
net.ipv4.tcp_keepalive_time=30
net.ipv4.tcp_keepalive_intvl=60
net.ipv4.tcp_keepalive_probes=9
net.ipv4.tcp_retries2=3
net.ipv4.tcp_syn_retries=2

panic_on_oops = 1
vm.min_free_kbytes = 51200
vm.swappiness=20
vm.dirty_background_ratio=5
vm.dirty_ratio=10
vm.dirty_expire_centisecs=500
vm.dirty_writeback_centisecs=100

EOF
echo
echo

# ���������������Ҫ����ID1286796.1���в������� (private:rp_filter = 2/public:rp_filter = 0)
net.ipv4.conf.eth2.rp_filter = 2
net.ipv4.conf.eth1.rp_filter = 2
net.ipv4.conf.eth0.rp_filter = 1

echo "make kernel change take effect"
/sbin/sysctl -p

echo
echo

echo "###################################################################################"
echo "4.3 disable transparent hugepages"
echo
# cat /sys/kernel/mm/redhat_transparent_hugepage/enabled
# cat /sys/kernel/mm/transparent_hugepage/enabled
# Append the following to the kernel command line in /etc/grub.conf:
# transparent_hugepage=never

echo "###################################################################################"
echo "4.4 ntpʱ��ͬ��"
echo

vi /etc/ntp.conf
Server 192.168.1.190

vi /etc/sysconfig/ntpd
OPTIONS="-u ntp:ntp -p /var/run/ntpd.pid -g"
�޸ĳ�
OPTIONS="-x -u ntp:ntp -p /var/run/ntpd.pid -g"

# chkconfig ntpd on
# service ntpd restart

echo "###################################################################################"
echo "4.5 �ر�Ĭ��169.254.0.0·��"
echo

vi /etc/sysconfig/network
NOZEROCONF=yes

chmod 644 /etc/sysconfig/network

echo "###################################################################################"
echo
echo
echo

###################################################################################
## 5. ���ù���洢
##    ��Ҫ�ֹ���ɣ�ͨ���ű��鿴���̵�scsi_id��Ϣ�ͷ�����С
###################################################################################

echo "###################################################################################"
echo "5.1 Disk I/O Scheduler"
echo
# cat /sys/block/${ASM_DISK}/queue/scheduler
# vi /etc/udev/rules.d/60-oracle-schedulers.rules
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="deadline"

# udevadm control --reload-rules

echo "###################################################################################"
echo "5.2 Oracle ASM Filter Driver (Oracle ASMFD)"
echo
# su - root
# export ORACLE_HOME=/u01/app/12.2.0/grid
#./u01/app/12.2.0/grid/bin/asmcmd afd_label DATA1 /dev/sdb1 --init
#./u01/app/12.2.0/grid/bin/asmcmd afd_lslbl /dev/sdb1

echo "###################################################################################"
echo "5.3 multipath"
echo

echo "###################################################################################"
echo "5.4 UDEV"
echo
# # vi diskinfo.sh
# > diskinfo.tmp
# 
# for i in a b c d e f g h i j k l m n o p q r s t u v w x y z;
# do
#         diskinfo=`fdisk -l /dev/sd$i | grep "Disk /dev/sd$i"`
#         echo 'scsi_id:' `scsi_id -gus /block/sd$i` $diskinfo | awk -F',' '{print $1}' >> diskinfo.tmp
# done
# 
# sort diskinfo.tmp > diskinfo.rs
# more diskinfo.rs
# rm -f diskinfo.tmp

###################################################################################
## 6. ���� oracle �û�����װĿ¼
###################################################################################

echo "###################################################################################"
echo "6. ���� oracle �û�����װĿ¼"
echo

echo "����oracle�û�����"
#Oracle Inventory Group
/usr/sbin/groupadd -g 1000 oinstall

#Standard Oracle Database Groups
/usr/sbin/groupadd -g 1001 dba
/usr/sbin/groupadd -g 1002 oper

#Extended Oracle Database Groups for Job Role Separation
/usr/sbin/groupadd -g 1003 backupdba
/usr/sbin/groupadd -g 1004 dgdba
/usr/sbin/groupadd -g 1005 kmdba

#Oracle ASM Groups for Job Role Separation
/usr/sbin/groupadd -g 1010 asmadmin
/usr/sbin/groupadd -g 1012 asmdba
/usr/sbin/groupadd -g 1011 asmoper

/usr/sbin/useradd -u 1000 -g oinstall -G dba,asmdba,backupdba,dgdba,kmdba,racdba,oper oracle
/usr/sbin/useradd -u 1001 -g oinstall -G asmadmin,asmdba,racdba,asmoper grid


echo oracle | passwd --stdin oracle
echo oracle | passwd --stdin grid

echo
echo "����oracle��װĿ¼"
mkdir -p /grid/app/grid
mkdir -p /grid/app/12.1/grid
chmod -R 775 /grid
chown -R grid:oinstall /grid

mkdir -p /oracle/app/oracle
chmod -R 775 /oracle
chown -R oracle:oinstall /oracle

echo
echo "�޸�oracle�û��Ự����"
cp /etc/security/limits.conf /etc/security/limits.conf.bak

cat >> /etc/security/limits.conf << "EOF"
#########################################
#add for grid
grid  soft  nofile  131072
grid  hard  nofile  131072
grid  soft  nproc   131072
grid  hard  nproc   131072
grid  soft  stack   10240
grid  soft  memlock  3145728		--> ��λKB��HugePages���������ڴ�90%/��HugePages��������3G
grid  hard  memlock  3145728		--> ��λKB��HugePages���������ڴ�90%/��HugePages��������3G

#########################################
#add for oracle
oracle  soft  nofile  131072
oracle  hard  nofile  131072
oracle  soft  nproc   131072
oracle  hard  nproc   131072
oracle  soft  stack   10240
oracle  soft  memlock  3145728
oracle  hard  memlock  3145728
EOF
echo

echo
cp /etc/pam.d/login /etc/pam.d/login.bak

cat >> /etc/pam.d/login << "EOF"
##############################################
#add for oracle
session required /lib64/security/pam_limits.so
EOF
echo

echo
echo "�޸�oracle�û���Դ����"
cp /etc/profile /etc/profile.bak

cat >> /etc/profile << "EOF"
#########################################
#add for oracle
if [ $USER = "oracle" ] || [ $USER = "grid" ]; then
  if [ $SHELL = "/bin/ksh"  ]; then
    ulimit -p 16384
    ulimit -n 65536
  else
    ulimit -u 16384 -n 65536
  fi
  umask 022
fi

EOF
echo

echo
echo "�༭grid�û���������"

cp /home/grid/.bash_profile /home/grid/.bash_profile.bak

cat >> /home/grid/.bash_profile << "EOF"
#########################################
if [ -t 0 ]; then
   stty intr ^C
fi

export LANG=C

export ORACLE_BASE=/grid/app/grid
export ORACLE_HOME=/grid/app/12.1/grid

export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"

export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:/usr/sbin:/sbin:$PATH

export DISPLAY=192.168.56.1:0.0
umask 022
EOF
echo

echo
echo "�༭oracle�û���������"

cp /home/oracle/.bash_profile /home/oracle/.bash_profile.bak

cat >> /home/oracle/.bash_profile << "EOF"
#########################################
if [ -t 0 ]; then
   stty intr ^C
fi

export LANG=C

export ORACLE_BASE=/oracle/app/oracle
export GRID_HOME=/grid/app/12.1/grid
export ORACLE_HOME=$ORACLE_BASE/product/12.1/db
export ORACLE_SID=

export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"

export PATH=$ORACLE_HOME/bin:$GRID_HOME/bin:$ORACLE_HOME/OPatch:/usr/sbin:/sbin:$PATH

export DISPLAY=192.168.56.1:0.0
umask 022

alias sql='rlwrap sqlplus / as sysdba'
alias sqlplus='rlwrap sqlplus'
alias rman='rlwrap rman'

EOF
echo

chown -R grid:oinstall /home/grid/
chown -R oracle:oinstall /home/oracle/

###################################################################################
## 7. ��������ϵͳ�����޸���֤
##    ��Ҫ�˹���Ԥ
###################################################################################

###################################################################################
## ����޸���Ϣ
###################################################################################
echo "###################################################################################"
echo "����޸���Ϣ"
echo
echo "-----------------------------------------------------------------------------------"
echo "/etc/selinux/config"
cat /etc/selinux/config
echo
echo "-----------------------------------------------------------------------------------"
echo "/etc/sysctl.conf"
cat /etc/sysctl.conf
echo
echo "-----------------------------------------------------------------------------------"
echo "/etc/modprobe.conf"
cat /etc/modprobe.conf
echo
echo "-----------------------------------------------------------------------------------"
echo "/etc/security/limits.conf"
cat /etc/security/limits.conf
echo
echo "-----------------------------------------------------------------------------------"
echo "/etc/pam.d/login"
cat /etc/pam.d/login
echo
echo "-----------------------------------------------------------------------------------"
echo "/etc/profile"
cat /etc/profile
echo
echo "-----------------------------------------------------------------------------------"
echo "/home/grid/.bash_profile"
cat /home/grid/.bash_profile
echo
echo "-----------------------------------------------------------------------------------"
echo "/home/oracle/.bash_profile"
cat /home/oracle/.bash_profile
echo

echo "��ɰ�װ��ʼ������"

###################################################################################
## 8. ��Ⱥ��װ
##
###################################################################################

echo "###################################################################################"
echo "8.1 ��װǰ����"
echo

# RDA - Health Check / Validation Engine Guide (�ĵ� ID 250262.1)	
# /home/grid/grid/sshsetup
# ./sshUserSetup.sh -hosts "rac11g1 rac11g2" -user grid -advanced -noPromptPassphrase
# ./sshUserSetup.sh -hosts "rac11g1 rac11g2" -user oracle -advanced -noPromptPassphrase
# $ more /etc/hosts | grep -Ev '^#|^$|127.0.0.1|vip|:' | awk '{print "ssh " $2 " date;"}' > ping.sh
# $ ping.sh
# runcluvfy.sh stage -pre crsinst -n rac1,rac2 -verbose
# $ ./gridSetup.sh
# ./gridSetup.sh [-debug] [-silent -responseFile filename]
# ./gridSetup.sh -responseFile /u01/app/grid/response/response_file.rsp
# ./gridSetup.sh oracle_install_crs_Ping_Targets=192.0.2.1,192.0.2.2

./orachk -u -o pre 

echo "###################################################################################"
echo "8.2 ��װ����"
echo

$ crsctl check cluster -all
$ srvctl status asm
$ cluvfy comp scan
$ crsctl check ctss
$ cat $GRID_HOME/crs/install/s_crsconfig_nodename_env.txt

###################################################################################
## 9. ��Ⱥж��
##
###################################################################################

echo "###################################################################################"
echo "9.1 ж�ؼ�Ⱥ"
echo

$ cd /directory_path/
$ ./runInstaller -deinstall -paramfile /home/usr/oracle/my_db_paramfile.tmpl

$ cd /u01/app/oracle/product/12.2.0/dbhome_1/deinstall
$ ./deinstall -paramfile $ORACLE_HOME/deinstall/response/deinstall.rsp.tmpl

echo "###################################################################################"
echo "9.2 ʧ�ܺ���װ"
echo

# $GRID_HOME/deinstall/deinstall -local
# $GRID_HOME/bin/crsctl delete node -n node_name
# $GRID_HOME/gridSetup.sh
# $GRID_HOME/addnode/addnode.sh

###################################################################################
# export CVUQDISK_GRP=oinstall;
# rpm -ivh cvuqdisk-1.0.9-1.rpm

# echo deadline > /sys/block/${ASM_DISK}/queue/scheduler 


# $ crsctl check ctss
