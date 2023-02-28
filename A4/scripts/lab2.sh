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

cat >> ~/.ssh/authorized_keys <<EOL
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLS+lOidBwey5z6gSoHuio4Ik3iV4t/QcgSlopXW5ym songlin.jiang@aalto.fi
EOL

cat >> ~/.ssh/config <<EOL
Host lab1
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes
EOL

chmod 600 ~/.ssh/*

sudo modprobe dm_crypt aes
# sudo rmmod cryptoloop
sudo apt-get install gocryptfs -y

cat > gpg-key.conf <<EOL
%echo Generating a basic OpenPGP key
Key-Type: RSA
Key-Length: 2048
Subkey-Type: RSA
Subkey-Length: 2048
Name-Real: lab2
Name-Email: lab2@insec
Expire-Date: 0
Passphrase: insec
# Do a commit here, so that we can later print "done" :-)
%commit
%echo done
EOL
gpg --batch --generate-key gpg-key.conf
gpg --export -a "lab2" > lab2-public.key
gpg --export-ownertrust > lab2-ownertrust.txt
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r lab2-public.key vagrant@lab1:~/
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r lab2-ownertrust.txt vagrant@lab1:~/

cat > plaintext.sign.txt <<< "Message for lab1"
gpg --pinentry-mode=loopback --passphrase insec -s plaintext.sign.txt
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r plaintext.sign.txt.gpg vagrant@lab1:~/

# gpg --import lab1-public.key
# gpg --import-ownertrust lab1-ownertrust.txt
# gpg --fingerprint "lab1"
# gpg --pinentry-mode=loopback --passphrase insec -d plaintext.txt.gpg > decrypted.txt
