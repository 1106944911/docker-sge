#!/bin/bash
bash -c /set_sge_client_env.sh
action_file=$1
bash -c " /data/scripts/qsub.sh $action_file "

