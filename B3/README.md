# B3: DNS
## Motivation
Devices on the internet are distinguishable from each other by their IP addresses. However, typing an IP address in your browser, e.g. 172.217.21.163 to reach google.com, is tedious and the addresses are difficult to remember. The Domain Name System (DNS) was designed to create an easy to remember naming system to be used instead of IP addresses. Instead of having to type an IP directly, your computer will do a query to a DNS server, finding who in the .com network owns google.com domain, and what IP is assigned to it. A single DNS server cannot store all the name-ip pairs, so DNS operates in a hierarchical manner.

Domain Name Servers are not something only internet service providers can run, but can be created quite easily inside your network as well. Using your own server allows you to create your own domain within your network. This can be used for creating a domain inside a closed corporate network, for example. Storing website-IP address pairs can also reduce the need for higher level queries, speeding up your access to a website. That is why name servers often have a cache of name-address pairs for recently/frequently requested websites.

## Description of the exercise
In this exercise you will set up a simple caching-only nameserver, implement your own .insec -domain, complete with a slave server - and finally a subdomain .not.insec, enhanced with DNSSEC. You will also try out Pi-hole - a DNS sinkhole, which can be used to stop DNS-queries for blacklisted domains.

## Additional reading
BIND9 Administrators Reference Manual
DNS for Rocket Scientists - BIND9 guide
RFC 1035 - Domain Names - Implementation and Specification
The Basics of DNSSEC
RFC 6781 - DNSSEC Operational Practices
Pi-hole documentation
## 1. Preparations
You will need at least four virtual machines for this exercise. Begin with assigning suitable host names in /etc/hosts, for example ns1, ns2, ns3 and client. Install the bind9 package on ns1 and ns2 and ns3. Setup a network topology as below:

Dns topology

## 2. Caching-only nameserver
Setup ns1 to function as a caching-only nameserver. It will not be authoritative for any domain, and will only resolve queries on behalf of the clients, and cache the results.

Configure the nameserver to forward all queries for which it does not have a cached answer to Google's public nameserver (8.8.8.8). Only allow queries and recursion from local network.

Start your nameserver and watch the logfile /var/log/syslog for any error messages. Check that you can resolve addresses through your own nameserver from the client machine. You can use dig(1) to do the lookups.

### 2.1 Explain the configuration you used.

```bash
sudo rndc flush
```

To set up a caching-only nameserver, the configuration file (typically named.conf or named.conf.options) should be updated with the following parameters:

```conf
options {
        directory "/var/cache/bind";
        forwarders {
                8.8.8.8;
        };
        allow-recursion {
                localnets;
        };
        allow-query {
                localnets;
        };
        recursion yes;
};
```

The "directory" option sets the location where the nameserver should store its cache. The "forwarders" option specifies the IP address of the public nameserver (in this case, Google's public DNS server at 8.8.8.8) to which queries for which the nameserver does not have a cached answer should be forwarded. The "allow-recursion" and "allow-query" options restrict the nameserver to accept recursive queries and queries from local networks only. The "recursion" option is set to "yes" to enable the nameserver to perform recursive queries on behalf of its clients.

```bash
vagrant@ns1:~$ sudo tail -f /var/log/syslog
Feb 11 20:18:21 ubuntu-jammy named[3225]: network unreachable resolving './NS/IN': 2001:500:2d::d#53
Feb 11 20:18:21 ubuntu-jammy named[3225]: network unreachable resolving './NS/IN': 2001:dc3::35#53
Feb 11 20:18:21 ubuntu-jammy named[3225]: network unreachable resolving './NS/IN': 2001:500:12::d0d#53
Feb 11 20:18:21 ubuntu-jammy named[3225]: network unreachable resolving './NS/IN': 2001:7fe::53#53
Feb 11 20:18:21 ubuntu-jammy named[3225]: zone localhost/IN: loaded serial 2
Feb 11 20:18:21 ubuntu-jammy named[3225]: all zones loaded
Feb 11 20:18:21 ubuntu-jammy named[3225]: running
Feb 11 20:18:21 ubuntu-jammy systemd[1]: Started BIND Domain Name Server.
Feb 11 20:18:21 ubuntu-jammy named[3225]: managed-keys-zone: Key 20326 for zone . is now trusted (acceptance timer complete)
Feb 11 20:18:21 ubuntu-jammy named[3225]: resolver priming query complete: success
^C
vagrant@ns1:~$ dig google.com @127.0.0.1

; <<>> DiG 9.18.1-1ubuntu1.3-Ubuntu <<>> google.com @127.0.0.1
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 1649
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 865cd85eca12b8bd0100000063e7f81b91ab36c6de8c7050 (good)
;; QUESTION SECTION:
;google.com.			IN	A

;; ANSWER SECTION:
google.com.		300	IN	A	142.250.186.46

;; Query time: 120 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Sat Feb 11 20:18:35 UTC 2023
;; MSG SIZE  rcvd: 83
```

### 2.2 What is a recursive query? How does it differ from an iterative query?
A recursive query is a type of DNS query where the nameserver is expected to find the answer to the query by either resolving the query itself or forwarding the query to another nameserver. The nameserver is responsible for providing the client with the final answer.

An iterative query, on the other hand, is a type of DNS query where the nameserver is expected to provide the client with the next step in resolving the query, rather than providing the final answer. The client then contacts the next nameserver in the chain to continue the resolution process.

## 3. Create your own tld .insec
Configure ns1 to be the primary master for .insec domain. For that you will need to create zone definitions, reverse mappings, and to let your server know it will be authoritative for the zone. Create a zone file for .insec with the following information:

Primary name server for the zone is ns1.insec
Contact address should be hostmaster@insec
Use short refresh and retry time limits of 60 seconds
Put your machine's ip in ns1.insec's A record
Similarly create a reverse mapping zone c.b.a.in-addr.arpa, where a, b and c are the first three numbers of the virtual machine's current IP address (i.e. IP = a.b.c.xxx -> c.b.a.in-addr.arpa).

Add a master zone entry for .insec and c.b.a.in-addr.arpa (see above) in named.conf. Reload bind's configuration files and watch the log for errors. Try to resolve ns1.insec from your client.

### 3.1 Explain your configuration.
The configuration I provided is for a primary master nameserver for the ".insec" domain, using the bind9 DNS server software. The nameserver is set up to be authoritative for the ".insec" domain and its reverse mapping zone, and to serve DNS queries for the domain and cache the results.

The configuration includes two zone files, one for the ".insec" domain and one for its reverse mapping zone. The zone files specify the SOA (Start of Authority) record, NS (Name Server) record, and A (Address) record for the host "ns1.insec". The SOA record provides information about the primary name server for the zone, the hostmaster's email address, and various time limits for refresh, retry, expire, and minimum TTL values.

The named configuration file, /etc/bind/named.conf, specifies the zones for ".insec" and its reverse mapping, and the location of the corresponding zone files. The configuration also disallows updates to the zones.

Finally, the bind9 service is restarted to apply the changes, and the syslog is checked for any error messages. The nameserver can be tested from a client machine using the dig command, which should resolve the host "ns1.insec" to its IP address.

### 3.2 Provide the output of dig(1) for a successful query.
The output of a successful dig(1) query for ns1.insec would look like this:
```bash
vagrant@ns1:~$ dig ns1.insec @127.0.0.1

; <<>> DiG 9.18.1-1ubuntu1.3-Ubuntu <<>> ns1.insec @127.0.0.1
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 58477
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 65d2806e84f6b1be0100000063e804209ecab9dd3a441755 (good)
;; QUESTION SECTION:
;ns1.insec.			IN	A

;; ANSWER SECTION:
ns1.insec.		60	IN	A	192.168.1.2

;; Query time: 0 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Sat Feb 11 21:09:52 UTC 2023
;; MSG SIZE  rcvd: 82
vagrant@ns1:~$ dig -x 192.168.1.2 @127.0.0.1

; <<>> DiG 9.18.1-1ubuntu1.3-Ubuntu <<>> -x 192.168.1.2 @127.0.0.1
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: SERVFAIL, id: 61488
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 38a402ecccad7d6f0100000063e805eb05b7d02d401056f7 (good)
;; QUESTION SECTION:
;2.1.168.192.in-addr.arpa.	IN	PTR

;; Query time: 0 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Sat Feb 11 21:17:31 UTC 2023
;; MSG SIZE  rcvd: 81
```
### 3.3 How would you add an IPv6 address entry to a zone file?
An IPv6 address entry can be added to a zone file by adding an AAAA record. The format for an AAAA record is:

```bash
hostname	IN	AAAA	IPv6Address
```

For example, if the hostname is "ns1" and the IPv6 address is "2001:0db8:85a3:0000:0000:8a2e:0370:.

## 4. Create a slave server for .insec
Configure ns2 to work as a slave for .insec domain. Use a similar configuration as for the master, but don't create zone files.

On the master server, add an entry (A, PTR and NS -records) for your slave server. Don't forget to increment the serial number for the zone. Also allow zone transfers to your slave.

Reload configuration files in both machines and watch the logs. Verify that the zone files get transferred to the slave. Try to resolve machines in the .insec domain through both servers.

### 4.1 Demonstrate the successful zone file transfer.
```bash
dig ns1.insec SOA @ns1
dig ns1.insec SOA @ns2
```
Use the dig command to query the SOA (Start of Authority) record of the .insec domain on both the master and slave servers. If the transfer was successful, the serial number of the SOA record should be the same on both servers. Or check the logs on both the master and slave servers for any errors or messages related to zone transfers.

```bash
rndc reload insec
```

### 4.2 Explain the changes you made.
To configure ns2 as a slave for the .insec domain, the following changes were made:

- On the master server, an entry for the slave server was added in the .insec zone file, including an A record, a PTR record, and an NS record. The serial number of the zone was incremented.
- The master server's named.conf file was updated to allow zone transfers to the slave server. The allow-transfer option was added to the zone definition for .insec.
- On the slave server, the named.conf file was updated to include a zone definition for .insec as a slave zone, specifying the master server's IP address.
- The configuration files for both servers were reloaded to apply the changes.

### 4.3 Provide the output of dig(1) for a successful query from the slave server. Are there any differences to the queries from the master?
```bash
vagrant@ns2:~$ dig ns1.insec @127.0.0.1

; <<>> DiG 9.18.1-1ubuntu1.3-Ubuntu <<>> ns1.insec @127.0.0.1
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 46940
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 1b24efa6f26f7a780100000063fa5c3d2dcebb4912b5cea2 (good)
;; QUESTION SECTION:
;ns1.insec.			IN	A

;; ANSWER SECTION:
ns1.insec.		60	IN	A	192.168.1.2

;; Query time: 0 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Sat Feb 25 19:06:37 UTC 2023
;; MSG SIZE  rcvd: 82
```

## 5. Create a subdomain .not.insec.
Similar to above, create a subdomain .not.insec, use ns2 as a master and ns3 as a slave. Remember to add an entry for subdomain NS in the .not.insec zone files.

N.B You are creating a subdomain of .insec, so a simple copy paste of 4 won't work . Check out bind9 delegation.

Reload configuration files in all three servers (watch the logs) and verify that the zone files get transferred to both slave servers. Try to resolve machines in .not.insec -domain from all three servers.

### 5.1 Explain the changes you made.

```bash
rndc reload not.insec
```

To create a subdomain .not.insec, the following steps can be taken:

On the master server ns2, create a zone file for .not.insec with the necessary A, PTR, and NS records. Make sure to increment the serial number for the zone.

Add an NS record for .not.insec in the .insec zone file, pointing to ns2.not.insec. This is to delegate the responsibility of the subdomain to ns2.

On ns3, configure it as a slave for the .not.insec domain. This can be done by creating a similar configuration as for the master, but without creating a zone file.

On the master server ns2, allow zone transfers to ns3.

Reload configuration files in all three servers and check the logs for any errors.

Verify that the zone files get transferred to the slave servers ns3. This can be done by checking if the zone file for .not.insec exists on ns3 and if it contains the latest updates.

### 5.2 Provide the output of dig(1) for successful queries from all the three name servers.
```bash
vagrant@client:~$ dig ns2.not.insec @ns1

; <<>> DiG 9.18.1-1ubuntu1.3-Ubuntu <<>> ns2.not.insec @ns1
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 3667
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: d372257ccfdc5ffa0100000063fb7cabcabed07a242da2e3 (good)
;; QUESTION SECTION:
;ns2.not.insec.			IN	A

;; ANSWER SECTION:
ns2.not.insec.		53	IN	A	192.168.1.3

;; Query time: 3 msec
;; SERVER: 192.168.1.2#53(ns1) (UDP)
;; WHEN: Sun Feb 26 15:37:15 UTC 2023
;; MSG SIZE  rcvd: 86
vagrant@client:~$ dig ns2.not.insec @ns2

; <<>> DiG 9.18.1-1ubuntu1.3-Ubuntu <<>> ns2.not.insec @ns2
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 2479
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: c075c4419ca943aa0100000063fb7ce7dff62dbfcfc345cc (good)
;; QUESTION SECTION:
;ns2.not.insec.			IN	A

;; ANSWER SECTION:
ns2.not.insec.		60	IN	A	192.168.1.3

;; Query time: 3 msec
;; SERVER: 192.168.1.3#53(ns2) (UDP)
;; WHEN: Sun Feb 26 15:38:15 UTC 2023
;; MSG SIZE  rcvd: 86
vagrant@client:~$ dig ns2.not.insec @ns3

; <<>> DiG 9.18.1-1ubuntu1.3-Ubuntu <<>> ns2.not.insec @ns3
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 50427
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 8a3e8065a072d6b00100000063fb7cf1b83cbb4955ae8bcb (good)
;; QUESTION SECTION:
;ns2.not.insec.			IN	A

;; ANSWER SECTION:
ns2.not.insec.		60	IN	A	192.168.1.3

;; Query time: 3 msec
;; SERVER: 192.168.1.4#53(ns3) (UDP)
;; WHEN: Sun Feb 26 15:38:25 UTC 2023
;; MSG SIZE  rcvd: 86
```

## 6. Implement transaction signatures
One of the shortcomings of DNS is that the zone transfers are not authenticated, which opens up an opportunity to alter the zone files during updates. Prevent this by enhancing the .not.insec -domain to implement transaction signatures.

Generate a secret key to be shared between masters and slaves with the command tsig-keygen(8). Use HMAC-SHA1 as the algorithm.

Create a shared key file with the following template:

```conf
key keyname {
algorithm hmac-sha1;
secret "generated key";
};

# server to use key with
server ip-addr {
keys { keyname; };
};
```

Fill in the generated key and server IP address, and make the key available to both the name servers of .not.insec. Include the key file in both the .not.insec name servers' named.conf files, and configure servers to only allow transfers signed with the key.

First try an unauthenticated transfer - and then proceed to verify that you can do authenticated zone transfers using the transaction signature.

### 6.1 Explain the changes you made. Show the successful and the unsuccessful zone transfer in the log.
to implement transaction signatures in the .not.insec domain, the following steps can be taken:

- Generate a secret key to be shared between the master and slave name servers using the tsig-keygen command and selecting the HMAC-SHA1 algorithm.
- Create a shared key file using the template provided, filling in the generated key and the IP address of the servers.
- Make the key available to both name servers by including the key file in their named.conf files.
- Configure the servers to only allow transfers signed with the key by adding the appropriate statements in the named.conf files.
- Verify that an unauthenticated transfer fails and that an authenticated transfer using the transaction signature succeeds.

`sudo tail -f /var/log/syslog`

### 6.2 TSIG is one way to implement transaction signatures. DNSSEC describes another, SIG(0). Explain the differences.
TSIG (Transaction SIGnature) is one way to implement transaction signatures in DNS. TSIG uses a shared secret key to sign the messages exchanged between name servers, providing authentication and integrity protection.

DNSSEC (Domain Name System Security Extensions) describes another way to implement transaction signatures, using digital signatures instead of shared secrets. DNSSEC uses public-key cryptography to sign the zone data, providing not only authentication and integrity protection but also confidentiality protection.

In conclusion, while both TSIG and DNSSEC provide transaction signature functionality, DNSSEC provides a more secure solution through the use of digital signatures and public-key cryptography.

## 7. Pi-hole DNS sinkhole
Install Pi-hole on ns1 and configure the client to use it as their DNS. Perform a dig(1) query to a non-blacklisted domain such as google.com. Then blacklist that domain on the Pi-hole and repeat the query. (The result should not be same for both runs.) 

### 7.1 Based on the dig-queries, how does Pi-hole block domains on a DNS level? 
Pi-hole blocks domains on a DNS level by intercepting the DNS queries made by the client and matching the domain name being queried with the domains in its blacklist. If the domain is found in the blacklist, Pi-hole returns an IP address that leads to nowhere, effectively blocking the client's access to the domain.

### 7.2 How could you use Pi-hole in combination with your own DNS server, such as your caching-only nameserver? 
Pi-hole can be used in combination with a caching-only nameserver by configuring the caching-only nameserver to forward the DNS queries to Pi-hole. This way, Pi-hole can be used as a first line of defense in blocking unwanted domains, while the caching-only nameserver can be used to improve the performance of the DNS resolution by caching the frequently used domains.
