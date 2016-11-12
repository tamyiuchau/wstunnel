#!/bin/bash
iptables -t mangle -N WSTUNNEL
iptables -t mangle -A OUTPUT --protocol tcp --out-interface eth0 --sport 25566 --jump WSTUNNEL
iptables -t mangle -A WSTUNNEL --jump MARK --set-mark 0x1
iptables -t mangle -A WSTUNNEL --jump ACCEPT
ip rule add fwmark 0x1 lookup 100
ip route add local 0.0.0.0/0 dev lo table 100

./bin/node ./bin/wstt.js -s 0.0.0.0:35566 -t 192.168.0.1:25566
