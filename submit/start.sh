#!/bin/bash
set -x
bash -c /set_sge_client_env.sh
sleep 1000000
action_file=$1
sleep 20
bash -c " /data/scripts/qsub.sh $action_file "

