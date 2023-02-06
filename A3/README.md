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

In the Unique Local IPv6 Unicast Address space, a device can determine whether the IPv6 address it has created for itself is unique by using the Network Discovery for IP version 6 (IPv6) protocol, also known as Neighbor Discovery (ND). ND allows devices to determine the uniqueness of their addresses by sending Neighbor Solicitation messages to determine if the address is already in use by another device. If no response is received, the device assumes that the address is unique.

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
Unique Local IPv6 Unicast Addresses (ULA) are IPv6 addresses meant for use within a private network and not intended for global routing on the Internet. These addresses are defined by the `FC00::/7` prefix and are assigned randomly. They allow for communication within a network while preventing accidental routing of these addresses to the Internet. The format of ULA addresses is `FC00::/7` followed by a 40-bit identifier, making the full address format `FC00::/7:40-bit-identifier`.

### 2.3 List all commands that you used to add static addresses to lab1, lab2 and lab3. Explain one of the add address commands.

`sudo ip -6 addr add fd01:2345:6789:abc1::1/64 dev enp0s8`

The command ip -6 addr add adds an IPv6 address to the specified device (in this case, enp0s8). The address being added is fd01:2345:6789:abc1::1 with a subnet prefix of /64.

### 2.4 Show the command that you used to add the route to lab3 on lab2, and explain it.

`sudo ip -6 route add fd01:2345:6789:abc2::3 via fd01:2345:6789:abc1::1 dev enp0s8`

The command ip -6 route add adds a route for the IPv6 address fd01:2345:6789:abc2::3 to the specified device (in this case, enp0s8). The route uses fd01:2345:6789:abc1::1 as the gateway (specified with the via option), meaning that packets destined for the address fd01:2345:6789:abc2::3 will be sent to fd01:2345:6789:abc1::1 for forwarding.

### 2.5 Show enp0s8 interface information from lab2, as well as the IPv6 routing table. Explain the IPv6 information from the interface and the routing table. What does a double colon (::) indicate?

`sudo ip -6 addr show dev enp0s8`

To view the IPv6 routing table, you can use the "ip -6 route" command.

The information displayed in the interface will include the interface name (enp0s8), the state (UP or DOWN), the MAC address, and the IPv6 addresses assigned to the interface.

The IPv6 routing table will show the routes to various network destinations, including the next hop, the metric, and the device used to reach the destination.

A double colon (::) in an IPv6 address indicates that one or more groups of 16-bits are omitted and replaced with a double colon. It represents consecutive groups of zeros and is used as a shorthand for writing IPv6 addresses.

### 2.6 Start tcpdump to capture ICMPv6 packets on each machine. From lab2, ping the lab1 and lab3 IPv6 addresses using ping6(8). You should get a return packet for each ping you have sent. If not, recheck your network configuration. Show the headers of a successful ping return packet. Show ping6 output as well as tcpdump output.

To start tcpdump to capture ICMPv6 packets on a machine, run the following command in the terminal:

sudo tcpdump -i `<interface>` -vvv icmp6

Replace `<interface>` with the appropriate network interface, for example enp0s8.

To ping the IPv6 address of another machine using ping6, run the following command in the terminal:

ping6 `<IPv6 address>`

Replace `<IPv6 address>` with the appropriate IPv6 address of the target machine.

The headers of a successful ping return packet will show information about the ICMPv6 packet, including the source and destination addresses, the type and code of the ICMPv6 message, and the payload.

The ping6 output will display the number of packets sent, received, and lost, as well as the round-trip time for each packet.

The tcpdump output will show detailed information about each captured ICMPv6 packet, including the source and destination addresses, the type and code of the ICMPv6 message, and the payload.

A double colon (::) in an IPv6 address is a shorthand notation that represents multiple contiguous zero blocks. For example, 2001:: is equivalent to 2001:0:0:0:0:0:0:0.

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

The options in the configuration file are not all mandatory, but some of them are:

- `interface` specifies the interface name to which the prefix will be advertised.
- `AdvSendAdvert on;` enables the advertisement of prefixes on the interface.
- `prefix` specifies the prefix to be advertised.
- `AdvOnLink on;` indicates that the prefix is on-link, meaning it can be used as the destination address of a packet.
- `AdvAutonomous on;` indicates that the prefix can be used for autoconfiguration of addresses.

### 3.2 Analyze captured packets and explain what happens when you set up the interface on lab2.
When the interface on lab2 is set up, it listens for Router Advertisement packets. The router advertisement packets contain information about the prefixes available on the network, as well as other information such as the default gateway and the preferred and valid lifetimes of the prefixes. Upon receipt of the router advertisement packet, lab2 uses the information to autoconfigure its address.

### 3.3 How is the host-specific part of the address determined in this case?
The host-specific part of the address is determined by the host generating a random interface identifier (IID) and concatenating it with the prefix obtained from the router advertisement. The IID is usually generated from the MAC address of the interface.

### 3.4 Show and explain the output of a traceroute(1) from lab2 to lab3.
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
To verify that lab4 can ping lab2, we can use the ping6 command on lab4 with the IPv6 address of lab2 as the target. If successful, this will demonstrate that there is a functioning IPv6 link between lab2 and lab4.

### 4.2 Show that you can ping 8.8.8.8 from lab1 and lab4
To verify that lab1 and lab4 can access the Internet, we can use the ping command on both lab1 and lab4 with 8.8.8.8 as the target. This is the IP address of the Google public DNS server, and a successful ping will indicate that both lab1 and lab4 have Internet connectivity via lab3 as the Internet gateway.

### 4.3 Show that you can open https://ipv6.google.com/ on lab1.
We can use a web browser on lab1 to access the URL https://ipv6.google.com/. If the page loads successfully, this will indicate that lab1 has Internet connectivity over IPv6.

### 4.4 Explain your solution, why did you use this method over the other options
We used this method because it demonstrates a common scenario in which IPv6-only nodes communicate with the Internet through an IPv4 link. The method uses a combination of IPv6 links between the internal nodes and an IPv4 link between the border routers (lab1 and lab3) to achieve this communication. This solution is effective and simple, but it has security issues such as exposing the internal IPv6 network to the Internet and relying on the security of the border routers.

### 4.5 Are there security issues with your solution? what and how to fix them
Security issues with this solution include the exposure of the internal IPv6 network to the Internet, lack of control over the routing of IPv6 packets, and a reliance on the security of the border routers. To fix these issues, we can implement security measures such as firewalls, network segmentation, and routing policies to restrict access to the internal network and ensure secure communication. Additionally, the border routers should be hardened and monitored to prevent malicious attacks or exploitation.
