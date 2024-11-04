#!/bin/bash

docker compose exec link-main-node chainlink admin login -f /chainlink/.api
docker compose exec link-main-node chainlink admin status
docker compose exec link-main-node chainlink bridges create '{
  "name": "executor",
  "url": "http://executor:8000/",
  "confirmations": 1,
  "minimumContractPayment": "0"
}'
docker compose exec link-main-node chainlink jobs create /chainlink/chainnode/node-api1.toml

