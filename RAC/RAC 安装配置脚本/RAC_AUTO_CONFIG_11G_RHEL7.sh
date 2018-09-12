#!/bin/bash

###################################################################################
## Author: duchengwen@gmail.com
##		 QQ: 23828728
## ���ĵ���� Red Hat Enterprise Linux Server release 6.X ��������ں� ���� 11G RAC ����Ĳ���
## 0. ������Ϣ���
## 1. �رն���ķ�����߲���ϵͳ���ܺͰ�ȫ��
## 2. ����Զ��ͼ�ν���(Xmanager��VNC)
## 3. ���ñ���YUMԴ����װ����ϵͳ������
## 4. �޸Ĳ���ϵͳ�ں˲���
## 5. ���ù���洢
## 6. ���� oracle �û�����װĿ¼
## 7. ��������ϵͳ�����޸���֤
## 8. ִ�� CRS ��װ
## 9. ��װ CRS 10.2.0.5 ����
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
echo "memory info"
grep MemTotal /proc/meminfo


echo
echo
echo "swap info"
grep SwapTotal /proc/meminfo

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
grep "model name" /proc/cpuinfo

echo
echo
echo "kernel info"
uname -a

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
##	  ���ݻ�������Ҫ�Զ���
###################################################################################

echo "###################################################################################"
echo "1. �رն���ķ�����߲���ϵͳ���ܺͰ�ȫ��"
echo
systemctl stop firewalld.service
systemctl disable firewalld.service

systemctl stop irqbalance.service
systemctl disable irqbalance.service

systemctl stop postfix.service
systemctl disable postfix.service

systemctl stop avahi-dnsconfd
systemctl disable avahi-dnsconfd

systemctl stop avahi-daemon
systemctl disable avahi-daemon

systemctl stop smartd.service
systemctl disable smartd.service

systemctl stop cups.service
systemctl disable cups.service

systemctl stop bluetooth.service
systemctl disable bluetooth.service

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
#
# mount ISO
# mount -o loop myISO.iso /media/myISO

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

#Linux 7
yum install -y binutils compat-libcap1 compat-libstdc++-33.x86_64 compat-libstdc++-33.i686 elfutils.x86_64 elfutils-libelf.x86_64 elfutils-libelf-devel.x86_64 gcc.x86_64 gcc-c++.x86_64 glibc.i686 glibc.x86_64 glibc-devel.i686 glibc-devel.x86_64 ksh libgcc.i686 libgcc.x86_64 libstdc++.i686 libstdc++.x86_64 libstdc++-devel.i686 libstdc++-devel.x86_64 libaio.i686 libaio.x86_64 libaio-devel.i686 libaio-devel.x86_64 libXi.x86_64 libXi.i686 libXtst.x86_64 libXtst.i686 make.x86_64 sysstat.x86_64

yum install unzip tree sg3_utils pciutils psmisc bc numactl iptraf

rpm -ivh cvuqdisk*

echo "finish package install"

echo
echo
echo "check package info"

rpm -q --qf '%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n' binutils compat-libcap1 compat-libstdc++-33 gcc gcc-c++ glibc glibc-devel ksh libaio libaio-devel libcap libgcc libstdc++ libstdc++-devel make sysstat

umount /dev/cdrom
eject

echo
echo "###################################################################################"
echo
echo
echo

###################################################################################
## 4. �޸Ĳ���ϵͳ�ں˲���
###################################################################################

echo "###################################################################################"
echo "4. �޸Ĳ���ϵͳ�ں˲���"
echo

cd /etc/sysctl.d

cat >> 99-oracle-rdbms.conf << "EOF"
###################################################################################
##################### change for oracle install #####################

fs.file-max = 6815744
fs.aio-max-nr = 3145728

kernel.msgmni = 2878
kernel.msgmax = 8192
kernel.msgmnb = 65536
kernel.sem = 250 32000 100 142
kernel.shmmni=4096
kernel.shmall=16777216
#vm.nr_hugepages=16384

net.core.rmem_default = 1048576
net.core.wmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_max = 1048576

net.ipv4.tcp_rmem=4096 262144 4194304
net.ipv4.tcp_wmem=4096 262144 262144
net.ipv4.ip_local_port_range = 9000 65500
net.ipv4.tcp_keepalive_time=30
net.ipv4.tcp_keepalive_intvl=60
net.ipv4.tcp_keepalive_probes=9
net.ipv4.tcp_retries2=3
net.ipv4.tcp_syn_retries=2

#vm.min_free_kbytes = 5242880
vm.swappiness=20
vm.dirty_background_ratio=3
vm.dirty_ratio=15
vm.dirty_expire_centisecs=500
vm.dirty_writeback_centisecs=100

EOF
echo
echo

echo "make kernel change take effect"
/sbin/sysctl -p

echo
echo

# disable transparent hugepages
# Append the following to the kernel command line in grub.conf:
# numa=off transparent_hugepage=never

echo "###################################################################################"
echo
echo
echo

###################################################################################
## 5. ���ù���洢
##    ��Ҫ�ֹ���ɣ�ͨ���ű��鿴���̵�scsi_id��Ϣ�ͷ�����С
##    Oracle�������ݿ�ʹ�õĴ��̵ĵ��Ȳ���Ϊdeadline
##    ������̷�����udev�󶨴��̸��豸
##    /sbin/scsi_id --whitelisted --replace-whitespace --device=/dev/sdb
##    /usr/lib/udev/scsi_id -g -u -d /dev/sdb
###################################################################################

# # vi diskinfo.sh
# > diskinfo.tmp
# 
# for i in b c d e f;
# do
#         diskinfo=`fdisk -l /dev/sd$i | grep "Disk /dev/sd$i"`
#         echo "KERNEL==\"sd*\", BUS==\"scsi\", PROGRAM==\"/sbin/scsi_id --whitelisted --replace-whitespace --device=/dev/\$name\", RESULT==\"`/sbin/scsi_id --whitelisted --replace-whitespace --device=/dev/sd$i`\", NAME=\"asm-disk$i\", OWNER=\"grid\", GROUP=\"asmadmin\", MODE=\"0660\""      
# done
# 
# sort diskinfo.tmp > diskinfo.rs
# more diskinfo.rs
# rm -f diskinfo.tmp

# vi /etc/udev/rules.d/99-oracle-asmdevices.rules

# ͨ�� partprobe ʹ������Ϣ�ڼ�Ⱥ����Ч
# [root@archdb01 ~]# partprobe

cd /dev
chmod 775 oracleasm/
chown grid:oinstall ./oracleasm/

# [root@A42ams1 ~]# grep deadline /sys/block/sd*/queue/scheduler    
# RHEL 4, RHEL 5, RHEL 6: add elevator=deadline to the end of the kernel line in /etc/grub.conf file:
# kernel /vmlinuz-2.6.9-67.EL ro root=/dev/vg0/lv0 elevator=deadline

###################################################################################
## 6. ���� oracle �û�����װĿ¼
###################################################################################

echo "###################################################################################"
echo "6. ���� oracle �û�����װĿ¼"
echo

echo "����oracle�û�����"
/usr/sbin/groupadd -g 1000 oinstall
/usr/sbin/groupadd -g 1001 dba
/usr/sbin/groupadd -g 1002 oper
/usr/sbin/groupadd -g 1010 asmadmin
/usr/sbin/groupadd -g 1011 asmoper
/usr/sbin/groupadd -g 1012 asmdba

/usr/sbin/useradd -u 1000 -g oinstall -G dba,oper,asmdba oracle
/usr/sbin/useradd -u 1001 -g oinstall -G dba,asmadmin,asmdba,asmoper grid

echo oracle | passwd --stdin oracle
echo oracle | passwd --stdin grid

echo
echo "����oracle��װĿ¼"
mkdir -p /grid/app/11.2.0.4/grid
chown -R grid:oinstall /grid
chmod -R 755 /grid

mkdir -p /oracle/app/oracle
chown -R oracle:oinstall /oracle
chmod -R 755 /oracle

echo
echo "�޸�oracle�û��Ự����"
# vi /etc/security/limits.d/20-nproc.conf
*       soft    nproc     unlimited

# vi /etc/ssh/sshd_config
UsePAM yes

cp /etc/security/limits.conf /etc/security/limits.conf.bak
cd /etc/security/limits.d
cat >> /etc/security/limits.conf << "EOF"
#########################################
#add for grid
grid    hard    nofile  131072
grid    soft    nofile  131072
grid    hard    nproc   131072
grid    soft    nproc   131072
grid    hard    core    unlimited
grid    soft    core    unlimited
grid    hard    stack   10240
grid    soft    stack   10240
grid    hard    memlock unlimited
grid    soft    memlock unlimited

#########################################
#add for oracle
oracle    hard    nofile  131072
oracle    soft    nofile  131072
oracle    hard    nproc   131072
oracle    soft    nproc   131072
oracle    hard    core    unlimited
oracle    soft    core    unlimited
oracle    hard    stack   10240
oracle    soft    stack   10240
oracle    hard    memlock unlimited
oracle    soft    memlock unlimited

EOF
echo

# memlock ��������hugepage,��ֵ����SGAС�������ڴ�

echo
#cp /etc/pam.d/login /etc/pam.d/login.bak
#
#cat >> /etc/pam.d/login << "EOF"
###############################################
##add for oracle
#session required /lib64/security/pam_limits.so
#EOF
#echo

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
		ulimit -u 16384 -n 65536 -l unlimited
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
export LANG=C

export ORACLE_BASE=/grid/app/grid
export ORACLE_HOME=/grid/app/11.2.0.4/grid
export ORACLE_SID=+ASM

export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"

export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:/usr/sbin:/sbin:$PATH

umask 022
EOF
echo

echo
echo "�༭oracle�û���������"

cp /home/oracle/.bash_profile /home/oracle/.bash_profile.bak

cat >> /home/oracle/.bash_profile << "EOF"
#########################################
export LANG=C

export ORACLE_BASE=/oracle/app/oracle
export GRID_HOME=/grid/app/11.2.0.4/grid
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0.4/db_1
export ORACLE_SID=

export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"

export PATH=$ORACLE_HOME/bin:$GRID_HOME/bin:$ORACLE_HOME/OPatch:/usr/sbin:/sbin:$PATH

umask 022
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

./runcluvfy.sh stage -pre crsinst -n archdb01,archdb02 -fixup -verbose
 
echo "��ɰ�װ��ʼ������"

###################################################################################
## �Զ����ssh���ýű���ʹ��11g�Դ��Ľű����
###################################################################################
# /home/grid/grid/sshsetup
# ./sshUserSetup.sh -hosts "rac11g1 rac11g2" -user grid -advanced -noPromptPassphrase
# ./sshUserSetup.sh -hosts "rac11g1 rac11g2" -user oracle -advanced -noPromptPassphrase
# $ more /etc/hosts | grep -Ev '^#|^$|127.0.0.1|vip|scan|:' | awk '{print "ssh " $2 " date;"}' > ping.sh
# $ sh ./ping.sh

###################################################################################
## �쳣����
###################################################################################

1. ж�ذ�װʧ�ܵļ�Ⱥ
$ORACLE_HOME/crs/install/rootcrs.pl -verbose -force -deconfig
./deinstall -home /grid/app/11.2.0.4/grid/ 

