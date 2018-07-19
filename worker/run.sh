#!/bin/bash
set -x
useradd -u 10000 sgeuser
echo "sgeuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
host_svc_ip=$(env|grep $(echo ${BATCH_JOB_ID}_${BATCH_TASKGROUP_NAME}${BATCH_TASK_INDEX}_service_host|tr 'a-z' 'A-Z'|tr '-' '_')|awk -F= '{print $2}')
master_ip=$(env|grep SGE|grep MASTER|grep SERVICE_HOST|grep -i $(hostname|awk -F- '{print $1}')|awk -F= '{print $2}')
while true;then
do
  status=$(sudo -u sgeuser bash -c "ssh -o BatchMode=yes -o ConnectTimeout=5 sgeuser@$master_ip -p 30222 echo ok 2>&1"|tail -n 1)

  if [[ $status == ok ]] ; then
    echo 'connect master success'
    break
  elif [[ $status == "Permission denied"* ]] ; then
     echo 'connect master refued'
  else
     echo 'connect master fail'
  fi
done


(sleep 10; sudo -u sgeuser bash -c "ssh ${master_ip} -p 30222 \"sudo bash -c 'echo $host_svc_ip $hostname;. /etc/profile.d/sge.sh; qconf -ah `hostname -f`; qconf -as `hostname -f`'\""; cd /opt/sge; ./inst_sge -x -auto install_sge_worker.conf -nobincheck) &
exec /usr/sbin/sshd -D
