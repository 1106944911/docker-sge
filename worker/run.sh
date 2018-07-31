#!/bin/bash
set -x
useradd -u 10000 sgeuser
echo "sgeuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
host_svc_ip=$(env|grep $(echo ${BATCH_JOB_ID}_${BATCH_TASKGROUP_NAME}${BATCH_TASK_INDEX}_service_host|tr 'a-z' 'A-Z'|tr '-' '_')|awk -F= '{print $2}')
master_ip=$(env|grep SGE|grep MASTER|grep SERVICE_HOST|grep -i $(hostname|awk -F- '{print $1}')|awk -F= '{print $2}')

while true
do
  status=$(sudo -u sgeuser bash -c "ssh -o BatchMode=yes -o ConnectTimeout=5 sgeuser@$master_ip -p 30222 echo ok 2>&1"|tail -n 1)
  echo $status

  if [[ $status = *"ok"* ]];
  then
    echo 'connect master success'
    break
  elif [[ $status = *"Permission denied"* ]];
  then
     echo 'connect master refued'
     sleep 1
  else
     echo 'connect master fail'
     sleep 1
  fi
done

host_name=$(hostname -f)
svc_name=$(env|grep BATCH_CURRENT_HOST|awk -F "=" '{print $2}'|awk -F ","  '{for(i=1;i<=NF;i++){print $i}}'|awk -F ":" '{print $1}'|awk '{for(i = 1;i<=NF;i++){ print$i }}'|tr A-Z a-z)
cp /etc/hosts /etc/hosts.bak
sed  -i "s/$host_name/$svc_name $host_name/g" /etc/hosts.bak
cat /opt/sge/hosts >> /etc/hosts.bak
cat /etc/hosts.bak > /etc/hosts

(sleep 10; cd /opt/sge; ./inst_sge -x -auto install_sge_worker.conf -nobincheck) &
exec /usr/sbin/sshd -D
