#!/bin/bash

flock -n /var/run/salaryzen/aggregator.lock timeout -k 2m 3m /opt/SalaryZen/SalaryZenAggregator/aggregate.sh -o /etc/public_files/salaryzen/datav1.json >> /var/log/salaryzen/aggregate.log 2>&1
