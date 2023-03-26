# A5: Firewall
## Motivation
A firewall is a network security system used for monitoring and controlling network traffic. Setting up a firewall gives you control over which packets you want to let through and where to direct them. Furthermore, you can log the traffic going through the firewall to identify unusual behavior. A router hosting Network Address Translation (NAT) can act as a firewall, directing communications from a certain port to a certain IP address. Many consumer routers have firewall capabilities in them, allowing similar control to the ones set up in this assignment.

## Description of the exercise
This assignment introduces you to some firewalling basics. It includes packet filtering using Linux Nftables. You will first setup a router which will work as a firewall between the other two machines. The firewall will then be extended with a web proxy.

## Additional reading
route manual page
Nftables documentation
Squid documentation
Please note that you may render your virtual machine unreachable if you are not careful. If in doubt, please have a look at Nftables-apply man pages because it can revert such sloppy changes automatically.

## 1. Preparation
If you are doing both paths, you might want to consider making new virtual machines for this exercise, because the two assignments might cause some conflicts or problems.

You will need all three virtual machines for this exercise. Lab1 functions as a router/firewall between lab2 and lab3, which are in different subnetworks. The enp0s3 interface allows access to the virtual machines. Be careful not to modify it or block access to it. Make sure you are not sending packets through enp0s3 when connecting to other virtual machines, because that way you will bypass the firewall. The communication between VMs should be through the internal networks.

Please remember to take backups of the folders you have modified on the virtual machines.


## 2. Set up the network
You will configure lab1 to act as a router between lab2 and lab3. The resulting network should look like the following:

Firewall Topology

On lab1:

Assign a static IP from the subnet 192.168.0.0/24 to the interface enp0s8
Assign a static IP from the subnet 192.168.2.0/24 to the interface enp0s9
On lab2:

Assign a static IP from the subnet 192.168.0.0/24 to the interface enp0s8
On lab3:

Assign a static IP from the subnet 192.168.2.0/24 to the interface enp0s8
On lab1:

Add lab2 and lab3 static IP's to /etc/hosts, remove all other lab2 and lab3 mentions
On lab2:

Add lab1 static IP (that is in the same network as lab2) to /etc/hosts, remove all other lab1 mentions
Add lab3 static IP to /etc/hosts, remove all other mentions
On lab3:

Add lab1 static IP (that is in the same network as lab3) to /etc/hosts, remove all other lab1 mentions
Add lab2 static IP to /etc/hosts, remove all other mentions
On lab1:

Add routes to both subnets (192.168.0.0/24 and 192.168.2.0/24) via the interfaces connected to those
On lab2 & lab3:

Add the necessary route to allow the machines to reach each other through lab1.
Do not change the default gateway or you will lose your connection to the machines.

Enable forwarding and arp proxying on lab1 for the enp0s8 and enp0s9 interfaces. Use the following sysctl(8) commands:

sysctl -w net.ipv4.conf.enp0s8.forwarding=1
sysctl -w net.ipv4.conf.enp0s9.forwarding=1
sysctl -w net.ipv4.conf.enp0s8.proxy_arp=1
sysctl -w net.ipv4.conf.enp0s9.proxy_arp=1

Check that there is no firewall rules at this point (iptables -L), and test that routing works by using traceroute(8) from lab2 to lab3. Make sure that the route uses lab1 and the correct static IPs.

### 2.1 List all commands you used to create the router setup, and briefly explain what they do. Show the results of the traceroute as well.
These commands are used to modify kernel parameters related to packet forwarding and proxy ARP on two network interfaces named "enp0s8" and "enp0s9".

- "net.ipv4.conf.enp0s8.forwarding=1": This command enables IP forwarding on the "enp0s8" network interface. When IP forwarding is enabled, the Linux kernel will forward packets from one network interface to another if the destination IP address is not on the same subnet as the source IP address.
- "net.ipv4.conf.enp0s9.forwarding=1": This command enables IP forwarding on the "enp0s9" network interface.
- "net.ipv4.conf.enp0s8.proxy_arp=1": This command enables proxy ARP on the "enp0s8" network interface. Proxy ARP allows a system to respond to ARP requests on behalf of another system. This is useful when a network device needs to communicate with a remote device that is not on the same subnet.
- "net.ipv4.conf.enp0s9.proxy_arp=1": This command enables proxy ARP on the "enp0s9" network interface.

These commands modify the values of kernel parameters in the /proc/sys/net/ipv4/conf directory. The "sysctl -w" command is used to write new values to these parameters, and the parameter name is specified after the "net.ipv4.conf." prefix.

```bash
vagrant@lab2:~$ traceroute lab3
traceroute to lab3 (192.168.2.3), 64 hops max
  1   192.168.0.2  0.845ms  0.760ms  0.525ms 
  2   192.168.2.3  0.582ms  0.369ms  0.399ms
vagrant@lab3:~$ traceroute lab2
traceroute to lab2 (192.168.0.3), 64 hops max
  1   192.168.2.2  0.627ms  0.447ms  0.317ms 
  2   192.168.0.3  0.471ms  0.641ms  0.431ms
```
### 2.2 Explain Tables ,chains, hooks and rules in nftables?
nftables is a powerful and flexible packet filtering framework in the Linux kernel. It provides a more efficient and scalable way of filtering packets than its predecessor iptables. In nftables, there are four main building blocks: tables, chains, hooks, and rules.

1. Tables:
Tables are the top-level containers that group chains and define the type of packet filtering or manipulation to be performed. Each table has a unique name and is identified by a family, which can be one of the following: ip, ip6, inet, or arp. Tables can be created, deleted, and modified using the nft command-line tool or via a configuration file.

2. Chains:
Chains are the second level of the nftables structure and are used to define a set of rules for packet filtering or manipulation. Chains can be attached to different hooks, which define the point in the packet processing path where the chain should be executed. The most common hooks are pre-routing, input, forward, output, and post-routing.

3. Hooks:
Hooks define the point in the packet processing path where a chain should be executed. There are five main hooks in nftables:
- PREROUTING: This hook is executed before a packet is routed and can be used to modify the packet's source address, destination address, or transport protocol.
- INPUT: This hook is executed when a packet is destined for the local machine.
- FORWARD: This hook is executed when a packet is forwarded to another machine.
- OUTPUT: This hook is executed when a packet is generated by the local machine and is destined for another machine.
- POSTROUTING: This hook is executed after a packet has been routed and can be used to modify the packet's source address, destination address, or transport protocol.

4. Rules:
Rules are the third level of the nftables structure and define the specific actions to be taken for a packet that matches a particular set of criteria. Each rule consists of a set of expressions that match against a packet's metadata, such as its source and destination addresses, transport protocol, and port numbers. If a packet matches a rule, the associated action is taken, which can be one of the following: accept, drop, reject, or jump to another chain.

In summary, tables, chains, hooks, and rules are the building blocks of nftables and provide a powerful and flexible framework for packet filtering and manipulation in Linux.

## 3. Implement packet filtering on the router
First, scan lab3 from lab2 and vice versa with nmap(1) to see what services they are running. Try to gather as much information on the machine as feasible, including information about software versions and the operating system.

Set up an nftables(8) FORWARD policy to disallow traffic through the router by default. Add rules to allow ping(8) from lab2 on the enp0s8 interface and replies to lab2. Change rules only for the FORWARD hook! Once this is working, expand the ruleset to allow SSH connections to and from lab2. Also allow browsing the web and transferring files via FTP (both active and passive modes) from lab2. Set up a web server (e.g. httpd(8)) and an ftp server (e.g. proftpd(8)) on lab3 for testing. Use as restricting ruleset as possible while allowing full functionality. You will probably need the "ip_conntrack_ftp" kernel module for FTP filtering. Load it with modprobe(8).

Finally, rescan lab3 from lab2 and vice versa.


### 3.1 List the services that were found scanning the machines with and without the firewall active. Explain the differences in how the details of the system were detected.
Before:
```bash
vagrant@lab2:~$ sudo nmap -sV -p- lab3
Starting Nmap 7.80 ( https://nmap.org ) at 2023-03-25 22:45 UTC
Nmap scan report for lab3 (192.168.2.3)
Host is up (0.00030s latency).
Not shown: 65532 closed ports
PORT   STATE SERVICE VERSION
21/tcp open  ftp     ProFTPD
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.5 (Ubuntu Linux; protocol 2.0)
80/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 18.74 seconds
vagrant@lab3:~$ sudo nmap -sV -p- lab2
Starting Nmap 7.80 ( https://nmap.org ) at 2023-03-25 22:51 UTC
Nmap scan report for lab2 (192.168.0.3)
Host is up (0.0087s latency).
Not shown: 65534 closed ports
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.5 (Ubuntu Linux; protocol 2.0)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 7.34 seconds
```

After:
```bash
vagrant@lab2:~$ sudo nmap -sV -p- lab3
Starting Nmap 7.80 ( https://nmap.org ) at 2023-03-25 23:06 UTC
Nmap scan report for lab3 (192.168.2.3)
Host is up (0.0023s latency).
Not shown: 65532 closed ports
PORT   STATE SERVICE VERSION
21/tcp open  ftp     ProFTPD
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.5 (Ubuntu Linux; protocol 2.0)
80/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 18.25 seconds
vagrant@lab3:~$ sudo nmap -sV -p- lab2
Starting Nmap 7.80 ( https://nmap.org ) at 2023-03-25 23:07 UTC
Nmap scan report for lab2 (192.168.0.3)
Host is up (0.00034s latency).
Not shown: 65534 closed ports
PORT   STATE SERVICE    VERSION
22/tcp open  tcpwrapped

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 13.28 seconds
```

This is because the firewall may be blocking ports and services. Nmap detects system details by sending a series of TCP and UDP packets to the remote host and examining practically every bit in the responses. Nmap then runs various tests from TCP ISN sampling to IP ID sampling and compares it to its internal database of 2,600 operating systems

### 3.2 List the commands used to implement the ruleset with explanations.

```bash
sudo nft -a list table inet filter
sudo nft delete rule inet filter forward handle 16
```
### 3.3 Create a few test cases to verify your ruleset. Run the tests and provide minimal, but sufficient snippets of iptables' or tcpdump's logs to support your test results.

```bash
vagrant@lab2:~$ ftp lab3
Connected to lab3.
220 ProFTPD Server (Debian) [::ffff:192.168.2.3]
Name (lab3:vagrant): vagrant
331 Password required for vagrant
Password:
230 User vagrant logged in
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> ls
200 PORT command successful
150 Opening ASCII mode data connection for file list
226 Transfer complete
ftp> passive
Passive mode on.
ftp> ls
227 Entering Passive Mode (192,168,2,3,178,201).
150 Opening ASCII mode data connection for file list
226 Transfer complete
ftp> put 1.txt 1.txt
local: 1.txt remote: 1.txt
227 Entering Passive Mode (192,168,2,3,168,47).
150 Opening BINARY mode data connection for 1.txt
226 Transfer complete
ftp> passive
Passive mode off.
ftp> put 1.txt 1.txt
local: 1.txt remote: 1.txt
200 PORT command successful
150 Opening BINARY mode data connection for 1.txt
226 Transfer complete
ftp> ls
200 PORT command successful
150 Opening ASCII mode data connection for file list
-rw-r--r--   1 vagrant  vagrant         0 Mar 25 22:39 1.txt
226 Transfer complete
```

```bash
vagrant@lab3:~$ sudo tcpdump -i enp0s8
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on enp0s8, link-type EN10MB (Ethernet), capture size 262144 bytes
22:41:01.533431 IP lab2.45336 > lab3.ftp: Flags [P.], seq 1598340732:1598340758, ack 3330061165, win 502, options [nop,nop,TS val 1758536159 ecr 998374888], length 26: FTP: PORT 192,168,0,3,188,249
22:41:01.533690 IP lab3.ftp > lab2.45336: Flags [P.], seq 1:30, ack 26, win 510, options [nop,nop,TS val 998447520 ecr 1758536159], length 29: FTP: 200 PORT command successful
22:41:01.534768 IP lab2.45336 > lab3.ftp: Flags [P.], seq 26:32, ack 30, win 502, options [nop,nop,TS val 1758536161 ecr 998447520], length 6: FTP: LIST
22:41:01.534967 IP lab3.ftp-data > lab2.48377: Flags [S], seq 1869841352, win 64240, options [mss 1460,sackOK,TS val 998447521 ecr 0,nop,wscale 7], length 0
22:41:01.536012 IP lab2.48377 > lab3.ftp-data: Flags [S.], seq 3940072064, ack 1869841353, win 65160, options [mss 1460,sackOK,TS val 1758536162 ecr 998447521,nop,wscale 7], length 0
```

### 3.4 Explain the difference between netfilter DROP and REJECT targets. Test both of them, and explain your findings.
DROP and REJECT are both used to block incoming traffic, but they have different behaviors. The main difference between DROP and REJECT is how they respond to blocked traffic.

DROP simply discards incoming traffic without sending any response back to the source. When a packet is dropped, the sender doesn't know that the packet was blocked, and may continue to send additional packets. This can be useful in some cases where you want to silently drop traffic without alerting the sender.

REJECT, on the other hand, sends an error message back to the source to indicate that the traffic was blocked. This lets the sender know that their traffic is being blocked, and they can take appropriate action. This can be useful when you want to block traffic but also want to notify the sender of the reason for the block.

In both cases, the traffic will be blocked and won't reach the target machine. However, with the DROP target, the sender won't receive any response, while with the REJECT target, the sender will receive an error message.

In summary, the main difference between the DROP and REJECT targets in netfilter is how they respond to blocked traffic. DROP silently drops traffic without sending any response, while REJECT sends an error message back to the sender to indicate that the traffic was blocked.

## 4. Implement a web proxy
In addition to packet filtering, a proxy can be used to control traffic. In this step, you will set up a web proxy and force all http traffic to go through the proxy, where more detailed rules can be applied.

Connect from lab2 to the HTTP server running on lab3 and capture the headers of the response.
On lab1, configure a squid(8) web proxy to serve only requests from lab2 as a transparent proxy.
Configure the firewall on lab1 to send all TCP traffic from lab2 bound to port 80 to the squid proxy.
Connect to the HTTP server on lab3 again and capture the headers of the response.
Finally, configure the proxy not to serve pages from lab3 and attempt to retrieve the front page.
### 4.1 List the commands you used to send the traffic to the proxy with explanations.
Add a rule to the nat table in the PREROUTING chain that matches all TCP packets from lab2 destined to port 80 and redirects them to port 8000, where the squid proxy is listening:

```bash
sudo nft add rule ip filter prerouting iifname enp0s8 ip saddr lab2 tcp dport 80 redirect to :8000
```

### 4.2 Show and explain the changes you made to the squid.conf.
To configure squid as a transparent proxy, I made the following changes to the squid.conf file on lab1:

```conf
# This line tells squid to listen on port 8000 and act as a transparent proxy.
http_port 8000 transparent
; # This line defines an access control list (acl) named lab2 that matches the source IP address of lab2.
; acl localnet src 192.168.0.0/24
; # This line allows HTTP access for the acl lab2.
; http_access allow lab2
# This line allow HTTP access for all the requests.
http_reply_access allow all
http_access allow all

# configure Squid not to serve pages from lab3
# acl lab3 dstdomain lab3
# never_direct allow lab3
```

### 4.3 What is a transparent proxy?
A transparent proxy is a proxy that intercepts and modifies all traffic that is sent to a certain destination without requiring any configuration or awareness from the client. A transparent proxy can be used to enforce policies, filter content, cache data, or improve performance.

### 4.4 List the differences in HTTP headers after setting up the proxy. What has changed?
```bash
curl -I lab3
```

before setting up the proxy:
```bash
vagrant@lab2:~$ curl -I lab3
HTTP/1.1 200 OK
Date: Sat, 25 Mar 2023 22:20:29 GMT
Server: Apache/2.4.41 (Ubuntu)
Last-Modified: Sat, 25 Mar 2023 22:11:34 GMT
ETag: "2aa6-5f7c0caf76d35"
Accept-Ranges: bytes
Content-Length: 10918
Vary: Accept-Encoding
Content-Type: text/html
```

After setting up the proxy:
```bash
vagrant@lab2:~$ curl -I lab3
HTTP/1.1 200 OK
Date: Sat, 25 Mar 2023 22:22:07 GMT
Server: Apache/2.4.41 (Ubuntu)
Last-Modified: Sat, 25 Mar 2023 22:11:34 GMT
ETag: "2aa6-5f7c0caf76d35"
Accept-Ranges: bytes
Content-Length: 10918
Vary: Accept-Encoding
Content-Type: text/html
X-Cache: MISS from lab1
X-Cache-Lookup: MISS from lab1:3128
Via: 1.1 lab1 (squid/4.10)
Connection: keep-alive

vagrant@lab2:~$ curl -I lab3
HTTP/1.1 200 OK
Date: Sat, 25 Mar 2023 22:22:07 GMT
Server: Apache/2.4.41 (Ubuntu)
Last-Modified: Sat, 25 Mar 2023 22:11:34 GMT
ETag: "2aa6-5f7c0caf76d35"
Accept-Ranges: bytes
Content-Length: 10918
Vary: Accept-Encoding
Content-Type: text/html
Age: 103
X-Cache: HIT from lab1
X-Cache-Lookup: HIT from lab1:3128
Via: 1.1 lab1 (squid/4.10)
Connection: keep-alive
```

- The response header has an additional line: `Via: 1.1 lab1 (squid/4.10)`, which indicates that the response was processed by squid on lab1.
- The response header has an additional line: `X-Cache: MISS from lab1`, which indicates that the response was not cached by squid on lab1.
- The response header has an additional line: `X-Cache-Lookup: MISS from lab1:3128`, which indicates that squid on lab1 did not find the requested resource in its cache.
- The response header has an additional line: `Age: 103`, which indicates that the response was cached by squid on lab1 for 103 seconds.

## 5. Implement a DMZ
A DMZ (demilitarized zone) network is a physical or logical subnet that separates an internal local area network (LAN) from other untrusted networks (usually the Internet). The purpose of a DMZ is to add an extra layer of security to an organization's LAN. In this way, each external network node can access only what is provided through the DMZ, and the rest of the organization's network remains behind the firewall. In this task we design a DMZ network with a firewall. Assume your organizations outward facing webserver running on lab2 is in a DMZ and your lab3 is in Internal Network, while lab1 is the firewall host executing the firewall rules as shown below.

DMZ topology
 You can use a destination network address translation (DNAT) rule to forward incoming packets on a lab1 port to a port on lab2.
1. On lab1 set up the nftables firewall with 3 network cards. You should forward port 8080 from your host to lab1
eth0 is attached to NAT
eth1 is attached to DMZ (lab2)
eth2 is attached to Internal network (lab3)
2. Add a rule to the prerouting chain that redirects incoming packets on port 8080 to the port 80 on lab2. It means the traffic coming from eth0 will be redirected to eth1. 
3. Add a rule to the postrouting chain to masquerade outgoing traffic.
4. The traffic coming from eth2 to eth 1 would be passed without any problem.
5. eth1 just allows to pass traffic in response to requests that have been made to lab2 in DMZ.
6. On lab2 install Apache web server.

### 5.1 Demonstrate you can browse the Apache webserver from your host and lab3. Demonstrate you cannot ping from lab2 to lab3
```bash
vagrant ssh-config > vagrant-ssh
sudo ssh -F vagrant-ssh -NL 8080:localhost:8080 lab1
```

```bash
vagrant@lab3:~$ curl lab1:8080
vagrant@lab3:~$ curl lab2
```
### 5.2 List the commands you used to set up the DMZ in nftables. You must show the prerouting, postrouting , forward, input and output chains.

```bash
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
        tcp sport 80 accept
        tcp dport 22 accept
        tcp dport 8080 accept
        drop
    }

    chain output {
        type filter hook output priority 0; policy accept;
        oif lo accept
        tcp dport 80 accept
        tcp sport 22 accept
        tcp sport 8080 accept
        drop
    }

    chain forward {
        type filter hook forward priority 0; policy accept;
        iif enp0s9 oif enp0s8 ct state new,related,established accept
        iif enp0s8 oif enp0s9 ct state related,established accept
        drop
    }
}
```
