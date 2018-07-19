#!/bin/bash

/usr/sbin/service rpcbind start
mount -t nfs ${SGE_USER_HOME}  /home
mount -t nfs ${SGE_WORK_HOME} /opt
useradd -u 10000 sgeuser
echo "sgeuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
master_ip=$(env|grep SGE|grep MASTER|grep SERVICE_HOST|awk -F= '{print $2}')
(sleep 10; sudo -u sgeuser bash -c "ssh ${master_ip} -p 30222 \"sudo bash -c '. /etc/profile.d/sge.sh; qconf -ah `hostname -f`; qconf -as `hostname -f`'\""; cd /opt/sge; ./inst_sge -x -auto install_sge_worker.conf -nobincheck) &
exec /usr/sbin/sshd -D
