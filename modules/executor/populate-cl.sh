#!/bin/bash

docker compose exec link-main-node chainlink admin login -f /chainlink/.api
docker compose exec link-main-node chainlink admin status
docker compose exec link-main-node chainlink bridges create '{
  "name": "test1",
  "url": "http://test1/",
  "confirmations": 1,
  "minimumContractPayment": "0"
}'



