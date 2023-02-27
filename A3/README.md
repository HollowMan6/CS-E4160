# A3: IPv6
## Motivation
Communication over the internet is done using IP-addresses. IPv4 addresses consist of 32 bits divided into 8 bit segments, and in a common form represented using decimal numbers, e.g. 172.217.21.142. However, with 32 bits it is theoretically possible to have roughly 4,3 billion distinct addresses (232). This doesn’t provide enough addresses to have even a single distinct address for every human in existence. Furthermore, with people having multiple devices connected to the Internet, from mobile phones to air conditioners, many regional internet registries have depleted their pool of IPv4 addresses.

This problem was anticipated however, and IPv6 protocol was developed. With 128 bit long addresses, a vast amount of 3.4*1038 (2128) addresses can be used and divided between the world. Currently, both protocols are used simultaneously, with IPv4 addresses being used for the foreseeable future. While there has been transition to IPv6 for over a decade, the protocols are not compatible with each other, and therefore IPv4-only hardware would need to be completely replaced to fully migrate into IPv6.

## Description of the exercise
In this exercise you will familiarize yourself with Internet Protocol version 6 (IPv6). The main task is to build a small network and assign addresses and routes automatically with router advertisements. Finally you will connect your IPv6 network to the global IPv6 internet using Teredo.

## Additional reading
RFC 4291 - IP version 6 Addressing Architecture
RFC 4193 - Unique Local IPv6 Unicast Addresses
RFC 2375 - IPv6 Multicast Address Assignment
RFC 2460 - Internet Protocol, Version 6 (IPv6) Specification
RFC 2461 - Neighbor Discovery for IP version 6 (IPv6)
RFC 4380 - Teredo: Tunneling IPv6 over UDP through Network Address Translations
RFC 6052 - IPv6 Addressing of IPv4/IPv6 Translators
RFC 6146 - Stateful NAT64 
Cisco NAT64 Guide – A tutorial on NAT64 by Cisco
IPv6 HOWTO - Good information about IPv6 and Linux
IPv6 - Ubuntu Wiki - Information about IPv6 and Ubuntu
ip, route and tcpdump manual pages
## 1. IPv6 addressing
The following picture shows the categories of different IPv6 address types, and you should familiarize yourself with the use for each of them

### 1.1 In Unique Local IPv6 Unicast Address space. how does a device know whether the IPv6 address it just created for itself is unique?

Using the Network Discovery for IPv6 protocol, it also known as Neighbor Discovery (ND). ND allows devices to determine the uniqueness of their addresses by sending Neighbor Solicitation messages to determine if the address is already in use by another device. If no response is received, the device assumes that the address is unique.

RFC 4193 - Unique Local IPv6 Unicast Addresses
3.2.1.  Locally Assigned Global IDs Locally assigned Global IDs MUST be generated with a pseudo-random algorithm consistent with [RANDOM]. 

Section 3.2.2 describes a suggested algorithm.
It is important that all sites generating Global IDs use a functionally similar algorithm to ensure there is a high probability of uniqueness.

The use of a pseudo-random algorithm to generate Global IDs in the locally assigned prefix gives an assurance that any network numbered using such a prefix is highly unlikely to have that address space clash with any other network that has another locally assigned prefix allocated to it.  This is a particularly useful property when considering a number of scenarios including networks that merge, overlapping VPN address space, or hosts mobile between such networks.

### 1.2 Explain 3 methods of dynamically allocating IPv6 global unicast addresses?

Three methods of dynamically allocating IPv6 global unicast addresses are:

- Stateless Address Autoconfiguration (SLAAC): devices can automatically generate a unique global unicast address by combining the network prefix information provided by a Router Advertisement (RA) message with the interface identifier of the device.
- Dynamic Host Configuration Protocol version 6 (DHCPv6): similar to DHCP for IPv4, DHCPv6 allows a centralized server to assign unique global unicast addresses to devices on a network.
- Stateful Address Autoconfiguration (DHCPv6-Stateful): a combination of SLAAC and DHCPv6, where DHCPv6 servers provide the network prefix information, while devices generate their own interface identifier.

## 2. Build two IPv6 networks with a router
We will set up lab1 to act as a router. This means that lab1 will route traffic from one network to another. In practice this is done using routing tables, but before that we must allow certain things that are not allowed by default. Use the following sysctl commands (note that the last one will avoid messing up enp0s3 interface. You should do the last one on all of your VMs to prevent problems with misconfiguration.):

sudo sysctl -w net.ipv6.conf.default.forwarding=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1
sudo sysctl -w net.ipv6.conf.enp0s3.accept_ra=0

After the following steps you should have network topology similar to the following image:

Assign static IPv6 addresses from the subnets fd01:2345:6789:abc1::/64 and fd01:2345:6789:abc2::/64 to your virtual machines. On lab2 and lab3 add IPv6 route to the other network using lab1 as a gateway. Make sure that you can ping lab1 from lab2 and lab3, then ensure that IPv6 routing works on lab1 by pinging lab3 from lab2.

You can do the configurations using ip(8). Editing /etc/network/interfaces is a bad idea as it can mess radvd in the next part. The addresses should be assigned to intnet interfaces, not the NAT Network.

### 2.1 What do the above sysctl commands do?
The above sysctl commands enable IPv6 forwarding on all interfaces (`net.ipv6.conf.all.forwarding=1`) and on the default configuration (`net.ipv6.conf.default.forwarding=1`), allowing the machine to act as a router. The third command `net.ipv6.conf.enp0s3.accept_ra=0` disables router advertisement acceptance on the interface enp0s3 to prevent misconfiguration.

### 2.2 The subnets used belong to Unique Local IPv6 Unicast Address space. Explain what this means and what is the format of such addresses.
Unique Local IPv6 Unicast Addresses (ULA) are IPv6 addresses meant for use within a private network and not intended for global routing on the Internet. These addresses are defined by the `fc00::/7` prefix and are assigned randomly. They allow for communication within a network while preventing accidental routing of these addresses to the Internet. The format of ULA addresses is `fc00::/7` followed by a 40-bit identifier.

https://en.wikipedia.org/wiki/Unique_local_address

Unique local address format

| bits | 7 | 1 | 40 | 16 | 64 |
| --- | --- | --- | --- | --- | --- |
| field | prefix | L | random | subnet id | interface identifier |

### 2.3 List all commands that you used to add static addresses to lab1, lab2 and lab3. Explain one of the add address commands.

The command `ip -6 addr` add adds an IPv6 address to the specified device. The address being added with a subnet prefix of /64.

### 2.4 Show the command that you used to add the route to lab3 on lab2, and explain it.

`sudo ip -6 route add fd01:2345:6789:abc2::/64 via fd01:2345:6789:abc1::1 dev enp0s8`

The command `ip -6 route add` adds a route for the IPv6 subnet `fd01:2345:6789:abc2::/64` to the specified device (in this case, enp0s8). The route uses `fd01:2345:6789:abc1::1` as the gateway (specified with the via option), meaning that packets destined for the address `fd01:2345:6789:abc2::3` will be sent to `fd01:2345:6789:abc1::1` for forwarding.

### 2.5 Show enp0s8 interface information from lab2, as well as the IPv6 routing table. Explain the IPv6 information from the interface and the routing table. What does a double colon (::) indicate?

```bash
vagrant@lab2:~$ sudo ip -6 addr show dev enp0s8
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    inet6 fd01:2345:6789:abc1::2/64 scope global 
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe27:b32a/64 scope link 
       valid_lft forever preferred_lft forever
vagrant@lab2:~$ ip -6 route
::1 dev lo proto kernel metric 256 pref medium
fd01:2345:6789:abc1::/64 dev enp0s8 proto kernel metric 256 pref medium
fd01:2345:6789:abc2::/64 via fd01:2345:6789:abc1::1 dev enp0s8 metric 1024 pref medium
fe80::/64 dev enp0s3 proto kernel metric 256 pref medium
fe80::/64 dev enp0s8 proto kernel metric 256 pref medium
```

- `3: enp0s8`: This is the interface index and name.
- `<BROADCAST,MULTICAST,UP,LOWER_UP>`: These are flags that indicate the state of the interface. "UP" means that the interface is active and running. "BROADCAST" and "MULTICAST" indicate that the interface supports broadcast and multicast, respectively. "LOWER_UP" means that the lower-level protocol is running and the interface is up.
- `mtu 1500`: This is the maximum transmission unit (MTU) of the interface, which is the maximum size of a single packet that can be transmitted over the network.
- `qdisc fq_codel`: This is the queueing discipline (qdisc) used by the interface. "fq_codel" is a specific type of qdisc that uses the Fair Queuing Codel algorithm for managing network traffic.
- `state UP`: This is the state of the interface, indicating whether it is up (active) or down (inactive).
- `group default`: This is the name of the group to which the interface belongs.
- `qlen 1000`: This is the maximum number of packets that can be queued for transmission on the interface.
- `inet6 fd01:2345:6789:abc1::2/64`: This is an IPv6 address assigned to the interface, in CIDR notation. The address is "fd01:2345:6789:abc1::2" and the subnet mask is "/64".
- `scope global`: This is the scope of the IPv6 address, indicating the portion of the network in which the address is valid. In this case, the scope is "global", meaning that the address can be used on the entire internet.
- `valid_lft forever`: This is the "valid lifetime" of the IPv6 address, indicating how long the address will remain assigned to the interface. In this case, the lifetime is "forever", meaning that the address will remain assigned indefinitely.
- `preferred_lft forever:` This is the "preferred lifetime" of the IPv6 address, indicating how long the address will be the preferred address for the interface. In this case, the lifetime is "forever", meaning that the address will be the preferred address indefinitely.

- `::1 dev lo proto kernel metric 256 pref medium`: This line describes a route in the IPv6 routing table. The destination network is "::1", which is the loopback address. The interface through which the network can be reached is "lo" (the loopback interface). The routing protocol used is "kernel", meaning that it is managed by the kernel. The metric is "256", which is a value used to determine the preferred path to the destination network. The preference is "medium", which is a value used to determine the order in which routes are selected when multiple routes to the same destination exist.
- `fd01:2345:6789:abc1::/64 dev enp0s8 proto kernel metric 256 pref medium`: This line describes a route in the IPv6 routing table. The destination network is "fd01:2345:6789:abc1::/64". The interface through which the network can be reached is "enp0s8". The routing protocol used is "kernel", meaning that it is managed by the kernel. The metric is "256", which is a value used to determine the preferred path to the destination network. The preference is "medium", which is a value used to determine the order in which routes are selected when multiple routes to the same destination exist.
- `fd01:2345:6789:abc2::/64 via fd01:2345:6789:abc1::1 dev enp0s8 metric 1024 pref medium`: This line describes a route in the IPv6 routing table. The destination network is "fd01:2345:6789:abc2::/64". The next hop (the intermediate device through which the network can be reached) is "fd01:2345:6789:abc1::1". The interface through which the next hop can be reached is "enp0s8". The routing protocol used is "kernel", meaning that it is managed by the kernel. The metric is "1024", which is a value used to determine the preferred path to the destination network. The preference is "medium", which is a value used to determine the order in which routes are selected when multiple routes to the same destination exist.
- `fe80::/64 dev enp0s3 proto kernel metric 256 pref medium`: This line describes a route in the IPv6 routing table. The destination network is "fe80::/64". The interface through which the network can be reached is "enp0s3". The routing protocol used is "kernel", meaning that it is managed by the kernel. The metric is "256", which is a value used to determine the preferred path to the destination network. The preference is "medium", which is a value used to determine the order in which routes are selected when multiple routes to the same destination exist.
- `fe80::/64 dev enp0s8 proto kernel metric 256 pref medium`: This line describes a route in the IPv6 routing table. The destination network is "fe80::/64". The interface through which the network can be reached is "enp0s8". The routing protocol used is "kernel", meaning that it is managed by the kernel. The metric is "256", which is a value used to determine the preferred path to the destination network. The preference is "medium", which is a value used to determine the order in which routes are selected when multiple routes to the same destination exist.

A double colon (::) in an IPv6 address indicates that one or more groups of 16-bits are omitted and replaced with a double colon. It represents consecutive groups of zeros and is used as a shorthand for writing IPv6 addresses.

### 2.6 Start tcpdump to capture ICMPv6 packets on each machine. From lab2, ping the lab1 and lab3 IPv6 addresses using ping6(8). You should get a return packet for each ping you have sent. If not, recheck your network configuration. Show the headers of a successful ping return packet. Show ping6 output as well as tcpdump output.

<!-- 
‵‵‵log
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|Version| Traffic Class |           Flow Label                  |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|         Payload Length        |  Next Header  |   Hop Limit   |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
+                                                               +
|                         Source Address                        |
+                                                               +
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
+                                                               +
|                      Destination Address                      |
+                                                               +
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```
-->

- Version: This field indicates the version of the IP protocol being used. For IPv6, this value is always set to 6.
- Traffic Class: This field is used to prioritize traffic and control congestion. It consists of two subfields: the 6-bit Differentiated Services Code Point (DSCP) and the 2-bit Explicit Congestion Notification (ECN) field.
- Flow Label: This field is used to identify packets that belong to the same flow or session. It is a 20-bit field that is set by the sender and should be kept unchanged by intermediate routers.
- Payload Length: This field indicates the length of the payload (i.e., the data being transmitted) in bytes.
- Next Header: This field indicates the protocol of the next header in the packet after the IPv6 header. For a successful ping return packet, this value would typically be set to ICMPv6 (Internet Control Message Protocol version 6).
- Hop Limit: This field limits the number of routers that a packet can traverse before being discarded. It is decremented by each router that forwards the packet, and the packet is discarded when the hop limit reaches zero.
- Source Address: This field indicates the IPv6 address of the sender.
- Destination Address: This field indicates the IPv6 address of the intended recipient (i.e., the address that was pinged).


```bash
vagrant@lab1:~$ sudo tcpdump -i enp0s8 -i enp0s9
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on enp0s9, link-type EN10MB (Ethernet), snapshot length 262144 bytes
21:18:56.706162 IP6 fd01:2345:6789:abc1::2 > fd01:2345:6789:abc2::2: ICMP6, echo request, id 9, seq 1, length 64
21:18:56.706594 IP6 fd01:2345:6789:abc2::2 > fd01:2345:6789:abc1::2: ICMP6, echo reply, id 9, seq 1, length 64
21:18:57.749048 IP6 fd01:2345:6789:abc1::2 > fd01:2345:6789:abc2::2: ICMP6, echo request, id 9, seq 2, length 64
21:18:57.749680 IP6 fd01:2345:6789:abc2::2 > fd01:2345:6789:abc1::2: ICMP6, echo reply, id 9, seq 2, length 64
21:19:01.902119 IP6 lab1 > fd01:2345:6789:abc2::2: ICMP6, neighbor solicitation, who has fd01:2345:6789:abc2::2, length 32
21:19:01.902807 IP6 fd01:2345:6789:abc2::2 > lab1: ICMP6, neighbor advertisement, tgt is fd01:2345:6789:abc2::2, length 24
21:19:01.926934 IP6 fe80::a00:27ff:fe9f:1789 > lab1: ICMP6, neighbor solicitation, who has lab1, length 32
21:19:01.926952 IP6 lab1 > fe80::a00:27ff:fe9f:1789: ICMP6, neighbor advertisement, tgt is lab1, length 24
21:19:07.031313 IP6 lab1 > fe80::a00:27ff:fe9f:1789: ICMP6, neighbor solicitation, who has fe80::a00:27ff:fe9f:1789, length 32
21:19:07.032009 IP6 fe80::a00:27ff:fe9f:1789 > lab1: ICMP6, neighbor advertisement, tgt is fe80::a00:27ff:fe9f:1789, length 24
21:19:07.038854 IP6 fe80::a00:27ff:fe9f:1789 > lab1: ICMP6, neighbor solicitation, who has lab1, length 32
21:19:07.038861 IP6 lab1 > fe80::a00:27ff:fe9f:1789: ICMP6, neighbor advertisement, tgt is lab1, length 24
vagrant@lab2:~$ sudo tcpdump -i enp0s8
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on enp0s8, link-type EN10MB (Ethernet), snapshot length 262144 bytes
21:18:52.547048 IP6 lab2 > fd01:2345:6789:abc2::1: ICMP6, echo request, id 8, seq 1, length 64
21:18:52.547507 IP6 fd01:2345:6789:abc2::1 > lab2: ICMP6, echo reply, id 8, seq 1, length 64
21:18:53.581710 IP6 lab2 > fd01:2345:6789:abc2::1: ICMP6, echo request, id 8, seq 2, length 64
21:18:53.582420 IP6 fd01:2345:6789:abc2::1 > lab2: ICMP6, echo reply, id 8, seq 2, length 64
21:18:56.696062 IP6 lab2 > fd01:2345:6789:abc2::2: ICMP6, echo request, id 9, seq 1, length 64
21:18:56.697255 IP6 fd01:2345:6789:abc2::2 > lab2: ICMP6, echo reply, id 9, seq 1, length 64
21:18:57.739165 IP6 lab2 > fd01:2345:6789:abc2::2: ICMP6, echo request, id 9, seq 2, length 64
21:18:57.740343 IP6 fd01:2345:6789:abc2::2 > lab2: ICMP6, echo reply, id 9, seq 2, length 64
21:18:57.792558 IP6 lab2 > fd01:2345:6789:abc1::1: ICMP6, neighbor solicitation, who has fd01:2345:6789:abc1::1, length 32
21:18:57.793299 IP6 fd01:2345:6789:abc1::1 > lab2: ICMP6, neighbor advertisement, tgt is fd01:2345:6789:abc1::1, length 24
21:18:57.814861 IP6 fe80::a00:27ff:feda:ce6e > lab2: ICMP6, neighbor solicitation, who has lab2, length 32
21:18:57.814882 IP6 lab2 > fe80::a00:27ff:feda:ce6e: ICMP6, neighbor advertisement, tgt is lab2, length 24
21:19:02.917241 IP6 lab2 > fe80::a00:27ff:feda:ce6e: ICMP6, neighbor solicitation, who has fe80::a00:27ff:feda:ce6e, length 32
21:19:02.917875 IP6 fe80::a00:27ff:feda:ce6e > lab2: ICMP6, neighbor advertisement, tgt is fe80::a00:27ff:feda:ce6e, length 24
21:19:02.917876 IP6 fe80::a00:27ff:feda:ce6e > lab2: ICMP6, neighbor solicitation, who has lab2, length 32
21:19:02.917911 IP6 lab2 > fe80::a00:27ff:feda:ce6e: ICMP6, neighbor advertisement, tgt is lab2, length 24
21:19:04.715977 IP6 lab2 > fd01:2345:6789:abc1::1: ICMP6, echo request, id 11, seq 1, length 64
21:19:04.716472 IP6 fd01:2345:6789:abc1::1 > lab2: ICMP6, echo reply, id 11, seq 1, length 64
21:19:05.731907 IP6 lab2 > fd01:2345:6789:abc1::1: ICMP6, echo request, id 11, seq 2, length 64
21:19:05.732761 IP6 fd01:2345:6789:abc1::1 > lab2: ICMP6, echo reply, id 11, seq 2, length 64
vagrant@lab3:~$ sudo tcpdump -i enp0s8
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on enp0s8, link-type EN10MB (Ethernet), snapshot length 262144 bytes
21:18:56.695596 IP6 fd01:2345:6789:abc1::2 > lab3: ICMP6, echo request, id 9, seq 1, length 64
21:18:56.695625 IP6 lab3 > fd01:2345:6789:abc1::2: ICMP6, echo reply, id 9, seq 1, length 64
21:18:57.738671 IP6 fd01:2345:6789:abc1::2 > lab3: ICMP6, echo request, id 9, seq 2, length 64
21:18:57.738698 IP6 lab3 > fd01:2345:6789:abc1::2: ICMP6, echo reply, id 9, seq 2, length 64
21:19:01.891598 IP6 fe80::a00:27ff:feac:eaca > lab3: ICMP6, neighbor solicitation, who has lab3, length 32
21:19:01.891640 IP6 lab3 > fe80::a00:27ff:feac:eaca: ICMP6, neighbor advertisement, tgt is lab3, length 24
21:19:01.915798 IP6 lab3 > fd01:2345:6789:abc2::1: ICMP6, neighbor solicitation, who has fd01:2345:6789:abc2::1, length 32
21:19:01.916198 IP6 fd01:2345:6789:abc2::1 > lab3: ICMP6, neighbor advertisement, tgt is fd01:2345:6789:abc2::1, length 24
21:19:07.020591 IP6 fe80::a00:27ff:feac:eaca > lab3: ICMP6, neighbor solicitation, who has lab3, length 32
21:19:07.020617 IP6 lab3 > fe80::a00:27ff:feac:eaca: ICMP6, neighbor advertisement, tgt is lab3, length 24
21:19:07.027510 IP6 lab3 > fe80::a00:27ff:feac:eaca: ICMP6, neighbor solicitation, who has fe80::a00:27ff:feac:eaca, length 32
21:19:07.028120 IP6 fe80::a00:27ff:feac:eaca > lab3: ICMP6, neighbor advertisement, tgt is fe80::a00:27ff:feac:eaca, length 24
vagrant@lab2:~$ ping6 fd01:2345:6789:abc2::1
PING fd01:2345:6789:abc2::1(fd01:2345:6789:abc2::1) 56 data bytes
64 bytes from fd01:2345:6789:abc2::1: icmp_seq=1 ttl=64 time=0.471 ms
64 bytes from fd01:2345:6789:abc2::1: icmp_seq=2 ttl=64 time=0.732 ms
^C
--- fd01:2345:6789:abc2::1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1035ms
rtt min/avg/max/mdev = 0.471/0.601/0.732/0.130 ms
vagrant@lab2:~$ ping6 fd01:2345:6789:abc2::2
PING fd01:2345:6789:abc2::2(fd01:2345:6789:abc2::2) 56 data bytes
64 bytes from fd01:2345:6789:abc2::2: icmp_seq=1 ttl=63 time=1.20 ms
64 bytes from fd01:2345:6789:abc2::2: icmp_seq=2 ttl=63 time=1.20 ms
^C
--- fd01:2345:6789:abc2::2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1043ms
rtt min/avg/max/mdev = 1.201/1.201/1.201/0.000 ms
vagrant@lab2:~$ ping6 fd01:2345:6789:abc1::2
PING fd01:2345:6789:abc1::2(fd01:2345:6789:abc1::2) 56 data bytes
64 bytes from fd01:2345:6789:abc1::2: icmp_seq=1 ttl=64 time=0.018 ms
64 bytes from fd01:2345:6789:abc1::2: icmp_seq=2 ttl=64 time=0.044 ms
^C
--- fd01:2345:6789:abc1::2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1032ms
rtt min/avg/max/mdev = 0.018/0.031/0.044/0.013 ms
vagrant@lab2:~$ ping6 fd01:2345:6789:abc1::1
PING fd01:2345:6789:abc1::1(fd01:2345:6789:abc1::1) 56 data bytes
64 bytes from fd01:2345:6789:abc1::1: icmp_seq=1 ttl=64 time=0.503 ms
64 bytes from fd01:2345:6789:abc1::1: icmp_seq=2 ttl=64 time=0.876 ms
^C
--- fd01:2345:6789:abc1::1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1016ms
rtt min/avg/max/mdev = 0.503/0.689/0.876/0.186 ms
```

## 3. IPv6 Router Advertisement Daemon
Now we will set up Router Advertisement Daemon on lab1 to automatically assign IPv6 addresses to VMs connected to intnet1 and intnet 2.

On lab2 and lab3: Remove all static addresses from the intnet interfaces and run the interfaces down.
lab1: Install IPv6 Router Advertisement Daemon (radvd). Modify the content of radvd.conf file to be used in your network (If radvd.conf file does not exist create one under /etc directory). Radvd should advertise prefix fd01:2345:6789:abc1::/64 on enp0s8 and fd01:2345:6789:abc2::/64 on enp0s9. Start the router advertisement daemon (radvd).
Check using tcpdump that router advertisement packets are sent to enp0s8 and enp0s9 of lab1 periodically. If you can’t see any packets sent, edit the conf file.
Start tcpdump on lab2 and capture ICMPv6 packets. Bring the interfaces on lab2 and lab3 up. Stop capturing packets after receiving first few ICMPv6 packets. Make sure the addresses that are assigned to the interfaces are received from the router advertisement.
Ping lab3 from lab2 using the IPv6 address allocated by radvd. You should get a return packet for each ping you have sent. If not, recheck your network configuration.

### 3.1 Explain your modifications to radvd.conf. Which options are mandatory?
The radvd.conf file needs to be modified to advertise the correct prefixes on the correct interfaces. A sample configuration for the scenario described could be:

```bash
interface enp0s8
{
  AdvSendAdvert on;
  AdvManagedFlag on;
  AdvOtherConfigFlag on;
  prefix fd01:2345:6789:abc1::/64
  {
    AdvOnLink on;
    AdvAutonomous on;
  };
};

interface enp0s9
{
  AdvSendAdvert on;
  AdvManagedFlag on;
  AdvOtherConfigFlag on;
  prefix fd01:2345:6789:abc2::/64
  {
    AdvOnLink on;
    AdvAutonomous on;
  };
};
```

https://linux.die.net/man/5/radvd.conf

- `AdvManagedFlag on`: This line indicates that the Managed Address Configuration flag in Router Advertisements (RAs) is set to "on". The Managed Address Configuration flag indicates whether stateful address autoconfiguration, such as DHCPv6, is available on the network. If the flag is set to "on", stateful address autoconfiguration is available; if it is set to "off", stateful address autoconfiguration is not available.
- `AdvOtherConfigFlag on`: This line indicates that the Other Configuration flag in Router Advertisements (RAs) is set to "on". The Other Configuration flag indicates whether stateless address autoconfiguration, such as SLAAC, is available on the network. If the flag is set to "on", stateless address autoconfiguration is available; if it is set to "off", stateless address autoconfiguration is not available.
- `AdvAutonomous on;` indicates that the prefix can be used for autoconfiguration of addresses.
- `AdvOnLink on;` indicates that the prefix is on-link, meaning it can be used as the destination address of a packet.

These options are mandatory:

- `interface` specifies the interface name to which the prefix will be advertised.
- `AdvSendAdvert on;` enables the advertisement of prefixes on the interface.
- `prefix` specifies the prefix to be advertised.

### 3.2 Analyze captured packets and explain what happens when you set up the interface on lab2.
```bash
vagrant@lab2:~$ sudo tcpdump -i enp0s8 icmp6
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on enp0s8, link-type EN10MB (Ethernet), snapshot length 262144 bytes
11:13:11.666324 IP6 _gateway > ip6-allnodes: ICMP6, router advertisement, length 56
11:13:11.788405 IP6 :: > ff02::1:ffe5:caed: ICMP6, neighbor solicitation, who has fd01:2345:6789:abc1:a00:27ff:fee5:caed, length 32
11:13:12.252843 IP6 :: > ff02::1:ff74:59ee: ICMP6, neighbor solicitation, who has lab2, length 32
11:13:12.678525 IP6 _gateway > ip6-allnodes: ICMP6, router advertisement, length 56
vagrant@lab3:~$ sudo tcpdump -i enp0s8 icmp6
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on enp0s8, link-type EN10MB (Ethernet), snapshot length 262144 bytes
11:13:11.685059 IP6 _gateway > ip6-allnodes: ICMP6, router advertisement, length 56
11:13:11.968663 IP6 :: > ff02::1:ff06:fb12: ICMP6, neighbor solicitation, who has fd01:2345:6789:abc2:a00:27ff:fe06:fb12, length 32
11:13:12.103962 IP6 :: > ff02::1:fffe:daa9: ICMP6, neighbor solicitation, who has lab3, length 32
```

When the interface on lab2 is set up, it listens for Router Advertisement packets. The router advertisement packets contain information about the prefixes available on the network, as well as other information such as the default gateway and the preferred and valid lifetimes of the prefixes. Upon receipt of the router advertisement packet, lab2 uses the information to autoconfigure its address.

### 3.3 How is the host-specific part of the address determined in this case?
The host-specific part of the address is determined by the host generating a random interface identifier (IID) and concatenating it with the prefix obtained from the router advertisement. The IID is usually generated from the MAC address of the interface.

### 3.4 Show and explain the output of a traceroute(1) from lab2 to lab3.
```bash
vagrant@lab2:~$ traceroute -6 fd01:2345:6789:abc2:a00:27ff:fe64:6423
traceroute to fd01:2345:6789:abc2:a00:27ff:fe64:6423 (fd01:2345:6789:abc2:a00:27ff:fe64:6423), 30 hops max, 80 byte packets
 1  fd01:2345:6789:abc1:a00:27ff:fe38:7e4d (fd01:2345:6789:abc1:a00:27ff:fe38:7e4d)  0.698 ms  0.672 ms  0.664 ms
 2  fd01:2345:6789:abc2:a00:27ff:fe64:6423 (fd01:2345:6789:abc2:a00:27ff:fe64:6423)  1.088 ms  1.082 ms  1.274 ms
```

La2 enp0s8 -> La1 enp0s8 -> La3 enp0s8.
The `traceroute` command shows the path taken by packets from the source to the destination. The output of a `traceroute` from lab2 to lab3 would show the hop-by-hop progression of the packets, with each hop representing a router on the network. The output would also show the round-trip time (RTT) for each hop. The IPv6 addresses of the routers can be seen in the output, allowing one to trace the path taken by the packets and identify any potential issues along the way.

## 4. Cofigure IPv6 over IPv4
Ideally, IPv6 should be run natively wherever possible, with IPv6 devices communicating with each other directly over IPv6 networks. However, the move from IPv4 to IPv6 will happen over time. The Internet Engineering Task Force (IETF) has developed several transition techniques to accommodate a variety of IPv4-to-IPv6 scenarios. One type of IPv4–to–IPv6 transition mechanism is translation including NAT64, Mapping of Address and Port (MAP), IPv6 Rapid Deployment (6rd), etc.

In this part of the assignment the goal is to demonstrate two ipv6 only nodes communicating with each other and the global IPv6 internet through an ipv4 link. You will need to spin up another VM, lab4 for this part of the assignment to setup the network shown below, which has two IPv6 only nodes and two nodes with both IPv6 and IPv4 capabilities but only an IPv4 link connecting them to each other

ipv4 over ipv6
1.    Reset the networking on lab1, lab2 and lab3 back to default.
2.    Create a new VM named lab4. Lab4 should have a NAT adapter for you to be able to ssh into and administer it, set up port forwarding accordingly
3.    On lab4 add a network adapter of type internal network and name it intnet3
4.    On lab2 and lab4, disable all static IPv4 interfaces on the intent adapters. Create an IPv6 link between lab2 and lab1 assigning static addresses from the fd01:2345:6789:abc1::/64 subnet, similarly create an IPv6 link between lab3 and lab4 assigning addresses from the subnet fd01:2345:6789:abc2::/64.
5.    Between lab1 and lab3 setup an IPv4 link with static addresses from 192.168.0.0/16
6. Make sure only lab3 has internet access. Configure your routing so that lab3 is used as the internet gateway

### 4.1 Show that you can ping6 lab2 from lab4

### 4.2 Show that you can ping 8.8.8.8 from lab1 and lab4

### 4.3 Show that you can open https://ipv6.google.com/ on lab4.

### 4.4 Explain your solution, why did you use this method over the other options
I use 6rd because it's easy to deploy.
- 6rd (IPv6 Rapid Deployment) is an IPv6 transition mechanism that enables service providers to quickly deploy IPv6 in their existing IPv4 infrastructure. It uses a combination of IPv4 and IPv6 addresses to allow IPv6-enabled devices to communicate over the IPv4 infrastructure. 6rd is simple to deploy and is well suited for service providers that have limited IPv4 address space or want to provide IPv6 connectivity to their customers quickly.
- NAT64 (Network Address Translation 64) is a technology that enables IPv6-only devices to communicate with IPv4-only devices. NAT64 uses a combination of IPv4 and IPv6 addresses to translate IPv6 packets into IPv4 packets, and vice versa. NAT64 is well suited for enterprise networks that have a mix of IPv4 and IPv6 devices and want to provide seamless IPv6 connectivity to their users.
- MAP (Mapping of Address and Port) is a technology that enables service providers to provide IPv6 connectivity to their customers over an IPv4 infrastructure. MAP uses a combination of IPv4 and IPv6 addresses to translate IPv6 packets into IPv4 packets and vice versa. MAP is similar to NAT64 in its functionality but is designed specifically for service providers who want to provide IPv6 connectivity to their customers over an IPv4 infrastructure.

### 4.5 Are there security issues with your solution? what and how to fix them
- Address Spoofing: 6rd uses a combination of IPv4 and IPv6 addresses, which increases the risk of address spoofing. Attackers can use forged IPv6 addresses to gain access to the network, making it difficult to identify the source of the attack.
- Increased Attack Surface: 6rd increases the attack surface by introducing a new layer of network infrastructure that must be secured. Service providers must take steps to secure the 6rd border relays and ensure that they are not susceptible to attacks.
- Interoperability Issues: 6rd uses a combination of IPv4 and IPv6 addresses, which can cause interoperability issues with some applications and devices. Service providers must ensure that their 6rd implementation is compatible with the devices and applications used in their network.

Fixes:
- Secure Configuration: Configuring access control lists (ACLs) to control access to the network.
- Network Segmentation: Segment the 6rd network into smaller, more manageable components to reduce the attack surface and make it easier to secure the network.
- Firewall and Intrusion Detection/Prevention Systems (IDS/IPS): Implement firewalls and IDS/IPS systems to control access to the network and prevent attacks.
- IPv6 Address Management: Properly manage the IPv6 address space to prevent address spoofing and ensure that only authorized devices have access to the network.
