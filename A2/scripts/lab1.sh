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

sudo debconf-set-selections <<< "postfix postfix/mailname string lab1"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
sudo apt-get install -y postfix procmail spamassassin mailutils

sudo sed -i 's#mynetworks =#mynetworks = 192.168.1.3#' /etc/postfix/main.cf

echo 'disable_vrfy_command = yes' | sudo tee -a /etc/postfix/main.cf
## https://www.postfix.org/ETRN_README.html
echo 'fast_flush_domains =' | sudo tee -a /etc/postfix/main.cf
echo 'smtpd_discard_ehlo_keywords = etrn' | sudo tee -a /etc/postfix/main.cf
sudo postfix reload

sudo tee -a /etc/procmailrc <<EOL
:0fw
| /usr/bin/spamassassin
* ^X-Spam-Status: Yes
spam/
EOL
# /usr/bin/procmail -a "$USER"
sudo postfix reload
sudo update-rc.d spamassassin enable

tee -a ~/.procmailrc <<EOL
:0
* ^Subject:.*\[cs-e4160\]
cs-e4160/
EOL
