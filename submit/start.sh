#!/bin/bash
bash -c /set_sge_client_env.sh
sleep 1000000
bash -c /data/scripts/qsub.sh
sleep 1000000
