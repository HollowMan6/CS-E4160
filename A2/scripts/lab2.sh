#!/usr/bin/env bash

cat >> ~/.ssh/authorized_keys <<EOL
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLS+lOidBwey5z6gSoHuio4Ik3iV4t/QcgSlopXW5ym songlin.jiang@aalto.fi
EOL

sudo apt-get install -y exim4
sudo tee /etc/exim4/conf.d/router/50_exim4-config_lab1_routers <<EOL
manualroute2:
  driver = manualroute
  domains = lab1
  transport = remote_smtp
  route_list = "* lab1 byname"
  no_more
EOL
sudo update-exim4.conf
