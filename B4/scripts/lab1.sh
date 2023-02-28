#!/usr/bin/env bash

sudo apt-get install nfs-kernel-server samba elinks apache2 mdadm -y

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

# sudo -u testuser1 chmod 600 /home/testuser1/.ssh/*

sudo tee -a /etc/exports <<EOL
/home lab2(rw,sync,no_subtree_check)
EOL
sudo systemctl restart nfs-kernel-server.service
sudo -u testuser1 tee /home/testuser1/test.txt <<< "Hello world"

sudo tee -a /etc/samba/smb.conf <<EOL
[homes]
   comment = Home Directories
   browseable = no
   read only = no
   create mask = 0755
   directory mask = 0755
EOL
sudo systemctl reload smbd.service
sudo smbpasswd -a testuser1 -s << EOL
123456
123456
EOL
sudo smbpasswd -e testuser1

sudo a2enmod dav_fs
sudo a2enmod auth_digest
sudo systemctl restart apache2
sudo mkdir -p /var/www/WebDAV/files
sudo chown -R www-data:vagrant /var/www/WebDAV
sudo chmod -R 755 /var/www/WebDAV
sudo ln -s /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/
# sudo htdigest -c /var/www/WebDAV/.htdigest your_auth_name testuser1
sudo tee -a /var/www/WebDAV/.htdigest <<EOL
testuser1:your_auth_name:220d38838d8b39f8c238b6b649737537
EOL
sudo chown www-data:root /var/www/WebDAV/.htdigest
sudo chmod 640 /var/www/WebDAV/.htdigest
sudo tee -a /etc/apache2/sites-available/000-default.conf <<EOL
Alias /webdav /var/www/WebDAV/files
<Location /webdav>
    DAV On
    AuthType Digest
    AuthName "your_auth_name"
    AuthUserFile /var/www/WebDAV/.htdigest
    Require valid-user
</Location>
EOL
sudo systemctl restart apache2

sudo mdadm --create --verbose /dev/md0 --level=5 --raid-devices=3 /dev/sdc /dev/sdd /dev/sde
sudo mkfs.ext4 /dev/md0
sudo mkdir /mnt/raid5
sudo mount /dev/md0 /mnt/raid5
sudo mdadm --detail /dev/md0

sudo tee -a /etc/exports <<EOL
/mnt/raid5 *(rw,sync,no_subtree_check)
EOL
sudo systemctl restart nfs-kernel-server
