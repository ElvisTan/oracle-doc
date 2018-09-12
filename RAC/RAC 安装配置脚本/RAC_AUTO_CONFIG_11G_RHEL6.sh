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
##    ���ݻ�������Ҫ�Զ���
###################################################################################

echo "###################################################################################"
echo "1. �رն���ķ�����߲���ϵͳ���ܺͰ�ȫ��"
echo
chkconfig --level 2345 bluetooth off
chkconfig --level 2345 cups off
chkconfig --level 2345 ip6tables off
chkconfig --level 2345 iptables off
chkconfig --level 2345 sendmail off

chkconfig --level 2345 acpid off
chkconfig --level 2345 bluetooth off
chkconfig --level 2345 cups off
chkconfig --level 2345 cpuspeed off
chkconfig --level 2345 irqbalance off
chkconfig --level 2345 postfix off
chkconfig --level 2345 ip6tables off
chkconfig --level 2345 iptables off
chkconfig --level 2345 sendmail off
chkconfig --level 2345 NetworkManager off

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

#Linux 6
yum install -y binutils compat-libcap1 compat-libstdc++-33.x86_64 compat-libstdc++-33.i686 elfutils.x86_64 elfutils-libelf.x86_64 elfutils-libelf-devel.x86_64 gcc.x86_64 gcc-c++.x86_64 glibc.i686 glibc.x86_64 glibc-devel.i686 glibc-devel.x86_64 ksh libgcc.i686 libgcc.x86_64 libstdc++.i686 libstdc++.x86_64 libstdc++-devel.i686 libstdc++-devel.x86_64 libaio.i686 libaio.x86_64 libaio-devel.i686 libaio-devel.x86_64 make.x86_64 sysstat.x86_64

--ϵͳ����
yum install unzip tree sg3_utils pciutils psmisc bc iotop htop iptraf-ng sysfsutils lsscsi util-linux-ng numactl fio iperf iperf3 qperf dstat blktrace iproute dropwatch strace hdparm mdadm perf tuna hwloc valgrind powertop sysfsutils ipmitool

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

cp /etc/sysctl.conf /etc/sysctl.conf.bak

cat >> /etc/sysctl.conf << "EOF"
###################################################################################
##################### change for oracle install #####################

fs.file-max = 6815744
fs.aio-max-nr = 3145728

kernel.msgmni = 2878
kernel.msgmax = 65536
kernel.msgmnb = 65536
kernel.sem = 250 32000 100 142
kernel.shmmni = 4096
kernel.shmall = 16777216 	# SHMALL = MemTotal(byte)/PAGE_SIZE

net.core.rmem_default = 1048576
net.core.wmem_default = 262144
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 262144 16777216
net.ipv4.tcp_wmem = 4096 262144 16777216
net.ipv4.ip_local_port_range = 9000 65500

net.ipv4.conf.bond-priv.rp_filter = 2
net.ipv4.conf.all.rp_filter = 0

#RHEL 6.6���ϰ汾
#net.ipv4.ipfrag_high_thresh = 16777216
#net.ipv4.ipfrag_low_thresh = 15728640

#net.ipv4.tcp_keepalive_time = 30
#net.ipv4.tcp_keepalive_intvl = 60
#net.ipv4.tcp_keepalive_probes = 9
#net.ipv4.tcp_retries2 = 3
#net.ipv4.tcp_syn_retries = 2

#vm.min_free_kbytes = 524288		#�� min_free_kbytes ���ù��ߣ����磬����ϵͳ�ڴ�� 5�C10% ����ʹϵͳ��������һ���ڴ治���״̬������ϵͳ��̫��ʱ���������ڴ档

#vm.nr_hugepages=16384

vm.swappiness = 20
vm.dirty_background_ratio = 3
vm.dirty_ratio = 15
vm.dirty_expire_centisecs = 500
vm.dirty_writeback_centisecs = 100
vm.overcommit_memory = 1

EOF
echo
echo

echo "make kernel change take effect"
/sbin/sysctl -p

echo
echo

# ��ģ����11gR2��RAC ���Ѿ�������Ҫ����
# echo "add hangcheck-timer mode"
# cp /etc/modprobe.conf /etc/modprobe.conf.bak
# 
# cat >> /etc/modprobe.conf << "EOF"
# options hangcheck-timer hangcheck_tick=1 hangcheck_margin=10 hangcheck_reboot=1
# EOF
# echo
# echo
# 
# /sbin/modprobe -v hangcheck-timer
# 
# echo 
# echo
# modprobe -l | grep -i hang

# disable transparent hugepages
# Append the following to the kernel command line in /boot/grub/grub.conf:
# transparent_hugepage=never

echo "###################################################################################"
echo
echo
echo

--��������������Ϣ������169.254����Ĭ��·�ɣ������HAIP����Ӱ��
cat /etc/sysconfig/network
NOZEROCONF=yes

###################################################################################
## 5. ���ù���洢
##    ��Ҫ�ֹ���ɣ�ͨ���ű��鿴���̵�scsi_id��Ϣ�ͷ�����С
##    Oracle�������ݿ�ʹ�õĴ��̵ĵ��Ȳ���Ϊdeadline
##    ������̷�����udev�󶨴��̸��豸
##    /sbin/scsi_id --whitelisted --replace-whitespace --device=/dev/sdb
###################################################################################

# vi diskinfo.sh
#> diskinfo.tmp
#> udevinfo.tmp
#
#cd /dev
#
#for i in $(ls sd* | grep -v sda | grep -v 1$);
#do
#        diskinfo=`fdisk -l /dev/$i | grep "Disk /dev/$i"`
#        scsiinfo=`/sbin/scsi_id --whitelisted --replace-whitespace --device=/dev/$i`
#        echo $diskinfo'         '$scsiinfo >> $OLDPWD/diskinfo.tmp
#        echo "KERNEL==\"sd*\", BUS==\"scsi\", PROGRAM==\"/sbin/scsi_id --whitelisted --replace-whitespace --device=/dev/\$parent\", RESULT==\"`/sbin/scsi_id --whitelisted --replace-whitespace --device=/dev/$i`\", NAME=\"oracleasm/asm-disk$i\", OWNER=\"grid\", GROUP=\"asmadmin\", MODE=\"0660\" # $diskinfo" >> $OLDPWD/udevinfo.tmp
#done
#
#cd $OLDPWD
#
#cat diskinfo.tmp
#cat udevinfo.tmp | awk -F'GB' '{print $1"GB"}'
#rm -f diskinfo.tmp
#rm -f udevinfo.tmp

# vi /etc/udev/rules.d/99-oracle-asmdevices.rules

# ͨ�� partprobe ʹ������Ϣ�ڼ�Ⱥ����Ч
# [root@archdb01 ~]# partprobe

cd /dev
mkdir -p oracleasm
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
cp /etc/security/limits.conf /etc/security/limits.conf.bak

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

