#!/bin/bash
sh -x 
mv -rf /tmp/sge/*  /opt/sge/

mkdir /home/sgeuser
useradd -u 10000 sgeuser
chown sgeuser:sgeuser /home/sgeuser/
sudo -u sgeuser bash -c 'ssh-keygen -q -f /home/sgeuser/.ssh/id_rsa -t rsa -P ""'
sudo -u sgeuser bash -c 'cat /home/sgeuser/.ssh/id_rsa.pub >> /home/sgeuser/.ssh/authorized_keys; chmod 600 /home/sgeuser/.ssh/authorized_keys'
sudo -u sgeuser bash -c 'echo -e "Host *\n   StrictHostKeyChecking no\n   UserKnownHostsFile=/dev/null" >> /home/sgeuser/.ssh/config; chmod 600 /home/sgeuser/.ssh/config'
echo "sgeuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
sed -e 's/^SGE_JMX_PORT=.*/SGE_JMX_PORT="6666"/' \
    -e 's/^SGE_JMX_SSL_KEYSTORE=.*/SGE_JMX_SSL_KEYSTORE="\/tmp"/' \
    -e 's/^SGE_JMX_SSL_KEYSTORE_PW=.*/SGE_JMX_SSL_KEYSTORE_PW="\/tmp"/' \
    -e 's/^SGE_JVM_LIB_PATH=.*/SGE_JVM_LIB_PATH="\/tmp"/' \
    -e 's/^HOSTNAME_RESOLVING=.*/HOSTNAME_RESOLVING="true"/' \
    -e "s/^DEFAULT_DOMAIN=.*/DEFAULT_DOMAIN=\"${DEFAULT_DOMAIN:=none}\"/" \
    -e 's/^ADMIN_HOST_LIST=.*/ADMIN_HOST_LIST=\`hostname -f\`/' \
    -e 's/^SUBMIT_HOST_LIST=.*/SUBMIT_HOST_LIST=\`hostname -f\`/' \
    -e 's/^EXEC_HOST_LIST=.*/EXEC_HOST_LIST=""/' \
    /opt/sge/util/install_modules/inst_template.conf > /opt/sge/install_sge_master.conf
sed -e 's/^EXEC_HOST_LIST=.*/EXEC_HOST_LIST=\`hostname -f\`/' \
    /opt/sge/install_sge_master.conf > /opt/sge/install_sge_worker.conf
(cd /opt/sge; ./inst_sge -m -auto ./install_sge_master.conf)
sed -i 's/Port 22/Port 30222/' /etc/ssh/sshd_config
exec /usr/sbin/sshd -D
