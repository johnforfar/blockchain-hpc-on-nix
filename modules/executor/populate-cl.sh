#!/bin/bash

docker compose exec link-main-node chainlink admin login -f /chainlink/.api
docker compose exec link-main-node chainlink admin status



