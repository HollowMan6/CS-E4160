#!/usr/bin/env bash

cat <<EOF | sudo debconf-set-selections
davfs2 davfs2/suid_file boolean false
EOF

sudo apt-get install nfs-common cifs-utils sshfs cadaver davfs2 -y

sudo adduser --disabled-password --gecos "" --uid 1002 testuser1
sudo adduser --disabled-password --gecos "" --uid 1003 testuser2

## Key generated with
## ssh-keygen -t ed25519 -C "songlin.jiang@aalto.fi" -f ~/.ssh/id_ed25519 -q -N ""
sudo -u testuser1 mkdir /home/testuser1/.ssh
sudo -u testuser1 tee -a /home/testuser1/.ssh/id_ed25519 <<EOL
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACAS0vpTonQcHsuc+oEqB7oqOCJN4leLf0HIEpaKV1ucpgAAAKAzoKMgM6Cj
IAAAAAtzc2gtZWQyNTUxOQAAACAS0vpTonQcHsuc+oEqB7oqOCJN4leLf0HIEpaKV1ucpg
AAAECkuPg9QwI93/BHLRvBJYBpdvBv9VYw3TkiF36y/njcRBLS+lOidBwey5z6gSoHuio4
Ik3iV4t/QcgSlopXW5ymAAAAFnNvbmdsaW4uamlhbmdAYWFsdG8uZmkBAgMEBQYH
-----END OPENSSH PRIVATE KEY-----
EOL

sudo -u testuser1 tee -a /home/testuser1/.ssh/id_ed25519.pub <<EOL
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLS+lOidBwey5z6gSoHuio4Ik3iV4t/QcgSlopXW5ym songlin.jiang@aalto.fi
EOL

sudo -u testuser1 tee -a /home/testuser1/.ssh/authorized_keys <<EOL
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLS+lOidBwey5z6gSoHuio4Ik3iV4t/QcgSlopXW5ym songlin.jiang@aalto.fi
EOL

sudo -u testuser1 tee -a /home/testuser1/.ssh/config <<EOL
Host lab1
    AddKeysToAgent yes
    IdentityFile /home/testuser1/.ssh/id_ed25519
    ForwardAgent yes
EOL

sudo -u testuser1 chmod 600 /home/testuser1/.ssh/id_ed25519

sudo mount -t nfs lab1:/home /mnt
sudo -u testuser1 cat /mnt/testuser1/test.txt
sudo umount /mnt

sudo mount -t cifs -o username=testuser1 -o password=123456 //lab1/testuser1 /mnt
cat /mnt/test.txt
sudo umount /mnt

sudo -u testuser1 mkdir /home/testuser1/mnt
sudo -u testuser1 sshfs -o StrictHostKeyChecking=no lab1:/home/testuser1 /home/testuser1/mnt
# sudo -u testuser1 umount /home/testuser1/mnt

echo "test" > test.txt
# cadaver http://lab1/webdav
# testuser
# 123456
# put /home/vagrant/test.txt
# exit

## This will disable file locking, which is not supported by some WebDAV servers.
sudo tee -a /etc/davfs2/davfs2.conf <<< "use_locks 0"
sudo mkdir /mnt/webdav
sudo mount -t davfs http://lab1/webdav /mnt/webdav -o username=testuser <<< "123456"
# sudo umount /mnt/webdav

sudo mkdir /mnt/raid5
sudo mount -t nfs lab1:/mnt/raid5 /mnt/raid5
cp ~/test.txt /mnt/raid5/test.txt
# sudo umount /mnt/raid5

