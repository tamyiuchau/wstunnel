# wstunnel (For servers with internal TCP transparent proxy)

Establish a TCP socket tunnel over web socket connection, for circumventing strict firewalls. Server can see the real connecting IP behind (even with CloudFlare). 

## Installation

1. Only Linux systems are supported. BSD is unknown.
2. Install `git` and (`node` or `nodejs`) packages.
2. `$ git clone https://github.com/Saren-Arterius/wstunnel.git`
3. `$ cd wstunnel`
4. `$ npm install`

## Usage

Assume that:

1. You have a TCP service listening on port `25565`
2. Your external network interface is `eth0`, which IP is `192.168.0.50`
3. Your internet IP is `8.8.8.8`
4. `wstunnel` will be listening on port `35565`

In that case, clients will be connecting to `8.8.8.8:25565` through `ws://8.8.8.8:35565`.

### Give node `CAP_NET_ADMIN`

To make transparent proxy work, we need to give node's executable `CAP_NET_ADMIN` capability. If you wish `wstunnel` to listen on lower ports, `CAP_NET_BIND_SERVICE` should be given as well. If you just don't care about security, simply run node as root.

To give it capability, you can either:

1. `# cd bin && cp /usr/bin/node . && setcap cap_net_admin+pe node`
2. `# setcap cap_net_admin+pe /usr/bin/node`
3. Make a systemd unit as the following then start it later
```
[Unit]
After=network.target
Documentation=man:dnsmasq(8)

[Service]
ExecStart=/usr/bin/node /path/to/wstunnel/bin/wstt.js -s 0.0.0.0:35565 -t 192.168.0.50:25565
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=1
KillMode=process
CapabilityBoundingSet=CAP_NET_ADMIN
PrivateTmp=true
PrivateDevices=true
ProtectSystem=full
ProtectHome=true
User=nobody

[Install]
WantedBy=multi-user.target
```

### Setup firewall

1. `# iptables -t mangle -N WSTUNNEL`
2. `# iptables -t mangle -A OUTPUT --protocol tcp --out-interface eth0 --sport 25565 --jump WSTUNNEL`
3. `# iptables -t mangle -A WSTUNNEL --jump MARK --set-mark 0x1`
4. `# iptables -t mangle -A WSTUNNEL --jump ACCEPT`
5. `# ip rule add fwmark 0x1 lookup 100`
6. `# ip route add local 0.0.0.0/0 dev lo table 100`

### Run wstunnel

- If you have previously made a systemd unit, simply start it.
- If you copied `node` to `/path/to/wstunnel/bin/` and performed `setcap`, `$ /path/to/wstunnel/bin/node /path/to/wstunnel/bin/wstt.js -s 0.0.0.0:35565 -t 192.168.0.50:25565`
- If you performed `setcap` on `/usr/bin/node`, `$ /usr/bin/node /path/to/wstunnel/bin/wstt.js -s 0.0.0.0:35565 -t 192.168.0.50:25565`
- If you don't care at all, `# /usr/bin/node /path/to/wstunnel/bin/wstt.js -s 0.0.0.0:35565 -t 192.168.0.50:25565`

## Gotchas
- Don't do `# /usr/bin/node /path/to/wstunnel/bin/wstt.js -s 0.0.0.0:35565 -t 127.0.0.1:25565`, you must proxy to traffic to a non-lo IP address. Just use `192.168.0.50:25565`.

## Project mothership
- https://github.com/mhzed/wstunnel (Base)
- https://github.com/inDream/wstunnel (Original transparent proxy fork)

## Thanks
- yrutschle for [sslh repo](https://github.com/yrutschle/sslh) and [answers to my question](https://github.com/yrutschle/sslh/issues/100)
- inDream for code changes and implementation 
- You for reading this
