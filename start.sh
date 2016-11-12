#!/bin/bash
# This script must be run as root
MY_LAN_OR_WAN_IP=192.168.0.1
MY_PUBLIC_INTERFACE=ext1
TCP_SERVICE_PORT=25566
WSTUNNEL_PORT=35566

trap ' ' INT

iptables -t mangle -N WSTUNNEL
iptables -t mangle -A OUTPUT --protocol tcp --out-interface ${MY_PUBLIC_INTERFACE} --sport ${TCP_SERVICE_PORT} --jump WSTUNNEL
iptables -t mangle -A WSTUNNEL --jump MARK --set-mark 0x1
iptables -t mangle -A WSTUNNEL --jump ACCEPT
ip rule add pref 10000 fwmark 0x1 lookup 100
ip route flush table 100
ip route add local 0.0.0.0/0 dev lo table 100

node ./bin/wstt.js -s 0.0.0.0:${WSTUNNEL_PORT} -t ${MY_LAN_OR_WAN_IP}:${TCP_SERVICE_PORT}

ip rule del pref 10000
ip route flush table 100
iptables -t mangle -F WSTUNNEL
iptables -t mangle -D OUTPUT --protocol tcp --out-interface ${MY_PUBLIC_INTERFACE} --sport ${TCP_SERVICE_PORT} --jump WSTUNNEL
