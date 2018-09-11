#!/bin/bash
set -x
chmod -R 777 /batch_holder/fvvirmp/*
bash -c /set_sge_client_env.sh
qsub_script=$1
action_file=$2

bash -c " ${qsub_script} ${action_file} "
