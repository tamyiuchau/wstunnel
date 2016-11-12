#!/bin/bash
trap ' ' INT

iptables -t mangle -N WSTUNNEL
iptables -t mangle -A OUTPUT --protocol tcp --out-interface ext1 --sport 25566 --jump WSTUNNEL
iptables -t mangle -A WSTUNNEL --jump MARK --set-mark 0x1
iptables -t mangle -A WSTUNNEL --jump ACCEPT
ip rule add pref 10000 fwmark 0x1 lookup 100
ip route flush table 100
ip route add local 0.0.0.0/0 dev lo table 100

# node must be executed as root or has cap
node ./bin/wstt.js -s 0.0.0.0:35566 -t 192.168.0.1:25566

ip rule del pref 10000
ip route flush table 100
iptables -t mangle -F WSTUNNEL
iptables -t mangle -D OUTPUT --protocol tcp --out-interface ext1 --sport 25566 --jump WSTUNNEL
