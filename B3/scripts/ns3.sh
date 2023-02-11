#!/usr/bin/env bash

cat >> ~/.ssh/authorized_keys <<EOL
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLS+lOidBwey5z6gSoHuio4Ik3iV4t/QcgSlopXW5ym songlin.jiang@aalto.fi
EOL

sudo tee /etc/bind/named.conf.options <<EOL
options {
    directory "/var/cache/bind";

    listen-on { 127.0.0.1; 192.168.1.4; };
    allow-query { 127.0.0.1; 192.168.1.0/24; };
};
EOL

sudo tee /etc/bind/named.conf.local <<EOL
key ns2.key {
	algorithm hmac-sha1;
	secret "/6K0596ZLllo0ncCLjcNc4I/ENc=";
};

server 192.168.1.3 {
  keys { ns2.key; };
};

zone "not.insec" {
   type slave;
   file "/etc/bind/db.not.insec";
   masters { 192.168.1.3; };
};
EOL

sudo service bind9 restart
