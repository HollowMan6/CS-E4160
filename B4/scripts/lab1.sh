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
EOL

chmod 600 ~/.ssh/*

sudo apt-get install nfs-kernel-server nfs-common -y
