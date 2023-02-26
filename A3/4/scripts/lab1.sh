#!/usr/bin/env bash

## Key generated with
## ssh-keygen -t ed25519 -C "songlin.jiang@aalto.fi" -f ~/.ssh/id_ed25519 -q -N ""
cat > ~/.ssh/id_ed25519 <<EOL
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACAS0vpTonQcHsuc+oEqB7oqOCJN4leLf0HIEpaKV1ucpgAAAKAzoKMgM6Cj
IAAAAAtzc2gtZWQyNTUxOQAAACAS0vpTonQcHsuc+oEqB7oqOCJN4leLf0HIEpaKV1ucpg
AAAECkuPg9QwI93/BHLRvBJYBpdvBv9VYw3TkiF36y/njcRBLS+lOidBwey5z6gSoHuio4
Ik3iV4t/QcgSlopXW5ymAAAAFnNvbmdsaW4uamlhbmdAYWFsdG8uZmkBAgMEBQYH
-----END OPENSSH PRIVATE KEY-----
EOL

cat > ~/.ssh/id_ed25519.pub <<EOL
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLS+lOidBwey5z6gSoHuio4Ik3iV4t/QcgSlopXW5ym songlin.jiang@aalto.fi
EOL

cat >> ~/.ssh/config <<EOL
Host lab2
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes

Host lab3
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes

Host lab4
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes
EOL

chmod 600 ~/.ssh/*

sudo ip route del default via 10.0.2.2

sudo ip6tables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE
sudo modprobe sit
sudo route add default gw 192.168.2.1
sudo ip tunnel add 6rd mode sit local 192.168.1.1 ttl 64
sudo ip addr add 2a02:2b64:c0a8:101::1/32 dev 6rd
sudo ip link set 6rd up
sudo route -6 add default gw ::192.168.2.1

sudo ip -6 tunnel add ip6tnl1 mode ip4ip6 remote fd01:2345:6789:abc1::2 local fd01:2345:6789:abc1::1
sudo ip link set dev ip6tnl1 up
sudo ip -6 route add fd01:2345:6789:abc1:: dev ip6tnl1 metric 1
sudo ip addr add 10.0.1.1/24 dev ip6tnl1

sudo iptables -t nat -A POSTROUTING -o enp0s9 -j MASQUERADE
