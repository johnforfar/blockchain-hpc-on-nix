#!/bin/bash
SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
cd $SCRIPT_DIR
docker compose down
docker volume rm blockchain-hpc_pg_data
docker compose up >& blockchain.log &
sleep 30
./populate-cl.sh
