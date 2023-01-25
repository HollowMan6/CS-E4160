# A2: Email Server
## Motivation

Setting up email servers isn’t something only big corporations like Google and Microsoft can do. In fact, setting up an email server on your virtual machines is relatively easy. This familiarizes you with the issues involved in running an email service, such as “How to deal with spam?” You will also learn about the structure of an email message, like the HTTP request from the previous exercise. You can see the mail process architecture between sender and receiver.

In an email delivery architecture, the following acronyms are used:

UA = User Agent, MSA = Mail Submission Agent, MTA = Mail Transfer Agent, AA = Access Agent

UA-to-MSA or -MTA as a message is injected into the mail system

MSA-to-MTA as the message starts its delivery journey

MTA- or MSA-to-antivirus or -antispam scanning programs 

MTA-to-MTA as a message is forwarded from one site to another 

MTA-to-DA as a message is delivered to the local message store


## Description of the exercise

In this exercise you will learn how to setup an email server with filtering rules and spam detection. Consider that from now on you'll have to do extensive self-research to be able to successfully complete the assignments.

Suggested reading
postconf(5) - Postfix Configuration Parameters
procmailrc(5) - Flags for procmail recipes
GTUBE - Testing spam filters
spamd - Spamassassin daemon doc
### 1. Preparation
During this assignment you will need two hosts (lab1 and lab2). Stop any daemons that might be listening on the default SMTP port.

#### 1.1 Add the IPv4 addresses and aliases of lab1 and lab2 on both computers to the /etc/hosts file.
See Vagrantfile.

### 2. Installing software and Configuring postfix and exim4, Verify that the following packages are installed:

lab1: postfix, procmail, spamassassin

lab2: exim4

Installing mailutils on lab1 can help with handling incoming mail. Then, you should configure postfix to deliver mail from lab2 to lab1.

Edit main configuration file for postfix (main.cf, postconf(5)) on lab1. You must change, at least, the following fields:

● myhostname (from /etc/hosts)

● mydestination

● mynetworks (localhost and virtual machines IP block)

Disable ETRN and VRFY commands. Remember to reload postfix service /etc/init.d/postfix every time you edit main.cf. `sudo postfix reload`

#### 2.1 Configure the postfix configuration file main.cf to fill the requirements above.

See lab1.sh

#### 2.2 What is purpose of the main.cf setting "mydestination"?
The "mydestination" setting in the main.cf configuration file of postfix is used to specify the domains and hosts that postfix should consider to be "local" and should handle mail for. This setting typically includes the hostname of the machine running postfix, as well as any local domain names that the machine should be responsible for handling mail for.

When postfix receives a message, it first checks the "mydestination" setting to determine if the message is intended for a local domain or host. If the message is for a local domain or host, postfix will handle the message locally, such as delivering it to a mailbox on the machine or forwarding it to another local machine. If the message is not for a local domain or host, postfix will forward the message to another mail server for delivery.

This allows for a separation of responsibilities for different domains and hosts, and helps to ensure that messages intended for local delivery are handled quickly and efficiently, while messages intended for external delivery are forwarded to the appropriate external mail servers.

#### 2.3 Why is it a really bad idea to set mynetworks broader than necessary (e.g. to 0.0.0.0/0)?

Setting the "mynetworks" configuration option in postfix to a broad range such as 0.0.0.0/0 (which would include all IP addresses) is a bad idea because it would allow any machine on the Internet to send mail through the postfix server, without any restriction. This could make the server an open relay, which would allow spammers and other malicious actors to use the server to send large amounts of unsolicited mail. This could lead to the server's IP address being blacklisted by various spam-blocking organizations, which would make it difficult for legitimate mail sent from the server to be delivered.

Additionally, allowing any machine to send mail through the server also increases the risk of the server being compromised by attackers. An attacker could use the open relay to send spam or malicious messages, which could damage the server's reputation and could also be used to distribute malware or phishing messages.

By limiting the "mynetworks" option to only include IP addresses and networks that are trusted and controlled by the organization, it reduces the risk of the server being used as an open relay and also decrease the risk of the server being used to distribute spam or malicious messages.

#### 2.4 What is the idea behind the ETRN and VRFY verbs? How can a malicious party misuse the commands?

The ETRN and VRFY verbs are SMTP (Simple Mail Transfer Protocol) commands that are used to manage email delivery and address verification, respectively.

The ETRN command is used to initiate a mail transfer from a remote mail server to a local mail server. It allows a remote server to request that a local server start sending mail that is queued for delivery to the remote server. This can be useful for situations where the remote server is offline for a period of time and needs to catch up on mail deliveries when it comes back online.

The VRFY command is used to verify that a specific email address exists on a server. It allows a client to send an email address to a server and receive a response indicating whether the address is valid or not. This can be useful for applications that need to validate email addresses before sending mail to them, or for troubleshooting email delivery issues.

However, both ETRN and VRFY commands can be misused by malicious parties to gain information about the email addresses that exist on a server. By sending VRFY commands to a server, an attacker can obtain a list of valid email addresses, which can then be used for spamming or phishing attacks. ETRN can be misused by malicious parties to force a server to start sending mail that it has queued for delivery, this could be used for spamming or phishing attacks as well.

For this reason, most modern mail servers disable the VRFY and ETRN commands by default, or allow them only for specific IP addresses or networks.

#### 2.5 Configure exim4 on lab2 to handle local emails and send all the rest to lab1. After you have configured postfix and exim4 you should be able to send mail from lab2 to lab1, but not vice versa. Use the standard debian package reconfiguration tool dpkg-reconfigure(8) to configure exim4.

Run:
```bash
sudo dpkg-reconfigure exim4-config
```


### 3. Sending email
Send a message from lab2 to <user>@lab1 using mail(1). Replace the <user> with your username. Read the message on lab1. See also email message headers. See incoming message information from /var/log/mail.log using tail(1).

#### 3.1 Explain shortly the incoming mail log messages

```bash
echo "My message" | mail -s subject vagrant@lab1
sudo tail /var/log/mail.log
```

```log
Sep 28 11:53:01 lab1 postfix/smtpd[1234]: connect from lab2.example.com[192.168.1.2]
Sep 28 11:53:02 lab1 postfix/smtpd[1234]: CF112345678: client=lab2.example.com[192.168.1.2], sasl_method=PLAIN, sasl_username=user@example.com
Sep 28 11:53:02 lab1 postfix/cleanup[1235]: CF112345678: message-id=<abcdef1234567890@lab2.example.com>
Sep 28 11:53:03 lab1 postfix/qmgr[1236]: CF112345678: from=<user@example.com>, size=834, nrcpt=1 (queue active)
Sep 28 11:53:03 lab1 postfix/local[1237]: CF112345678: to=<user@lab1.example.com>, relay=local, delay=0.05, delays=0.03/0.01/0/0.01, dsn=2.0.0, status=sent (delivered to command: /usr/bin/procmail)
```

- The first line shows that a connection was made to the email server from the IP address 192.168.1.2, which is associated with the hostname lab2.example.com.
- The second line shows that the client (lab2.example.com) is using the PLAIN SASL method and the user who is sending the email is user@example.com.
- The third line shows that the email has a unique message-id of abcdef1234567890@lab2.example.com.
- The fourth line shows that the email is from user@example.com, has a size of 834 bytes, and is being sent to 1 recipient.
- The fifth line shows that the email has been delivered to the local email server, and is being processed by the procmail command. In this case, the email was successfully delivered, with a status of "sent" and a delivery status notification (DSN) of 2.0.0.

#### 3.2 Explain shortly the email headers. At what point is each header added?

The headers contain information about the message, such as the sender, recipient, subject, date, and other details. The body contains the actual content of the message.

Email headers are added to a message at different points in the email delivery process. Here are a few examples:

- The From header is added when the email is composed by the sender.
- The To header is added when the email is addressed to the recipient.
- The Subject header is added when the email is given a subject.
- The Received header is added by each mail server that handles the message. This header contains information about the server and the time it received the message.
The Message-ID header is added when the message is first composed, it's unique identifier for the message
- The Date header is added when the email is sent.
- Some headers are added by the client software or the email server software, such as the User-Agent header, which identifies the software used to compose and send the email, or the MIME-Version header, which specifies the version of the MIME standard used in the message.

### 4. Configuring procmail and spamassassin
Procmail is configured by writing instruction sets caller recipes to a configuration file procmailrc(5). Edit (create if necessary) /etc/procmailrc and begin by piping your arriving emails into spamassassin with the following recipe:

:0fw
| /usr/bin/spamassassin

In postfix main.cf, you have to enable procmail with mailbox_command line:

```bash
/usr/bin/procmail -a "$USER"
```

Remember to reload postfix configuration after editing it.

You may need to start the spamassassin daemon after flipping the enabling bit in the configuration file /etc/default/spamassassin.

Send an email message from lab2 to <user>@lab1. Read the message on lab1. See email headers. If you do not see spamassassin headers there is something wrong, go back to previous step and see /var/log/mail.log.

Write additional procmail recipes to:

●     Automatically filter spam messages to a different folder.

●     Add a filter for your user to automatically save a copy of a message with header [cs-e4160] in the subject field to a different folder.

●     Forward a copy of the message with the same [cs-e4160] header to testuser1@lab1 (create user if necessary).

  Hint: You can use file .procmailrc in user's home directory for user-specific rules.

#### 4.1 How can you automatically filter spam messages to a different folder using procmail? Demonstrate by sending a message that gets flagged as spam.

This recipe checks the X-Spam-Status header in the email, and if it contains the word "Yes", the email is delivered to the spam/ folder. This is determined by spamassassin, the spam filter. This can be done by sending a message with spam content and see if it gets flagged as spam, and delivered to the spam folder.

#### 4.2 Demonstrate the filter rules created for messages with [cs-e4160] in the subject field by sending a message from lab2 to <user>@lab1 using the header.

This recipe checks the Subject header in the email, and if it contains the string "[cs-e4160]", the email is delivered to the cs-e4160/ folder. This can be done by sending a message with [cs-e4160] in the subject field and see if it gets delivered to the folder cs-e4160.

#### 4.3 Explain briefly the additional email headers (compared to step 4.2).

After creating additional procmail recipes, when an email is received that matches the conditions specified in the recipe, procmail will add a few additional headers to the email. For example, when an email is flagged as spam by spamassassin and delivered to the spam/ folder, procmail will add a header X-Spam-Status: Yes to the email. Similarly, when an email with [cs-e4160] in the subject field is delivered to the cs-e4160/ folder, procmail will add a header X-Procmail-To: cs-e4160/ to the email. These headers are added by procmail and can be used to identify the emails that have been processed by procmail and the actions that have been taken on them.

### 5. E-mail servers and DNS
#### 5.1 What information is stored in MX records in the DNS system?

MX records in the DNS system store information about the mail servers responsible for accepting email messages for a particular domain. Specifically, MX records contain the hostname and priority of a mail server. The priority is used to determine the order in which mail servers should be contacted if multiple servers are listed for a domain. When a client wants to send an email to a particular domain, it looks up the MX records for that domain and uses them to determine which server(s) to connect to in order to deliver the message.

#### 5.2 Explain briefly two ways to make redundant email servers using multiple email servers and the DNS system. Name at least two reasons why you would have multiple email servers for a single domain?

Hint: Using multiple DNS servers is not the correct answer!

One way to make redundant email servers using multiple email servers and the DNS system is to have multiple MX records for a domain, each with a different priority. This allows for failover in case the primary mail server is unavailable. For example, if the primary mail server has a priority of 10, the secondary mail server can have a priority of 20. This way, if the primary mail server is down, the client will attempt to connect to the secondary mail server.

Another way to make redundant email servers is by using a load balancer. The load balancer will distribute the incoming email traffic among multiple email servers.

Reasons for having multiple email servers for a single domain include:

- Redundancy and failover: By having multiple servers, you can ensure that email service is not interrupted in case one of the servers goes down.
- Scalability: As the number of email users or the volume of email traffic increases, it may be necessary to distribute the load among multiple servers in order to maintain performance and avoid bottlenecks.
- Geographical distribution: To provide faster service to users in different regions, you may want to set up multiple email servers in different locations and use DNS to direct clients to the nearest server.
- Security: By having multiple servers, you can implement different security measures to mitigate different types of threats or vulnerabilities.
