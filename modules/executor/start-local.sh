#!/bin/bash
export TRUFLATION_API_HOST=http://localhost:8081/
export TFI_ORDERS_LOCAL_LOGLEVEL=DEBUG
export PYTHONPATH=~/.local/lib/python3.10/site-packages
flask --app executor  run --debugger --port=8000


