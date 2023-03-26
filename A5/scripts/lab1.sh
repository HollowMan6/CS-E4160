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
EOL

chmod 600 ~/.ssh/*

sudo modprobe ip_conntrack_ftp
sudo apt install -y squid

# Create a table and a chain for the FORWARD hook with nftables:
sudo nft add table inet filter
# sudo nft add chain inet filter forward { type filter hook forward priority 0 \; policy drop \; }
# # This will create a table named filter and a chain named forward that will drop all packets by default.

# # Allow ping from lab2 on the enp0s8 interface and replies to lab2:
# sudo nft add rule inet filter forward iif enp0s8 icmp type echo-request counter accept
# sudo nft add rule inet filter forward oif enp0s8 icmp type echo-reply counter accept

# # Allow TCP packets with destination port 22 (SSH) from lab2 to initiate new or established connections, and TCP packets
# # with source port 22 from lab2 to continue established connections.
# sudo nft add rule inet filter forward iif enp0s8 tcp dport 22 ct state new,established counter accept
# sudo nft add rule inet filter forward oif enp0s8 tcp sport 22 ct state established counter accept

# # Allow TCP packets with destination port 80 (HTTP) from lab2 to initiate
# # new or established connections, and TCP packets with source port 80 from lab2 to
# # continue established connections.
# sudo nft add rule inet filter forward iif enp0s8 tcp dport 80 ct state new,established counter accept
# sudo nft add rule inet filter forward oif enp0s8 tcp sport 80 ct state established counter accept

# # Allow TCP packets with destination port 20 (FTP data) or 21 (FTP control) from lab2 to initiate new or established connections,
# # and TCP packets with source port 20 or 21 from lab2 to continue established connections. Also allow Passive FTP connections
# sudo nft add rule inet filter forward iif enp0s8 tcp dport {20-21} accept
# sudo nft add rule inet filter forward oif enp0s8 tcp sport {20-21} accept
# sudo nft add rule inet filter forward iif enp0s9 tcp dport {20-21} accept
# sudo nft add rule inet filter forward oif enp0s9 tcp sport {20-21} accept
# sudo nft add rule inet filter forward iif enp0s8 tcp dport {49152-65535} accept
# sudo nft add rule inet filter forward oif enp0s8 tcp sport {49152-65535} accept
# sudo nft add rule inet filter forward iif enp0s9 tcp dport {49152-65535} accept
# sudo nft add rule inet filter forward oif enp0s9 tcp sport {49152-65535} accept

sudo nft add table ip filter
sudo nft add chain ip filter prerouting { type nat hook prerouting priority 0 \; policy accept \; }

# sudo nft add rule ip filter prerouting iifname enp0s8 ip saddr lab2 tcp dport 80 redirect to :8000

sudo tee -a /etc/squid/squid.conf <<EOL
http_port 8000 transparent
http_reply_access allow all
EOL
sudo sed -i 's/http_access deny all/http_access allow all/g' /etc/squid/squid.conf
# sudo systemctl restart squid

# sudo tee -a /etc/squid/squid.conf <<EOL
# acl lab3 dstdomain lab3
# never_direct allow lab3
# EOL
# sudo systemctl restart squid
