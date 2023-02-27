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

### 2.2 Provide the commands you used for creating and verifying the keys and explain what they do.

### 2.3 Are there any security problems in using GPG like this?

### 2.4 How does GPG relate to PGP?

### 2.5 What is haveged and why did we install it earlier? What possible problems can usage of haveged have?

## 3. Crypto filesystem with loopback and device mapper
Create a file with random bytes to make it harder for the attacker to recognize which parts of device are used to store data, and which are left empty. This can be done with the command:

dd if=/dev/urandom of=loop.img bs=1k count=32k

Create a loopback device for the file using losetup(8). Then using cryptsetup(8), format the loopback device and map it to a pseudo-device. Please use LUKS with aes-cbc-essiv:sha256 cipher (should be default).

Create an ext2 filesystem on the pseudo-device, created in the previous step. The filesystem can be created with mkfs.ext2(8).

After this, you have successfully created an encrypted filesystem into a file. The filesystem is ready, and requires a passphrase to be entered when you luksOpen it.

Now mount your filesystem. Create some files and directories on the encrypted filesystem. Check also what happens if you try to mount the system with a wrong key.

### 3.1 Provide the commands you used.

### 3.2 Explain the concepts of the pseudo-device and loopback device.

### 3.3 What is LUKS? (Knowing the meaning of abbreviation won't get you a point.)

### 3.4 What is this kind of encryption method (creating a filesystem into a large random file, and storing a password protected decryption key with it) good for? What strengths and weaknesses does it have?

### 3.5 Why did we remove cryptoloop from the assignment and replaced it with dm_crypt? Extending the question a bit, what realities must a sysadmin remember with any to-be-deployed and already deployed security-related software?

## 4. Gocryptfs
Using gocryptfs, mount an encrypted filesystem on a directory of your choice. This gives you the encryption layer. After this, create a few directories, and some files in them. Unmount gocryptfs using Fuse's fusermount.

Check what was written on the file system.

### 4.1 Provide the commands you used.

### 4.2 Explain how this approach differs from the loopback one. What are the main differences between gocryptfs and encFS? Is encFS secure?

## 5. TrueCrypt and alternatives
On this course we used to have a TrueCrypt assignment where students were required to create a hidden volume inside another volume. However, since 2014 there has been a lot of discussion about the security of TrueCrypt. Read arguments against and for TrueCrypt and based on your knowledge of the subject make a choice to use either TrueCrypt or one of the alternative forks that can create hidden volumes. Using the software of your choice create a hidden volume within an encrypted volume.

If you decide to use veracrypt, the command line syntax for veracrypt is

veracrypt [OPTIONS] VOLUME_PATH [MOUNT_DIRECTORY]

and the options can be found by running

veracrypt -h

### 5.1 Which encryption software did you choose and why?

### 5.2 Provide the commands that you used to create the volumes. Demonstrate that you can mount the outer and the hidden volume.

### 5.3 What is plausible deniability?
