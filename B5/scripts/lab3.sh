#!/usr/bin/env bash

cat >> ~/.ssh/authorized_keys <<EOL
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLS+lOidBwey5z6gSoHuio4Ik3iV4t/QcgSlopXW5ym songlin.jiang@aalto.fi
EOL

sudo cp /vagrant/Server/pki/private/client1.key /etc/openvpn/
sudo cp /vagrant/CA/pki/issued/client1.crt /etc/openvpn/
sudo cp /vagrant/CA/pki/ca.crt /etc/openvpn/
sudo cp /vagrant/Server/pki/dh.pem /etc/openvpn/
sudo cp /vagrant/Server/ta.key /etc/openvpn/

sudo cp /vagrant/client.conf /etc/openvpn/

## Start client
sudo tee /etc/systemd/system/client.service <<EOL
[Unit]
Description=Client service
[Service]
ExecStart=/bin/bash -c "openvpn /etc/openvpn/client.conf"
[Install]
WantedBy=multi-user.target
EOL
sudo systemctl enable client --now

sudo systemctl stop client
sudo cp /vagrant/client-routed.conf /etc/openvpn/client.conf
sudo systemctl start client

# sudo systemctl stop client
# sudo cp /vagrant/client.conf /etc/openvpn/
# sudo systemctl start client
