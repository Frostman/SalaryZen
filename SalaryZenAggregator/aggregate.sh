#!/bin/bash

cd /opt/SalaryZen
git reset --hard HEAD
git pull origin
cd SalaryZenAggregator
virtualenv venv
. venv/bin/activate
pip install -U -r requirements.txt
python aggregator.py -o $1
deactivate
