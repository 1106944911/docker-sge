
#!/bin/bash
set -x
function set_input_and_output_777()
{

 input=${BATCH_INPUT_PATH//\"/}
 input=${input//[/}
 input=${input//]/}
 input=${input//,/ }
 for path in $input
 do
    echo $path
    path_stat=$(stat -c "%a" $path)
    if [ $path_stat -ne 777 ]
    then
      echo "change file stat 777"
      chmod -R 777 $path
    fi
 done

 output=${BATCH_OUTPUT_PATH//\"/}
 output=${output//[/}
 output=${output//]/}
 output=${output//,/ }
  echo  ${output}
 for path in $output
 do
    echo $path
    path_stat=$(stat -c "%a" $path)
    if [ $path_stat -ne 777 ]
    then
      echo "change file stat 777"
      chmod -R 777 $path
    fi
 done
}

set_input_and_output_777

useradd -u 10000 sgeuser
echo "sgeuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
host_svc_ip=$(env|grep SERVICE_HOST|grep $(env|grep BATCH_CURRENT_HOST|awk -F '=' '{print $2}'|awk -F ':' '{print $1}'|tr '-' '_'|tr 'a-z' 'A-Z')|awk -F= '{print $2}')
if [[ -z "$SGE_MASTER_JOB_ID" ]];
then
   sge_master_job_id=$BATCH_JOB_ID
else
   echo 'user set sge master job'
   sge_master_job_id=$SGE_MASTER_JOB_ID
fi
   
master_ip=$(env|grep -i $sge_master_job_id|grep SGE|grep MASTER|grep SERVICE_HOST|grep -i $(hostname|awk -F- '{print $1}')|awk -F= '{print $2}')

while true
do
  if [[ -z "$master_ip" ]];
  then
    while true
    do
      master_ip=$(cat /opt/sge/hosts|grep -i $sge_master_job_id|grep master|awk '{print $1}')
      if [[ -z "$master_ip" ]];
      then
        echo $master_ip
        sleep 1
      else
        break
      fi
    done
  fi

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

cat /opt/sge/hosts|grep $master_ip >> /etc/hosts
host_name=$(hostname)
echo ${host_svc_ip}  ${host_name} >> /opt/sge/hosts
sudo -u sgeuser bash -c "ssh ${master_ip} -p 30222 \"sudo bash -c '. /etc/profile.d/sge.sh; echo ${host_svc_ip}  ${host_name}>>/etc/hosts; qconf -ah `hostname -f`; qconf -as `hostname -f`'\""; cd /opt/sge; ./inst_sge -s -auto install_sge_worker.conf -nobincheck


#(sleep 1; sudo -u sgeuser bash -c "ssh ${master_ip} -p 30222 \"sudo bash -c '. /etc/profile.d/sge.sh; echo ${host_svc_ip}  ${host_name}>>/etc/hosts; qconf -ah `hostname -f`; qconf -as `hostname -f`'\""; cd /opt/sge; ./inst_sge -s -auto install_sge_worker.conf -nobincheck) &

#sudo su sgeuser bash -c '. /etc/profile.d/sge.sh; echo "/bin/hostname" | qsub'
