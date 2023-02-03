# B2: Web Server
## Motivation
Serving a web page requires a running server listening for incoming HTTP requests, and answering them by returning the requested page. Taking last exercise’s bogus server further, this time you will serve an actual web page to a browser requesting it. Websites can consist of multiple servers around the world, to load balance, to keep latency low, or to keep important information on more secure servers. To simulate this, you will set up a reverse proxy that will forward different requests to different servers.

## Suggested reads
Apache module index - You can check the usage of the needed modules
RFC 5280 - Public Key Infrastructure Certificate Profile
## Description of the exercise
In this exercise, you will introduce yourself to some basic features of Apache web server and its plugins. In addition to that you will set up a Node.js server for serving a webpage, and configure an nginx server as a reverse proxy for the servers. Take into account that from now on you'll have to do extensive self-research to be able to successfully complete the assignments. You will need three virtual machines to complete this assignment. The final web server network configuration will look like the image below.webserver topology

## 1. Apache2
Install Apache2 on lab2. The modules used later for serving user directory contents, rewriting URLs and setting up SSL should come with Apache2 by default. Set up SSH port forwarding for HTTP and HTTPS so that you can test the server on your local machine (localhost) with your favourite web browser. Note that VirtualBox port forwarding is not the way to do this! Instead, look into the ssh(1) manual page and use an ssh command to link the ports on the virtual machines to ports on the host.

### 1.1 Serve a default web page using Apache2

curl -s http://localhost

### 1.2 Show that the web page can be loaded on local browser (your machine or Niksula) using SSH port forwarding.

```bash
vagrant ssh-config > vagrant-ssh
sudo ssh -F vagrant-ssh -L 80:localhost:80 lab2
```

## 2. Serve a web page using Node.js
Install nodejs on lab3 from package manager and create an HTTP application helloworld.js listening on port 8080 that serves a web page with the text "Hello world!".

The web pages served by Node.js are written in javascript, but you do not actually need to know how to write it, because there's plenty of hello world examples on the internet. You do need to understand the contents.

The purpose of this assignment is to familiarize yourself with the increasingly popular and simple method of serving web applications using Node.js. Although javascript skills are not really needed in this assignment, we strongly recommend that you take a deeper look at javascript and also node.js

### 2.1 Provide a working web page with the text "Hello World!"

See lab3.sh

### 2.2 Explain the contents of the helloworld.js javascript file.

See lab3.sh

### 2.3 What does it mean that Node.js is event driven? What are the advantages in such an approach?

Node.js is an event-driven programming model, which means that it is designed to handle multiple events or inputs simultaneously, rather than executing them one after another in a linear sequence. This allows Node.js to handle many concurrent connections and perform other tasks while waiting for input or output to be available.

In an event-driven model, the program sets up a series of event handlers that are triggered when specific events occur. For example, in a web server, an event handler might be set up to handle incoming HTTP requests. When a request is received, the event handler is triggered and the appropriate action is taken.

The advantages of an event-driven model include:

- Scalability: Because it can handle multiple events simultaneously, an event-driven model can handle a large number of concurrent connections or inputs without becoming bogged down.

- Non-blocking I/O: Node.js uses a non-blocking I/O model, which means that it can perform other tasks while waiting for input or output to be available. This allows Node.js to handle many concurrent connections without having to wait for each one to complete before moving on to the next.

- Asynchronous programming: Node.js uses an asynchronous programming model, which means that it can handle multiple events at the same time without having to wait for one to complete before starting the next. This allows for more efficient use of system resources and can result in faster overall performance.

- Responsive: Node.js is designed to handle multiple connections and perform other tasks while waiting for input or output to be available, which means that it is able to respond quickly to incoming requests or other events.

- Efficient: Event-driven model is ideal when you have many I/O operations happening like in the case of web servers, since the program can handle multiple requests at the same time, without having to wait for one request to complete before starting the next one, which is more efficient.
 

## 3. Configuring SSL for Apache2
On lab2, use the Apache ssl module to enable https connections to the server. Create a 2048-bit RSA-key for the Apache2 server. Then create a certificate that matches to the key. Configure Apache2 to use this certificate for HTTPS traffic. Set up again SSH port forwarding for the HTTPS port to test the secure connection using your local browser (if it is not active already).

Note: Taking a shortcut with CA.pl is not accepted, you need to understand the process! Only a few commands are needed, though. Both the key and certificate can be created simultaneously using a single shell command. 

### 3.1 Provide and explain your solution.
```bash
sudo ssh -F vagrant-ssh -L 443:localhost:443 lab2
curl https://localhost -k
```

### 3.2 What information can a certificate include? What is necessary for it to work in the context of a web server?

A certificate is a digital document that is used to authenticate the identity of a website or other entity over the internet. A certificate includes information such as the domain name of the website, the name and address of the organization that owns the website, and the name of the certificate authority that issued the certificate. It also includes a public key and a digital signature that can be used to verify the authenticity of the certificate. For a certificate to work in the context of a web server, it must be issued by a trusted certificate authority and it must be installed on the server and properly configured so that it is used for HTTPS connections.

### 3.3 What do PKI and requesting a certificate mean?

PKI (Public Key Infrastructure) is a set of technologies and policies that are used to secure digital communications and transactions by creating a trust infrastructure. A key component of PKI is the use of digital certificates, which are used to authenticate the identity of a website or other entity over the internet. Requesting a certificate means asking a certificate authority (CA) to issue a digital certificate, which is a digital document that contains information about the identity of a website or other entity, along with a public key. The certificate is then used to establish trust between the server and the clients that connect to it. The process of requesting a certificate includes providing the necessary information to the CA, such as the domain name of the website and the name and address of the organization that owns the website, and then verifying that the information is correct and that the organization is authorized to use the domain name.
 
## 4. Enforcing HTTPS
On lab2, create a “public_html” directory and subdirectory called "secure_secrets" in your user’s home directory. Use the Apache userdir module to serve public_html from users' home directories.

Enforce access to the secure_secrets subdirectory with HTTPS by using rewrite module and .htaccess file, so that Apache2 forwards "http://localhost/~user/secure_secrets" to "https://localhost/~user/secure_secrets". Please note that this is a bit more complicated to test with the ssh forwarding, so you can test it locally with lynx or netcat at the virtual machine. If your demo requires, you may hard-code your port numbers to the forwarding rules.

### 4.1 Provide and explain your solution.

```bash
sudo ssh -F vagrant-ssh -L 443:localhost:443 lab2
curl https://localhost/~vagrant -k
```

### 4.2 What is HSTS?

HSTS (HTTP Strict Transport Security) is a security mechanism that is used to help protect websites against man-in-the-middle (MITM) attacks. It works by telling web browsers that they should only communicate with a website over HTTPS, even if the user types "http://" in the URL bar or clicks on a link that starts with "http://". This helps to prevent attackers from intercepting and modifying the communication between the browser and the website, and can help to protect users from phishing and other types of attacks.

### 4.3 When to use .htaccess? In contrast, when not to use it?

.htaccess is a configuration file that is used to control how Apache web server behaves for a specific directory and its subdirectories. The .htaccess file is typically used to configure the server for specific functionality, such as setting up redirects, password protection, and custom error pages. It can also be used to configure the server for specific functionality, such as setting up redirects, password protection, and custom error pages.

It's typically used when you don't have access to the main apache configuration or when you have a shared hosting environment.

When not to use it:

- When you have access to the main apache configuration and can make changes there instead.
- When you are dealing with a high traffic website, as .htaccess files may slow down the server and cause performance issues.
- When you have a lot of rules and configurations, it can become hard to manage and test the rules in a .htaccess file.
- When you are using a different web server other than Apache.
- It's important to note that using .htaccess is not always the best option, and it's best to use it in the proper context.The contents of the nginx configuration file are used to configure the behavior of the nginx server. The example above, it's defining a "server" block. Within this block, the first line is the "listen" directive, which tells nginx to listen on port 80 for incoming requests. The second line is the "server_name" directive, which tells nginx to respond to requests for the hostname "lab1".

Then we have two "location" blocks, one for /apache and one for /node, this blocks define the behavior of the server when a request is made to a specific path. The "proxy_pass" directive in each block tells nginx to forward requests to the specified URL.
 
## 5. Install nginx as a reverse proxy
Next, you are going to serve both Apache2 and Node.js hello world from lab1 using nginx as a reverse proxy.

Install nginx on lab1 and configure it to act as a gateway to both Apache2 at lab2 and Node.js at lab3 the following way:

HTTP requests to http://lab1/apache are directed to Apache2 server listening on lab2:80 and requests to http://lab1/node to Node.js server on lab3:8080.

### 5.1 Provide a working solution serving both web applications from nginx.

See lab1.sh

### 5.2 Explain the contents of the nginx configuration file.

The contents of the nginx configuration file are used to configure the behavior of the nginx server. The example above, it's defining a "server" block. Within this block, the first line is the "listen" directive, which tells nginx to listen on port 80 for incoming requests. The second line is the "server_name" directive, which tells nginx to respond to requests for the hostname "lab1".

Then we have two "location" blocks, one for /apache and one for /node, this blocks define the behavior of the server when a request is made to a specific path. The "proxy_pass" directive in each block tells nginx to forward requests to the specified URL.

### 5.3 What is commonly the primary purpose of an nginx server and why?
The primary purpose of an nginx server is to act as a reverse proxy. It's commonly used as a reverse proxy to handle incoming HTTP and HTTPS requests and forward them to the appropriate backend server, in this case Apache2 and Node.js. This allows nginx to handle tasks such as load balancing, SSL/TLS termination, caching, and serving static files, so that the backend servers can focus on handling the application-specific tasks. Additionally, nginx is highly configurable and can be used for a variety of purposes, such as a reverse proxy, web server, load balancer, and more. It is also known for its high performance and low resource usage, making it a popular choice for high traffic websites and web applications.

 
## 6. Test Damn Vulnerable Web Application
For security purposes, security professionals and penetration testers set up a Damn Vulnerable Web Application to practice some of the most common vulnerabilities. To achieve this goal, you can download the file in https://github.com/digininja/DVWA/archive/master.zip and install it. Finally, install Nikto tool which is an open-source web server scanner on lab 1 and scan your vulnerable web application.

### 6.1 Using Nmap, enumerate the lab2, and detect the os version, php version, apache version and open ports
Result:

https://nmap.org/nsedoc/scripts/http-php-version.html

```bash
vagrant@lab1:~$ nmap -A -T4 lab2
Starting Nmap 7.80 ( https://nmap.org ) at 2023-02-03 22:36 UTC
Nmap scan report for lab2 (192.168.1.3)
Host is up (0.0018s latency).
Not shown: 997 closed ports
PORT    STATE SERVICE VERSION
22/tcp  open  ssh     OpenSSH 8.9p1 Ubuntu 3 (Ubuntu Linux; protocol 2.0)
80/tcp  open  http    Apache httpd 2.4.52 ((Ubuntu))
| http-robots.txt: 1 disallowed entry 
|_/
|_http-server-header: Apache/2.4.52 (Ubuntu)
|_http-title: Apache2 Ubuntu Default Page: It works
443/tcp open  ssl/ssl Apache httpd (SSL-only mode)
| http-robots.txt: 1 disallowed entry 
|_/
|_http-server-header: Apache/2.4.52 (Ubuntu)
|_http-title: Apache2 Ubuntu Default Page: It works
| ssl-cert: Subject: organizationName=Internet Widgits Pty Ltd/stateOrProvinceName=Some-State/countryName=AU
| Not valid before: 2023-02-03T22:33:21
|_Not valid after:  2024-02-03T22:33:21
| tls-alpn: 
|_  http/1.1
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 13.26 seconds
```

This command tells Nmap to perform a version detection scan (-A) and to use a timing template of level 4 (-T4) on lab2.

### 6.2 Using Nikto, to detect vulnerabilities on lab2
```bash
vagrant@lab1:~$ nikto -h http://lab2
- Nikto v2.1.5
---------------------------------------------------------------------------
+ Target IP:          192.168.1.3
+ Target Hostname:    lab2
+ Target Port:        80
+ Start Time:         2023-01-24 22:00:56 (GMT0)
---------------------------------------------------------------------------
+ Server: Apache/2.4.52 (Ubuntu)
+ Server leaks inodes via ETags, header found with file /, fields: 0x29af 0x5f30991cd2060 
+ Uncommon header 'x-content-type-options' found, with contents: nosniff
+ Uncommon header 'x-frame-options' found, with contents: DENY
+ Cookie security created without the httponly flag
+ Cookie PHPSESSID created without the httponly flag
+ No CGI Directories found (use '-C all' to force check all possible dirs)
+ File/dir '/' in robots.txt returned a non-forbidden or redirect HTTP code (200)
+ "robots.txt" contains 1 entry which should be manually viewed.
+ Multiple index files found: index.php, index.html
+ Allowed HTTP Methods: GET, POST, OPTIONS, HEAD 
+ OSVDB-3268: /config/: Directory indexing found.
+ /config/: Configuration information may be available remotely.
+ OSVDB-3233: /phpinfo.php: Contains PHP configuration information
+ OSVDB-3268: /tests/: Directory indexing found.
+ OSVDB-3092: /tests/: This might be interesting...
+ OSVDB-3268: /database/: Directory indexing found.
+ OSVDB-3093: /database/: Databases? Really??
+ OSVDB-3268: /docs/: Directory indexing found.
......
```
