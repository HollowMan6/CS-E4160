#!/usr/bin/env bash

cat >> ~/.ssh/authorized_keys <<EOL
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLS+lOidBwey5z6gSoHuio4Ik3iV4t/QcgSlopXW5ym songlin.jiang@aalto.fi
EOL

sudo apt-get install -y exim4

# sudo dpkg-reconfigure exim4-config
sudo sed -i 's/dc_eximconfig_configtype=.*/dc_eximconfig_configtype="satellite"/' /etc/exim4/update-exim4.conf.conf
sudo sed -i 's/dc_other_hostnames=.*/dc_other_hostnames="lab2"/' /etc/exim4/update-exim4.conf.conf
sudo sed -i 's/dc_local_interfaces=.*/dc_local_interfaces=""/' /etc/exim4/update-exim4.conf.conf
sudo sed -i 's/dc_readhost=.*/dc_readhost=""/' /etc/exim4/update-exim4.conf.conf
sudo sed -i 's/dc_relay_domains=.*/dc_relay_domains=""/' /etc/exim4/update-exim4.conf.conf
sudo sed -i 's/dc_minimaldns=.*/dc_minimaldns="false"/' /etc/exim4/update-exim4.conf.conf
sudo sed -i 's/dc_relay_nets=.*/dc_relay_nets=""/' /etc/exim4/update-exim4.conf.conf
sudo sed -i 's/dc_smarthost=.*/dc_smarthost="lab1"/' /etc/exim4/update-exim4.conf.conf
sudo sed -i 's/CFILEMODE=.*/CFILEMODE="644"/' /etc/exim4/update-exim4.conf.conf
sudo sed -i 's/dc_use_split_config=.*/dc_use_split_config="false"/' /etc/exim4/update-exim4.conf.conf
sudo sed -i 's/dc_hide_mailname=.*/dc_hide_mailname="true"/' /etc/exim4/update-exim4.conf.conf
sudo sed -i 's/dc_mailname_in_oh=.*/dc_mailname_in_oh="true"/' /etc/exim4/update-exim4.conf.conf
sudo sed -i 's/dc_localdelivery=.*/dc_localdelivery="mail_spool"/' /etc/exim4/update-exim4.conf.conf
sudo update-exim4.conf
