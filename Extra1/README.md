# Extra: SDN
## Motivation
IP networks are becoming increasingly complex. Traditional network devices like routers have a limited view of the network and use that to make routing decisions. Also when such a device fails,it might take a long time for the network to react and find alternative routes. Further, maintenance of such devices is time and labor expensive. Software Defined Networking decouples the control(routing) plane from forwarding plane, enabling efficient centralized network management which allows for agile response to network changes.

## Description of the exercise
This assignment will introduce you to software-defined networks (SDN) basics using Mininet. First you'll be setting up a virtual machine equipped with tools and applications for testing and configuring a Mininet OpenFlow environment. Later on, you'll modify the example OpenFlow controllers to apply your own forwarding rules to the switches in Mininet.

## Additional reading
OpenFlow - Enabling Innovation in Campus Networks
Pox Wiki - Pox documentation resource
Mininet walkthrough
Ryu
## 1. Preparation
Unlike the previous exercises, this exercise is done using a separate preinstalled virtual machine on your own personal computer. First you'll need to install X-server (Xming for Windows or XQuartz for Mac OSX). Linux distributions usually have X-server preinstalled.

SDN is a concept that is easy to get confused with. However, the basic idea of SDN is very simple and it was first discussed as early as in the 90s. Today there are viable implementations that take advantage of the concept. After you have delved into the subject you will try your hand with practical tasks involving virtual network components that are software-defined.

### 1.1 What is SDN and how is OpenFlow related to it?
SDN (Software-Defined Networking) is a network architecture approach that decouples the control plane and data plane of traditional network devices. The control plane is responsible for network management and routing decisions, while the data plane handles forwarding of network traffic. In an SDN architecture, the control plane is separated from the data plane and managed centrally, enabling network administrators to program network behavior through software applications.

OpenFlow is a protocol that is used in SDN to communicate between the control plane and data plane. It defines how packets are forwarded within an SDN network and enables network administrators to programmatically define forwarding behavior through software applications. OpenFlow is just one of many protocols that can be used in SDN architectures, but it is one of the most widely used and well-known.

## 2. Setting up the Mininet virtual machine
First, you need to download the VirtualBox Mininet (2.2.2 or 2.3) image found here. Import the image you created in VirtualBox and set up port forwarding for SSH. This port forwarding will be used for connecting to the Mininet environment. The IP address of the virtual machine's eth0 should be 10.0.2.15. If you want to create your own VM and install Mininet from source, the intrsuctions are here.

You should now be able to connect to the VM with X forwarding enabled using SSH. The username is mininet and password is mininet.

## 3. Mininet
Start Mininet using single mn command which defines a topology of a single switch and three hosts. In addition the command must define that the OpenFlow controller is remote and the hosts will automatically get ascending mac addresses and static ARP entries. Adding ARP entries is important for assignments 4, 5 and 6. By testing connectivity you should notice, that the hosts are not able to connect since there is no controller connected. We are not going to connect a controller, but use a dpctl tool to install the flows.

Run the following commands in mininet console and test the connectivity again:

dpctl add-flow in_port=1,actions=output:2
dpctl add-flow in_port=2,actions=output:1

### 3.1 What was the command to start the mininet with the additional specifications listed above?
```bash
sudo mn --topo=single,3 --mac --arp --controller=remote
```

This command defines a single switch topology with three hosts, assigns ascending MAC addresses to hosts, creates static ARP entries, and specifies a remote controller.

### 3.2 What exactly does the tool dpctl do?
dpctl is a command-line tool used for managing OpenFlow switches. It allows users to query and modify the flow tables of OpenFlow switches. In the given context, dpctl is used to add flow entries to the switch's flow table.


Take a look into example scripts in /home/mininet/mininet/examples or Mininet walkthrough and using the scripts as template create a python script that creates a tree-topology described below:

sdn_topology

In the script include commands to start the network, dump the link information of hosts and switches. (See: dumpNodeConnections() -function.) Finally test the connectivity with pingall.
### 3.3 Present the python script that creates the tree-topology described above.


### 3.4 Explain the connection link information dump data and use it to prove the correct tree-like topology.


### 3.5	 Create the topology shown below so that a route between h1 and h3 exists and a route between h2 and h4, but there is not connectivity between h1/h3 and h2/h4


## 4. POX OpenFlow Controller
Instead of using the reference controller we'll next connect a POX OpenFlow controller to the Mininet effectively changing the network behaviour according to the modules loaded in POX.

POX is preinstalled on the VM image. Start up POX with a hub-like controller module* /home/mininet/pox/pox/forwarding/hub.py, which floods all traffic to every port in switch except the input port. Start Mininet with the command used in assignment 3.1. Verify the hub behaviour with tcpdump at h1, h2 and h3 (run "xterm h1 h2 h3" in mininet console to access the hosts). After verifying everything works, alter the hub module to direct all traffic from switch port 1 to port 2 and vice versa. Take a look into /home/mininet/pox/pox/forwarding for examples. Verify functionality by tcpdump.

*To run pox modules: "pox.py pox.directory.file" e.g. "pox.py pox.forwarding.hub".

### 4.1 Present your POX controller module that directs all traffic between port 1 and 2.


### 4.2 Ping from h1 to h3 while tcpdumping at h2. Why is h2 receiving the packets that are destined to h3?


## 5. Ryu
As demonstrated in the previous assignments, one can control a switch remotely using dpctl and low-level python commands. However, constructing complex applications like firewalling, load-balancing or such using only low-level tools can be tricky. SDN controllers like Ryu raise the abstraction level thus enabling developers more powerful tools over programmable switches. You have to install Ryu in the VM image.

Start up Ryu with:

ryu-manager  ryu.app.simple_switch_13

This module is a layer-2 learning switch. Start Mininet with the command used in assignment 3.1 with "--switch=ovsk".   Open up xterms in mininet console for each host (xterm h1 h2 h3). Begin monitoring the interfaces from each machine using tcpdump. Ping from h1 to h2.
### 5.1 Explain the results of tcpdump. Why does the switch flood the first packet that arrives to all hosts instead of h2? show the ARP entries in h1?


### 5.2 Explain the console output of Ryu controller


## 6. Implementing firewall in Ryu
Next you will be extending the functionality of the switch with  filtering using Ryu. Take a look here for inspiration. Start up Mininet with the command used in assignment 3.1 with "-- switch=ovsk,protocols=OpenFlow13", but change the amount of hosts connected to the switch to 8.

You'll need to drop all the traffic between these two end-points.

h1-------- h8
h2---------h7
h3---------h6
h4---------h5

You can create your firewall based on the app in ryu.app.rest_firewall, you can either code the app to have the rules built in or user the rest API to add rules after starting the controller app with ryu-manager ryu.app.rest_firewall.
Capture the OpenFlow FlowMod, PacketIn and PacketOut messages using wireshark with filter "of". Observe the network behaviour with Mininet console command pingall.

After finishing the firewall module you should see the following output when executing pingall at Mininet console:

mininet> pingall
*** Ping: testing ping reachability
h1 -> h2 h3 h4 h5 h6 h7 X
h2 -> h1 h3 h4 h5 h6 X h8
h3 -> h1 h2 h4 h5 X h7 h8
h4 -> h1 h2 h3 X h6 h7 h8
h5 -> h1 h2 h3 X h6 h7 h8
h6 -> h1 h2 X h4 h5 h7 h8
h7 -> h1 X h3 h4 h5 h6 h8
h8 -> X h2 h3 h4 h5 h6 h7
### 6.1 Present and explain your solution


### 6.2 Explain the FlowMod, PacketIn and PacketOut messages in the wireshark capture log.

