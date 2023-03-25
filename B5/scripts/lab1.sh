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

sudo cp /vagrant/Server/pki/private/server.key /etc/openvpn/
sudo cp /vagrant/CA/pki/issued/server.crt /etc/openvpn/
sudo cp /vagrant/CA/pki/ca.crt /etc/openvpn/
sudo cp /vagrant/Server/pki/dh.pem /etc/openvpn/
sudo cp /vagrant/Server/ta.key /etc/openvpn/

sudo cp /vagrant/server.conf /etc/openvpn/

sudo cp /usr/share/doc/openvpn/examples/sample-scripts/bridge-start /etc/openvpn/
sudo sed -i 's/eth0/enp0s8/g' /etc/openvpn/bridge-start
sudo sed -i 's/192.168.8./192.168.0./g' /etc/openvpn/bridge-start
sudo sed -i 's/192.168.0.4/192.168.0.2/g' /etc/openvpn/bridge-start
sudo /etc/openvpn/bridge-start

## Start server
sudo systemctl enable openvpn@server --now

sudo cp /usr/share/doc/openvpn/examples/sample-scripts/bridge-stop /etc/openvpn/

# sudo systemctl stop openvpn@server
# sudo /etc/openvpn/bridge-stop

# sudo cp /vagrant/server-routed.conf /etc/openvpn/server.conf
# sudo systemctl start openvpn@server

sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE





# sudo systemctl stop openvpn@server
# sudo cp /vagrant/server.conf /etc/openvpn
# sudo /etc/openvpn/bridge-start
# sudo systemctl start openvpn@server
