# B5: VPN
## Motivation
The government is spying on your internet use. Hackers are spying on you. Use VPN to protect yourself. Service providers are blocking overseas customers. Use VPN to bypass this.

You may have heard statements like the ones above from tech news, your favourite streamer or podcaster and VPN advertisements. VPNs can be used as proxies to hide the origin of web traffic by routing traffic through a VPN server in another location. They can also be used to hide your traffic from prying eyes by encrypting the traffic between your computer and the VPN server and burying the traffic into the massive flood of traffic going to and from the VPN server on the other end of the tunnel.

In this assignment, however, you will create a VPN bridge, that allows you to access a LAN network from the outside, as if the computer was a part of that network. You will provide an IP address from said network for the computer. This method can be used for accessing e.g. a corporate network over the internet.

## Description of the exercise
This assignment introduces you to the Virtual Private Network (VPN) concept. You will use OpenVPN and all three VMs to establish a VPN in practice by creating and examining a host-to-net VPN scenario. A roadwarrior host (lab3, RW) establishes a secure tunnel to a gateway (lab1, GW). Traffic can flow from the roadwarrior through the gateway to a Storage server (lab2, SS)  and back. Hosts on the right-side local link can not eavesdrop or modify the traffic flowing inside the tunnel. Here’s what the resulting network will look like.


The goal of this assignment is to test communication between the Storage Server and the Road Warrior by successfully pinging and tracerouting each other in both directions. OpenVPN will be used in bridging mode to connect the RW to the local network of SS and GW.

## Additional reading
OpenVPN HOWTO
How to Create Keys
## 1. Initial Setup
Install openvpn package for GW and RW if it has not been preinstalled. Install also bridge-utils for GW.

On lab1 (GW):

Assign a static IP from the subnet 192.168.0.0/24 to the interface enp0s8
Assign a static IP from the subnet 192.168.2.0/24 to the interface enp0s9
On lab2 (SS):

Assign a static IP from the subnet 192.168.0.0/24 to the interface enp0s8
On lab3 (RW):

Assign a static IP from the subnet 192.168.2.0/24 to the interface enp0s8
In this exercise, the enp0s3 interfaces are only used for SSH remote access. Do not use them for any other traffic. Verify that you can ping the gateway from the other hosts, and that you can not ping the RW from the SSor vice versa. Write down the network configuration.

### 1.1 Present your network configuration. What IPs did you assign to the interfaces (4 interfaces in all) of each of the three hosts?
On lab1 (GW):
- 192.168.0.2 -> enp0s8
- 192.168.2.2 -> enp0s9

On lab2 (SS):
- 192.168.0.3 -> enp0s8

On lab3 (RW):
- 192.168.2.3 -> enp0s8

## 2. Setting up a PKI (Public Key Infrastructure)
The first step in establishing an OpenVPN connection is to build the public key infrastructure (PKI).

You'll need to generate the master Certificate Authority (CA) certificate/key, the server certificate/key and a key for at least one client. In addition you also have to generate the Diffie-Hellman parameters for the server. Note: the Ubuntu openvpn package no longer ships with easy-rsa.

After you have generated all the necessary certificates and keys, copy the necessary files (securely) to the road warrior (RW) host.

### 2.1 What is the purpose of each of the generated files? Which ones are needed by the client?
The purpose of each of the generated files in the PKI for OpenVPN is as follows:

- Master Certificate Authority (CA) certificate/key: This is the root certificate/key that is used to sign all other certificates in the PKI. It is used to establish trust between the OpenVPN server and the clients.
- Server certificate/key: This certificate/key is used by the OpenVPN server to authenticate itself to the clients.
- Client certificate/key: This certificate/key is used by the OpenVPN clients to authenticate themselves to the server.
- Diffie-Hellman (DH) parameters: These parameters are used to establish the initial encryption key that is used for the OpenVPN connection.
- TLS authentication key: This is an additional layer of security that is used to authenticate the OpenVPN packets and prevent unauthorized access.

For a client to establish a connection with the OpenVPN server, they need to have the following files:
- Client certificate/key
- CA certificate
The DH parameters and TLS authentication key are already used during the initial handshake between the server and the client.

### 2.2 Is there a simpler way of authentication available in OpenVPN? What are its benefits/drawbacks?
Yes, there is a simpler way of authentication available in OpenVPN called "static key authentication". In this method, a pre-shared secret key is used instead of a PKI. The benefit of this method is that it is simple to set up and does not require the overhead of a PKI. However, the drawback is that it is less secure than using a PKI, as there is only one shared secret key for all clients and the server. This means that if the key is compromised, all clients are compromised.

## 3. Configuring the VPN server
On GW copy /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz to for example /etc/openvpn and extract it. You have to edit the server.conf to use bridged mode with the correct virtual interface. You also have to check that the keys and certificates point to the correct files. Set the server to listen for connection in GW's enp0s9 IP address.

Start the server on GW with openvpn server.conf .

### 3.1 List and give a short explanation of the commands you used in your server configuration.


### 3.2 What IP address space did you allocate to the OpenVPN clients?

10.8.0.0/24

### 3.3 Where can you find the log messages of the server by default? How can you change this?
The log messages of the OpenVPN server are typically stored in the syslog on Linux systems. However, the location can be changed by modifying the "log" option in the OpenVPN server configuration file. Additionally, the "verb" option can be used to control the verbosity of the log messages.

## 4. Bridging setup
Next you have to setup network bridging on the GW. We'll combine the enp0s8 interface of the gateway with a virtual TAP interface and bridge them together under an umbrella bridge interface.

OpenVPN provides a script for this in /usr/share/doc/openvpn/examples/sample-scripts . Copy the bridge-start and the bridge-stop scripts to a different folder for editing. Edit the parameters of the script files to match with GW's enp0s8. Start the bridge and check with ifconfig that the bridging was successful.

### 4.1 Show with ifconfig that you have created the new interfaces (virtual and bridge). What's the IP of the bridge interface?

Same as enp0s8, which is 192.168.0.2

### 4.2 What is the difference between routing and bridging in VPN? What are the benefits/disadvantages of the two? When would you use routing and when bridging?
Routing and bridging are two different methods for connecting networks in a VPN.

Routing: In routing mode, the VPN server acts as a gateway between two separate networks. Each client connects to the VPN server and sends all of its traffic to the server, which then routes it to the other network. This method can be used to connect networks that are not in the same broadcast domain.

Bridging: In bridging mode, the VPN server creates a virtual network interface that is connected to the physical network interface of the server. The VPN clients connect to the virtual interface and appear as if they are directly connected to the physical network. This method can be used to connect networks that are in the same broadcast domain.

The benefits of routing include scalability, ease of configuration, and the ability to connect networks that are not in the same broadcast domain. The drawbacks of routing include reduced performance due to the overhead of routing packets, and the need for more complex configuration.

The benefits of bridging include improved performance and simplicity of configuration, as the VPN clients appear as if they are directly connected to the physical network. The drawbacks of bridging include reduced scalability, as bridging can become more difficult to manage as the number of clients increases, and the inability to connect networks that are not in the same broadcast domain.

Routing is typically used when connecting separate networks, while bridging is typically used when connecting clients to an existing network.

## 5. Configuring the VPN client and testing connection
On RW copy /usr/share/doc/openvpn/examples/sample-config-files/client.conf to for example /etc/openvpn. Edit the client.conf to match with the settings of the server. Remember to check that the certificates and keys point to the right folders.

Connect RW to the server on GW with openvpn client.conf. Pinging the SSfrom RW should now work.

If you have problems with the ping not going through, go to VirtualBox network adapter settings and allow promiscuous mode for internal networks that need it.

### 5.1 List and give a short explanation of the commands you used in your VPN client configuration.


### 5.2 Demonstrate that you can reach the SS from the RW. Setup a server on the client with netcat and connect to this with telnet/nc. Send messages to both directions.

```bash
vagrant@lab2:~$ nc -l 5000
vagrant@lab3:~$ nc lab2 5000
```

### 5.3 Capture incoming/outgoing traffic on GW's enp0s9 or RW's enp0s8. Why can't you read the messages sent in 5.2 (in plain text) even if you comment out the cipher command in the config-files?

```bash
vagrant@lab1:~$ sudo tcpdump -i enp0s9
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on enp0s9, link-type EN10MB (Ethernet), snapshot length 262144 bytes
15:11:39.271040 IP lab1.openvpn > lab3.38033: UDP, length 103
15:11:39.272148 IP lab3.38033 > lab1.openvpn: UDP, length 90
15:11:43.389403 IP lab1.openvpn > lab3.38033: UDP, length 99
15:11:43.390460 IP lab3.38033 > lab1.openvpn: UDP, length 90
15:11:44.310391 ARP, Request who-has lab3 tell lab1, length 28
15:11:44.310966 ARP, Reply lab3 is-at 08:00:27:87:67:a3 (oui Unknown), length 46
15:11:44.376444 ARP, Request who-has lab1 tell lab3, length 46
15:11:44.376444 IP lab3.38033 > lab1.openvpn: UDP, length 66
15:11:44.376451 ARP, Reply lab1 is-at 08:00:27:0b:9c:95 (oui Unknown), length 28
15:11:44.377095 IP lab1.openvpn > lab3.38033: UDP, length 84
15:11:51.193709 IP lab1.openvpn > lab3.38033: UDP, length 105
15:11:51.194818 IP lab3.38033 > lab1.openvpn: UDP, length 90
15:11:54.587364 IP lab1.openvpn > lab3.38033: UDP, length 96
15:11:54.588168 IP lab3.38033 > lab1.openvpn: UDP, length 90
```

Because the OpenVPN protocol encapsulates the messages inside encrypted packets using SSL/TLS encryption. The messages are only decrypted on the receiving end after going through the OpenVPN encryption and decryption process.

### 5.4 Enable ciphering. Is there a way to capture and read the messages sent in 5.2 on GW despite the encryption? Where is the message encrypted and where is it not?

Enabling ciphering in the OpenVPN configuration will encrypt the messages being sent between the client and the server using SSL/TLS encryption. The encryption happens on the client-side before sending the messages and on the server-side before receiving the messages. Therefore, even if we capture the encrypted packets using a packet capture tool like tcpdump or Wireshark, we won't be able to read the messages in plain text because they are still encrypted.

However, if we have the correct encryption keys or certificates, we can decrypt the captured packets and read the messages in plain text. This can be done using Wireshark's SSL/TLS decryption feature. By providing the decryption keys or certificates, Wireshark can decrypt the captured packets and display the contents in plain text.

### 5.5 Traceroute RW from SS and vice versa. Explain the result.

```bash
vagrant@lab3:~$ traceroute lab2
traceroute to lab2 (192.168.0.3), 64 hops max
  1   192.168.0.3  2.035ms  1.307ms  0.856ms
```

The result of the traceroute command indicates that the destination host "lab2" with IP address 192.168.0.3 was reached within a single hop, with a response time of 2.035ms. This suggests that the source host and the destination host are on the same local network segment, and there are no intermediate routers or gateways that the packets need to pass through to reach the destination with VPN. Therefore, the packets can be sent directly from the source host to the destination host with minimal latency.

## 6. Setting up routed VPN
In this task, you have to set up routed VPN as opposed to the bridged VPN above.  Stop openvpn service on both server and client.
1. Reconfigure the server.conf and the client.conf to have routed vpn.
2. Restart openvpn service on both server and client.
3. Now you should be able to ping virtual IP address of vpn server from client.

### 6.1 List and give a short explanation of the commands you used in your server configuration


### 6.2 Show with ifconfig that you have created the new virtual IP interfaces . What's the IP  address?

10.8.0.1

```bash
vagrant@lab1:~$ ifconfig
enp0s3: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.2.15  netmask 255.255.255.0  broadcast 10.0.2.255
        inet6 fe80::22:61ff:fefc:e956  prefixlen 64  scopeid 0x20<link>
        ether 02:22:61:fc:e9:56  txqueuelen 1000  (Ethernet)
        RX packets 25020  bytes 35139561 (35.1 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 4943  bytes 461701 (461.7 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

enp0s8: flags=4419<UP,BROADCAST,RUNNING,PROMISC,MULTICAST>  mtu 1500
        inet 192.168.0.2  netmask 255.255.255.0  broadcast 192.168.0.255
        inet6 fe80::a00:27ff:fe88:f7f2  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:88:f7:f2  txqueuelen 1000  (Ethernet)
        RX packets 17  bytes 1332 (1.3 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 46  bytes 4190 (4.1 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

enp0s9: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.2.2  netmask 255.255.255.0  broadcast 192.168.2.255
        inet6 fe80::a00:27ff:feea:192f  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:ea:19:2f  txqueuelen 1000  (Ethernet)
        RX packets 125  bytes 19526 (19.5 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 92  bytes 15679 (15.6 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 298  bytes 27214 (27.2 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 298  bytes 27214 (27.2 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

tun0: flags=4305<UP,POINTOPOINT,RUNNING,NOARP,MULTICAST>  mtu 1500
        inet 10.8.0.1  netmask 255.255.255.255  destination 10.8.0.2
        inet6 fe80::7d74:a553:f497:b79c  prefixlen 64  scopeid 0x20<link>
        unspec 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  txqueuelen 500  (UNSPEC)
        RX packets 79  bytes 6636 (6.6 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 41  bytes 3192 (3.1 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```
