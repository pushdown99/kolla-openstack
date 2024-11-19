#!/bin/bash

ipaddr=`ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1`
ips=(`echo $ipaddr | tr "." "\n"`)
echo "${ips[@]}"
echo "${ips[1]}"