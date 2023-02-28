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
Host lab2
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
Name-Real: lab1
Name-Email: lab1@insec
Expire-Date: 0
Passphrase: insec
# Do a commit here, so that we can later print "done" :-)
%commit
%echo done
EOL
gpg --batch --generate-key gpg-key.conf
gpg --export -a "lab1" > lab1-public.key
gpg --export-ownertrust > lab1-ownertrust.txt

cat > plaintext.txt <<< "Secret message for lab2"

# gpg --import lab2-public.key
# gpg --import-ownertrust lab2-ownertrust.txt
# gpg --fingerprint "lab2"
# gpg -e -r "lab2" plaintext.txt
# scp plaintext.txt.gpg vagrant@lab2:~/
# scp lab1-public.key vagrant@lab2:~/
# scp lab1-ownertrust.txt vagrant@lab2:~/
# gpg --verify plaintext.sign.txt.gpg


dd if=/dev/urandom of=loop.img bs=1k count=32k
FREEDEVICE=$(losetup -f)
sudo losetup $FREEDEVICE loop.img
sudo cryptsetup luksFormat --batch-mode $FREEDEVICE <<< "123456"
sudo cryptsetup luksOpen $FREEDEVICE loopfs <<< "123456"
sudo mkfs.ext2 /dev/mapper/loopfs
sudo mkdir /mnt/loopfs
sudo mount /dev/mapper/loopfs /mnt/loopfs

# sudo umount /dev/mapper/loopfs
# sudo cryptsetup luksClose loopfs

mkdir encrypted
mkdir gocryptfs
gocryptfs -init gocryptfs <<< "123456"
gocryptfs gocryptfs encrypted <<< "123456"
cd encrypted
mkdir dir1
mkdir dir2
echo "File 1" > dir1/file1.txt
echo "File 2" > dir2/file2.txt
cd ..
# fusermount -u encrypted

wget https://launchpad.net/veracrypt/trunk/1.25.9/+download/veracrypt-1.25.9-Ubuntu-22.04-amd64.deb
sudo dpkg -i veracrypt-1.25.9-Ubuntu-22.04-amd64.deb
sudo apt-get -f install -y
head -c 4000 </dev/urandom > outer_keyfile
head -c 4000 </dev/urandom > hidden_keyfile
head -c 4000 </dev/urandom | veracrypt -c outer_volume --size=100M --encryption=AES --hash=SHA-512 --filesystem=Ext4 --volume-type=normal -p 123456 --pim=20 -k=outer_keyfile
head -c 4000 </dev/urandom | veracrypt -c outer_volume --size=50M --encryption=AES --hash=SHA-512 --filesystem=Ext4 --volume-type=hidden -p 123456 --pim=20 -k=hidden_keyfile
mkdir mount_veracrypt_outer
veracrypt outer_volume mount_veracrypt_outer -p 123456 --pim=20 -k=outer_keyfile --protect-hidden yes --protection-password=123456 --protection-pim=20 --protection-keyfiles=hidden_keyfile
# veracrypt --dismount outer_volume
