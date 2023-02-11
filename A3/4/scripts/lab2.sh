#!/usr/bin/env bash

cat >> ~/.ssh/authorized_keys <<EOL
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLS+lOidBwey5z6gSoHuio4Ik3iV4t/QcgSlopXW5ym songlin.jiang@aalto.fi
EOL

sudo ip route del default via 10.0.2.2
sudo ip -6 route add fd01:2345:6789:abc2::/64 via fd01:2345:6789:abc1::1 dev enp0s8