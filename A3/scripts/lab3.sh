#!/usr/bin/env bash

cat >> ~/.ssh/authorized_keys <<EOL
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLS+lOidBwey5z6gSoHuio4Ik3iV4t/QcgSlopXW5ym songlin.jiang@aalto.fi
EOL

sudo sysctl -w net.ipv6.conf.default.forwarding=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1
sudo sysctl -w net.ipv6.conf.enp0s3.accept_ra=0

# 2.3
sudo ip -6 addr add fd01:2345:6789:abc2::2/64 dev enp0s8
# 2.4
sudo ip -6 route add fd01:2345:6789:abc1::/64 via fd01:2345:6789:abc2::1 dev enp0s8

# # 3
# sudo ip -6 addr flush dev enp0s8
# sudo ip link set down dev enp0s8

# sudo ip link set up dev enp0s8
# sudo tcpdump -i enp0s8 icmp6
