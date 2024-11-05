#!/bin/bash
docker compose down
docker volume rm blockchain-hpc_pg_data
docker compose up >& blockchain.log &
sleep 60
./chainnode/populate-cl.sh
