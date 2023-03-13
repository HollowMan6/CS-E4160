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


### 2.2 Explain Tables ,chains, hooks and rules in nftables?


## 3. Implement packet filtering on the router
First, scan lab3 from lab2 and vice versa with nmap(1) to see what services they are running. Try to gather as much information on the machine as feasible, including information about software versions and the operating system.

Set up an nftables(8) FORWARD policy to disallow traffic through the router by default. Add rules to allow ping(8) from lab2 on the enp0s8 interface and replies to lab2. Change rules only for the FORWARD hook! Once this is working, expand the ruleset to allow SSH connections to and from lab2. Also allow browsing the web and transferring files via FTP (both active and passive modes) from lab2. Set up a web server (e.g. httpd(8)) and an ftp server (e.g. proftpd(8)) on lab3 for testing. Use as restricting ruleset as possible while allowing full functionality. You will probably need the "ip_conntrack_ftp" kernel module for FTP filtering. Load it with modprobe(8).

Finally, rescan lab3 from lab2 and vice versa.


### 3.1 List the services that were found scanning the machines with and without the firewall active. Explain the differences in how the details of the system were detected.


### 3.2 List the commands used to implement the ruleset with explanations.


### 3.3 Create a few test cases to verify your ruleset. Run the tests and provide minimal, but sufficient snippets of iptables' or tcpdump's logs to support your test results.


### 3.4 Explain the difference between netfilter DROP and REJECT targets. Test both of them, and explain your findings.


## 4. Implement a web proxy
In addition to packet filtering, a proxy can be used to control traffic. In this step, you will set up a web proxy and force all http traffic to go through the proxy, where more detailed rules can be applied.

Connect from lab2 to the HTTP server running on lab3 and capture the headers of the response.
On lab1, configure a squid(8) web proxy to serve only requests from lab2 as a transparent proxy.
Configure the firewall on lab1 to send all TCP traffic from lab2 bound to port 80 to the squid proxy.
Connect to the HTTP server on lab3 again and capture the headers of the response.
Finally, configure the proxy not to serve pages from lab3 and attempt to retrieve the front page.
### 4.1 List the commands you used to send the traffic to the proxy with explanations.


### 4.2 Show and explain the changes you made to the squid.conf.


### 4.3 What is a transparent proxy?


### 4.4 List the differences in HTTP headers after setting up the proxy. What has changed?


## 5. Implement a DMZ
A DMZ (demilitarized zone) network is a physical or logical subnet that separates an internal local area network (LAN) from other untrusted networks (usually the Internet). The purpose of a DMZ is to add an extra layer of security to an organization's LAN. In this way, each external network node can access only what is provided through the DMZ, and the rest of the organization's network remains behind the firewall. In this task we design a DMZ network with a firewall. Assume your organizations outward facing webserver running on lab2 is in a DMZ and your lab3 is in Internal Network, while lab1 is the firewall host executing the firewall rules as shown below.

DMZ topology
 You can use a destination network address translation (DNAT) rule to forward incoming packets on a lab1 port to a port on lab2.
1. On lab1 set up the nftables firewall with 3 network cards. You should forward port 8080 from your host to lab1
eth0 is attached to NAT
eth1 is attached to DMZ (lab2)
eth3 is attached to Internal network (lab3)
2. Add a rule to the prerouting chain that redirects incoming packets on port 8080 to the port 80 on lab2. It means the traffic coming from eth0 will be redirected to eth1. 
3. Add a rule to the postrouting chain to masquerade outgoing traffic.
4. The traffic coming from eth2 to eth 1 would be passed without any problem.
5. eth1 just allows to pass traffic in response to requests that have been made to lab2 in DMZ.
6. On lab2 install Apache web server.

### 5.1 Demonstrate you can browse the Apache webserver from your host and lab3. Demonstrate you cannot ping from lab2 to lab3


### 5.2 List the commands you used to set up the DMZ in nftables. You must show the prerouting, postrouting , forward, input and output chains.

