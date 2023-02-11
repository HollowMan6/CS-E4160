#!/usr/bin/env bash

cat >> ~/.ssh/authorized_keys <<EOL
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLS+lOidBwey5z6gSoHuio4Ik3iV4t/QcgSlopXW5ym songlin.jiang@aalto.fi
EOL

sudo modprobe sit
sudo ip tunnel add 6rd mode sit local 192.168.2.1 ttl 64
sudo ip tunnel 6rd dev 6rd 6rd-prefix 2a02:2b64::/32
sudo ip addr add 2a02:2b64:c0a8:0201::1/32 dev 6rd
sudo ip link set 6rd up
sudo ip -6 route add fd01:2345:6789:abc1::/64 via ::192.168.1.1 dev 6rd
