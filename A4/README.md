# A4: Encrypted filesystems
## Prerequisites
You should have a basic idea of filesystems in general and filesystems in Linux in particular. Also, you should have an idea of how Linux treats devices in general and storage and virtual devices in particular. Here are some resources:
1. Linux Filesystem Introduction
2. Device File
3. File System Architectures (an informal guide)
4. File system (Wikipedia)

## Motivation
From a practical and sysadmin perspective, whether it’s from hackers breaking into your server, you losing your USB drive or your laptop getting stolen, it is a good rule of thumb to assume attackers can have access to your data. Suitably protecting your data with encryption can ensure the attackers don’t get access to your precious data ( within a reasonably long time).

Data protection can be conceptually divided into security of data at rest and security of data in transit. Data in transit then refers to data that is actively traversing networks. Unlike data in transit, data at rest is data that is not actively being transferred from one node to another in a network. This includes data stored in storage devices like hard drives, flash drives, solid state drives etc. Data protection at rest aims to secure this type of static data. While data at rest is sometimes considered to be less vulnerable than data in transit, it is often more valuable and once an attacker has physical access to it, easier to remove its data protection. Common data at rest encryption methods are of two broad types depending on their layer of operation:

1.    Stacked filesystem encryption: Available solutions in this category are eCryptfs, gocryptfs and EncFS.
2.    Block device encryption : The following "block device encryption" solutions are available, loop-AES, dm-crypt,  TrueCrypt/VeraCrypt

The management of dm-crypt is done with the cryptsetup userspace utility. It can be used for the following types of block-device encryption: LUKS (default), plain, and has limited features for loopAES and Truecrypt devices.
Description of the exercise

In this exercise you will simulate encryption of an external memory (such as USB memory stick) using a file as the storage media. Simulation is needed because there is no physical access to the server machines (in addition, the servers are virtual). Two different schemes will be used: encrypted loopback device with dm_crypt and encryption layer for an existing filesystem with gocryptfs. However, we will begin by familiarizing with GPG and encrypting single files.

## 1. Preparation
You will need lab1 and lab2 for this assignment. Check that you have the following packages installed:
- cryptsetup
- gnupg
- haveged

Load the dm_crypt and aes kernel modules [lsmod(8), modprobe(8)]. Remove cryptoloop from use, if it's attached to the kernel.


For the fourth task, ensure that you have gocryptfs installed and FUSE is available. This should be done in a similar fashion as the earlier checks.

## 2. Encrypting a single file using GnuPG
Begin by creating a GPG keypair on both lab1 and lab2 using the RSA algorithm and 2048 bit keys. Exchange (and verify) the public keys between lab1 and lab2.

Create a plaintext file with some text in it on lab1. Encrypt the file using lab2's public key, and send the encrypted file to lab2. Now decrypt the file.

Finally, sign a plaintext file on lab2, send the file with its signature to lab1. Verify on lab1 that it really was the lab2 user that signed the message.

### 2.1 What are the differences between stacked file system encryption and Block device encryption?

Stacked filesystem encryption encrypts individual files or directories within a filesystem, while block device encryption encrypts the entire block device. In stacked filesystem encryption, the encryption is transparent to the applications that access the files and directories, whereas in block device encryption, the encryption is transparent to the operating system that manages the block device.

In stacked filesystem encryption, each file or directory has its own encryption key, whereas in block device encryption, the entire block device is encrypted with a single key.

### 2.2 Provide the commands you used for creating and verifying the keys and explain what they do.

To generate a GPG keypair with RSA algorithm and 2048 bit keys, the following command can be used:

```bash
gpg --full-generate-key
```
This command starts the GPG key generation process and prompts for the user's name, email address, and passphrase.

To export the public key, the following command can be used:

```bash
gpg --export -a "User Name" > public_key.asc
```
This command exports the public key and saves it in ASCII armored format to a file named public_key.asc.

To import a public key, the following command can be used:

```bash
gpg --import public_key.asc
```
This command imports the public key from the file public_key.asc.

To encrypt a file with GPG, the following command can be used:

```bash
gpg --encrypt --recipient "Recipient Name" plaintext_file.txt
```
This command encrypts the file plaintext_file.txt with the recipient's public key.

To decrypt a file with GPG, the following command can be used:

```bash
gpg --decrypt encrypted_file.txt.gpg
```
This command decrypts the file encrypted_file.txt.gpg using the recipient's private key.

To sign a file with GPG, the following command can be used:

```bash
gpg --sign plaintext_file.txt
```
This command signs the file plaintext_file.txt with the user's private key.

To verify a signed file with GPG, the following command can be used:

```bash
gpg --verify plaintext_file.txt.gpg
```
This command verifies the signature of the file plaintext_file.txt.gpg using the signer's public key.

### 2.3 Are there any security problems in using GPG like this?
Using GPG like this can be secure if the keys are properly generated, stored, and exchanged between trusted parties. However, there are several security problems that can arise, such as:

- Weak key generation: If the keypair is generated with weak parameters, it can be vulnerable to attacks.
- Key compromise: If a private key is compromised, an attacker can decrypt and access the encrypted data.
- Key exchange: If the public key is exchanged over an insecure channel, it can be intercepted and replaced with a malicious key.
- Malware: If malware is present on either lab1 or lab2, it can intercept the plaintext or the encrypted file before or after encryption or decryption.

### 2.4 How does GPG relate to PGP?
GPG is a free and open-source implementation of the OpenPGP standard, which is a protocol for secure communication based on PGP (Pretty Good Privacy). PGP was created by Phil Zimmermann in 1991 as a proprietary encryption software, but it was later released as an open standard. GPG is compatible with PGP and can interoperate with other OpenPGP-compliant software.

### 2.5 What is haveged and why did we install it earlier? What possible problems can usage of haveged have?
haveged is a software package that provides an easy-to-use, unpredictable random number generator based on the HAVEGE algorithm. It is used to increase the available entropy for cryptographic purposes, such as generating encryption keys.

During cryptographic operations, such as key generation, a source of randomness is required to ensure the generated key is as secure as possible. However, some systems may not have enough entropy available to generate truly random numbers, which can lead to predictable keys that are more susceptible to attacks. haveged is designed to provide a source of entropy when the system's default entropy sources are insufficient.

The possible problems with using haveged include its potential impact on system performance and security. While haveged can improve the randomness of generated keys, it can also consume significant system resources and may introduce new security risks if not configured properly. Additionally, haveged may not be necessary on all systems, and its use should be carefully evaluated on a case-by-case basis.

## 3. Crypto filesystem with loopback and device mapper
Create a file with random bytes to make it harder for the attacker to recognize which parts of device are used to store data, and which are left empty. This can be done with the command:

dd if=/dev/urandom of=loop.img bs=1k count=32k

Create a loopback device for the file using losetup(8). Then using cryptsetup(8), format the loopback device and map it to a pseudo-device. Please use LUKS with aes-cbc-essiv:sha256 cipher (should be default).

Create an ext2 filesystem on the pseudo-device, created in the previous step. The filesystem can be created with mkfs.ext2(8).

After this, you have successfully created an encrypted filesystem into a file. The filesystem is ready, and requires a passphrase to be entered when you luksOpen it.

Now mount your filesystem. Create some files and directories on the encrypted filesystem. Check also what happens if you try to mount the system with a wrong key.

### 3.1 Provide the commands you used.
Here are the commands I used to create and mount an encrypted filesystem in a file:

```bash
# create a 32 MB file with random bytes
dd if=/dev/urandom of=loop.img bs=1k count=32k

FREEDEVICE=$(losetup -f)
# create a loopback device for the file
sudo losetup $FREEDEVICE loop.img

# format the loopback device with LUKS encryption
sudo cryptsetup luksFormat --batch-mode $FREEDEVICE

# open the encrypted device and map it to a pseudo-device
echo "" | sudo cryptsetup luksOpen $FREEDEVICE loopfs

# create an ext2 filesystem on the pseudo-device
sudo mkfs.ext2 /dev/mapper/loopfs

# mount the encrypted filesystem
sudo mkdir /mnt/loopfs
sudo mount /dev/mapper/loopfs /mnt/loopfs
```

### 3.2 Explain the concepts of the pseudo-device and loopback device.
A loopback device is a special type of device that allows a file to be treated as if it were a block device. This means that a filesystem can be created within a file and mounted as if it were a separate disk partition.

A pseudo-device is a device that exists only in software, not in hardware. It is created by the device mapper (dm), which is a framework for creating virtual block devices out of other block devices. The device mapper takes a block device (such as a loopback device) and maps it to a new block device with additional features, such as encryption or RAID.

In the context of creating an encrypted filesystem in a file, the loopback device is used to create a block device from the file, and the device mapper is used to encrypt the block device and map it to a new, encrypted pseudo-device.

### 3.3 What is LUKS? (Knowing the meaning of abbreviation won't get you a point.)
LUKS (Linux Unified Key Setup) is a disk encryption specification that provides a standard format for storing encrypted data and metadata on disk. LUKS is typically used to encrypt the entire disk or a partition on a Linux system, but it can also be used to encrypt a loopback device or other block device.

LUKS supports various encryption algorithms and key sizes, as well as the ability to use multiple keys for a single encrypted volume. It also includes features such as key slot management and passphrase quality checking.

### 3.4 What is this kind of encryption method (creating a filesystem into a large random file, and storing a password protected decryption key with it) good for? What strengths and weaknesses does it have?
This kind of encryption method is good for creating an encrypted filesystem that can be easily moved or copied as a single file. It can be used for securely storing sensitive data on a system without requiring a separate physical disk partition or device.

One strength of this method is that it provides encryption of the entire filesystem, including filenames and directory structures. It also allows the filesystem to be easily backed up or moved without the need to separately encrypt individual files or directories.

However, this method has some weaknesses. One is that it requires the entire filesystem to be decrypted and mounted in order to access any of the data, which can be slow and inefficient for large filesystems. Additionally, if the encryption key is compromised, all data on the encrypted filesystem can be accessed by an attacker.

### 3.5 Why did we remove cryptoloop from the assignment and replaced it with dm_crypt? Extending the question a bit, what realities must a sysadmin remember with any to-be-deployed and already deployed security-related software?
Cryptoloop was an older encryption module in Linux that was replaced by dm-crypt, which is a more modern and secure encryption module that is now the preferred method for creating encrypted filesystems in Linux.

As for the second part of the question, a sysadmin must remember that any security-related software must be regularly updated to address any known security vulnerabilities. They must also ensure that any new software they deploy is properly configured and secured, and that any security-related settings are properly maintained. Additionally, they must regularly monitor their systems for any signs of intrusion or unauthorized access and take appropriate action if any issues are detected. Finally, they must also keep up to date with the latest developments in the field of cybersecurity and adapt their security measures accordingly to ensure the ongoing protection of their systems and data.

## 4. Gocryptfs
Using gocryptfs, mount an encrypted filesystem on a directory of your choice. This gives you the encryption layer. After this, create a few directories, and some files in them. Unmount gocryptfs using Fuse's fusermount.

Check what was written on the file system.

### 4.1 Provide the commands you used.
Assuming that gocryptfs is already installed on the system, the following commands can be used to create and mount an encrypted filesystem using gocryptfs:

Create a directory to mount the encrypted filesystem:
```bash
mkdir ~/encrypted
mkdir ~/gocryptfs
```

Initialize the encrypted filesystem using gocryptfs:
```bash
gocryptfs -init ~/gocryptfs
```

Mount the encrypted filesystem using gocryptfs:
```bash
gocryptfs ~/gocryptfs ~/encrypted
```

Create some directories and files in the mounted encrypted filesystem:
```bash
cd ~/encrypted
mkdir dir1
mkdir dir2
echo "File 1" > dir1/file1.txt
echo "File 2" > dir2/file2.txt
```

Unmount the encrypted filesystem:
```bash
fusermount -u ~/encrypted
```

### 4.2 Explain how this approach differs from the loopback one. What are the main differences between gocryptfs and encFS? Is encFS secure?
The main difference between gocryptfs and the loopback encryption approach is that gocryptfs is a userspace encrypted file system, whereas the loopback encryption approach involves using a file as a block device and then creating a file system on that device. In other words, gocryptfs provides encryption at the file system level, while the loopback approach provides encryption at the block device level.

Gocryptfs is designed to be more secure than encFS, which is another popular userspace encrypted file system. Gocryptfs uses a stronger encryption algorithm (AES-256) and provides better protection against tampering attacks, such as chosen ciphertext attacks. Additionally, gocryptfs does not rely on external libraries, which reduces the attack surface.

On the other hand, encFS has been criticized for its security vulnerabilities, such as the "IV reuse" vulnerability and the "reverse engineering" vulnerability. As a result, encFS is generally considered to be less secure than gocryptfs.

In summary, gocryptfs is a more secure and reliable encrypted file system compared to encFS, and is recommended for use in sensitive applications where security is a top priority.

## 5. TrueCrypt and alternatives
On this course we used to have a TrueCrypt assignment where students were required to create a hidden volume inside another volume. However, since 2014 there has been a lot of discussion about the security of TrueCrypt. Read arguments against and for TrueCrypt and based on your knowledge of the subject make a choice to use either TrueCrypt or one of the alternative forks that can create hidden volumes. Using the software of your choice create a hidden volume within an encrypted volume.

If you decide to use veracrypt, the command line syntax for veracrypt is

veracrypt [OPTIONS] VOLUME_PATH [MOUNT_DIRECTORY]

and the options can be found by running

veracrypt -h

### 5.1 Which encryption software did you choose and why?
I chose to use VeraCrypt because it is a widely used open-source software forked from TrueCrypt and is actively maintained with regular updates and security patches. Additionally, it has support for creating hidden volumes and plausible deniability.

### 5.2 Provide the commands that you used to create the volumes. Demonstrate that you can mount the outer and the hidden volume.
https://documentation.help/VeraCrypt/Personal%20Iterations%20Multiplier%20(PIM).html

Create the keyfiles:
```bash
head -c 4000 </dev/urandom > outer_keyfile
head -c 4000 </dev/urandom > hidden_keyfile
```

To create the outer volume, I used the following command:

```bash
head -c 4000 </dev/urandom | veracrypt -c outer_volume --size=100M --encryption=AES --hash=SHA-512 --filesystem=Ext4 --volume-type=normal -p 123456 --pim=20 -k=outer_keyfile
```

This creates an encrypted volume of size 100MB at outer_volume. I then created a password for the outer volume and selected the encryption algorithm and hash. After the outer volume was created, I created a hidden volume inside the outer volume using the following command:

```bash
head -c 4000 </dev/urandom | veracrypt -c outer_volume --size=50M --encryption=AES --hash=SHA-512 --filesystem=Ext4 --volume-type=hidden -p 123456 --pim=20 -k=hidden_keyfile
```

This creates a hidden volume of size 50MB inside the outer volume at outer_volume.

To mount the outer volume, I used the following command:

```bash
mkdir mount_veracrypt_outer
mkdir mount_veracrypt_hidden
veracrypt outer_volume mount_veracrypt_outer -p 123456 --pim=20 -k=outer_keyfile --protect-hidden yes --protection-password=123456 --protection-pim=20 --protection-keyfiles=hidden_keyfile
```

unmount the outer volume:
```bash
veracrypt --dismount outer_volume
```

### 5.3 What is plausible deniability?
Plausible deniability is a feature that allows a user to create an encrypted volume that appears to contain sensitive data, but can also contain a hidden volume with a separate password and data. This allows the user to reveal the password to the outer volume if pressured, while keeping the existence of the hidden volume secret. This feature is important in situations where the user wants to protect their sensitive data, but also wants to avoid revealing the existence of the hidden volume.
