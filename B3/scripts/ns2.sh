#!/usr/bin/env bash

cat >> ~/.ssh/authorized_keys <<EOL
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLS+lOidBwey5z6gSoHuio4Ik3iV4t/QcgSlopXW5ym songlin.jiang@aalto.fi
EOL

sudo tee /etc/bind/named.conf.options <<EOL
options {
    directory "/var/cache/bind";

    listen-on { 127.0.0.1; 192.168.1.3; };
    allow-query { 127.0.0.1; 192.168.1.0/24; };
};
EOL

sudo tee /etc/bind/db.not.insec <<EOL
\$TTL 60
@	IN	SOA	ns2.not.insec. hostmaster.insec. (
			2023021101      ; Serial YYYYMMDDnn
			60		; refresh (1 minute)
			60		; retry (1 minute)
			604800		; expire (1 week)
			60	)	; minimum (1 minute)
			
@	IN	NS	ns2
ns2 IN  A   192.168.1.3
EOL

# tsig-keygen -a HMAC-SHA1 ns2.not.insec
sudo tee /etc/bind/named.conf.local <<EOL
key ns2.key {
	algorithm hmac-sha1;
	secret "/6K0596ZLllo0ncCLjcNc4I/ENc=";
};

zone "insec" {
   type slave;
   file "/etc/bind/db.insec";
   masters { 192.168.1.2; };
};

zone "not.insec" {
   type master;
   file "/etc/bind/db.not.insec";
   allow-transfer { key ns2.key; };
};

zone "1.168.192.in-addr.arpa" {
   type slave;
   file "/etc/bind/db.1.168.192";
   masters { 192.168.1.2; };
};
EOL

sudo service bind9 restart
