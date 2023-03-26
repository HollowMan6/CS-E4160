#!/usr/bin/env bash

sudo tee /etc/nftables.conf <<EOL
#!/usr/sbin/nft -f

flush ruleset

table ip nat {
    chain prerouting {
        type nat hook prerouting priority 0; policy accept;
        tcp dport 8080 dnat to 192.168.0.3:80
    }

    chain postrouting {
        type nat hook postrouting priority 0; policy accept;
        oif enp0s3 masquerade
    }
}

table inet filter {
    chain input {
        type filter hook input priority 0; policy accept;
        iif lo accept
        tcp dport 22 accept
        tcp dport 8080 accept
        drop
    }

    chain output {
		type filter hook output priority 0;
	}

    chain forward {
        type filter hook forward priority 0; policy accept;
        iif enp0s9 oif enp0s8 ct state new,related,established accept
        iif enp0s8 oif enp0s9 ct state related,established accept
        drop
    }
}
EOL
sudo systemctl reload nftables
