#!/usr/bin/env bash

cat >> ~/.ssh/authorized_keys <<EOL
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLS+lOidBwey5z6gSoHuio4Ik3iV4t/QcgSlopXW5ym songlin.jiang@aalto.fi
EOL

sudo ip route del default via 10.0.2.2

sudo route -6 add default gw fd01:2345:6789:abc2::1
sudo ip -6 route add fd01:2345:6789:abc1::/64 via fd01:2345:6789:abc2::1 dev enp0s8

sudo ip -6 tunnel add ip6tnl1 mode ip4ip6 remote fd01:2345:6789:abc2::1 local fd01:2345:6789:abc2::2
sudo ip link set dev ip6tnl1 up 
sudo ip -6 route add fd01:2345:6789:abc2:: dev ip6tnl1 metric 1
sudo ip addr add 10.0.1.2/24 dev ip6tnl1

sudo ip route add default via 10.0.1.2
 