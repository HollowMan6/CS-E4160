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

echo "This is a test" | mail -s "Test Message" -v vagrant@lab1

```log
Jan 30 19:23:22 lab1 postfix/smtpd[5877]: connect from lab2[192.168.1.3]
Jan 30 19:23:22 lab1 postfix/smtpd[5877]: discarding EHLO keywords: ETRN
Jan 30 19:23:22 lab1 postfix/smtpd[5877]: warning: TLS library problem: error:0A000412:SSL routines::sslv3 alert bad certificate:../ssl/record/rec_layer_s3.c:1584:SSL alert number 42:
Jan 30 19:23:22 lab1 postfix/smtpd[5877]: lost connection after STARTTLS from lab2[192.168.1.3]
Jan 30 19:23:22 lab1 postfix/smtpd[5877]: disconnect from lab2[192.168.1.3] ehlo=1 starttls=1 commands=2
Jan 30 19:23:22 lab1 postfix/smtpd[5877]: connect from lab2[192.168.1.3]
Jan 30 19:23:22 lab1 postfix/smtpd[5877]: discarding EHLO keywords: ETRN
Jan 30 19:23:22 lab1 postfix/smtpd[5877]: 0EEFC3FEB5: client=lab2[192.168.1.3]
Jan 30 19:23:22 lab1 postfix/cleanup[5880]: 0EEFC3FEB5: message-id=<E1pMZkQ-00022k-0y@lab2>
Jan 30 19:23:22 lab1 postfix/qmgr[5673]: 0EEFC3FEB5: from=<vagrant@lab2>, size=562, nrcpt=1 (queue active)
Jan 30 19:23:22 lab1 postfix/smtpd[5877]: disconnect from lab2[192.168.1.3] ehlo=1 mail=1 rcpt=1 bdat=1 quit=1 commands=5
Jan 30 19:23:22 lab1 postfix/local[5881]: 0EEFC3FEB5: to=<vagrant@lab1>, relay=local, delay=0.64, delays=0/0/0/0.63, dsn=2.0.0, status=sent (delivered to command: procmail -a "$EXTENSION")
Jan 30 19:23:22 lab1 postfix/qmgr[5673]: 0EEFC3FEB5: removed
```

#### 3.1 Explain shortly the incoming mail log messages

- The line 1,6 shows that a connection was made to the email server from the IP address 192.168.1.3, which is associated with the hostname lab2.
- The line 2,7 shows that the ENTR command was discarded, because it is configured to be not allowed by the server.
- For line 3-5, as we have self-signed certificate for the domain lab2, the server is not able to verify the certificate and the connection is closed.
- The line 8 shows that the client (lab2) connects to the server successfully without the STARTTLS command.
- The line 9 shows that the email has a unique message-id of E1pMZkQ-00022k-0y@lab2.
- The line 10 shows that the email is from vagrant@lab2, has a size of 562 bytes, and is being sent to 1 recipient.
- The line 12 shows that the email has been delivered to the local email server, and is being processed by the procmail command. In this case, the email was successfully delivered, with a status of "sent" and a delivery status notification (DSN) of 2.0.0.

#### 3.2 Explain shortly the email headers. At what point is each header added?
```bash
vagrant@lab1:~$ mail
"/var/mail/vagrant": 1 message 1 new
>N   1 vagrant@lab2       Mon Jan 30 19:23  26/828   Test Message
? 1
Return-Path: <vagrant@lab2>
Delivered-To: vagrant@lab1
Received: from lab2 (lab2 [192.168.1.3])
	by lab1 (Postfix) with ESMTP id 0EEFC3FEB5
	for <vagrant@lab1>; Mon, 30 Jan 2023 19:23:22 +0000 (UTC)
Received: from vagrant by lab2 with local (Exim 4.95)
	(envelope-from <vagrant@lab2>)
	id 1pMZkQ-00022k-0y
	for vagrant@lab1;
	Mon, 30 Jan 2023 19:23:22 +0000
To: vagrant@lab1
Subject: Test Message
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Message-Id: <E1pMZkQ-00022k-0y@lab2>
From: vagrant@lab2
Date: Mon, 30 Jan 2023 19:23:22 +0000

This is a test

? 
```

The headers contain information about the message, such as the sender, recipient, subject, date, and other details. The body contains the actual content of the message.

Email headers are added to a message at different points in the email delivery process. Here are a few examples:

- The From header is added when the email is composed by the sender.
- The To header is added when the email is addressed to the recipient.
- The Subject header is added when the email is given a subject.
- The Received header is added by each mail server that handles the message. This header contains information about the server and the time it received the message.
- The Message-ID header is added when the message is first composed, it's unique identifier for the message.
- The Date header is added when the email is sent.
- Some headers are added by the client software or the email server software, such as the MIME-Version header, which specifies the version of the MIME standard used in the message.
- The Content-Type header specifies the type of content in the message, such as text, image, or audio.
- The Content-Transfer-Encoding header specifies the encoding used to encode the message body.
- The Return-Path header specifies the address to which undeliverable messages should be sent.

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

https://opensource.apple.com/source/SpamAssassin/SpamAssassin-124.1/SpamAssassin/sample-spam.txt.auto.html

```bash
mail -s "Test spam mail (GTUBE)" -v vagrant@lab1

This is the GTUBE, the
	Generic
	Test for
	Unsolicited
	Bulk
	Email

If your spam filter supports it, the GTUBE provides a test by which you
can verify that the filter is installed correctly and is detecting incoming
spam. You can send yourself a test mail containing the following string of
characters (in upper case and with no white spaces and line breaks):

XJS*C4JDBQADN1.NSBN3*2IDNEN*GTUBE-STANDARD-ANTI-UBE-TEST-EMAIL*C.34X

You should send this test mail from an account outside of your network.

```

CTRL+D to send the email.

#### 4.2 Demonstrate the filter rules created for messages with [cs-e4160] in the subject field by sending a message from lab2 to <user>@lab1 using the header.

This recipe checks the Subject header in the email, and if it contains the string "[cs-e4160]", the email is delivered to the cs-e4160/ folder. This can be done by sending a message with [cs-e4160] in the subject field and see if it gets delivered to the folder cs-e4160.

```bash
echo "This is a test" | mail -s "[cs-e4160] hi" -v vagrant@lab1
```

```bash
cd ~/cs-e4160/new
vagrant@lab1:~/cs-e4160/new$ cat 1675108483.5929_0.lab1 
Return-Path: <vagrant@lab2>
X-Spam-Checker-Version: SpamAssassin 3.4.6 (2021-04-09) on lab1
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=5.0 tests=ALL_TRUSTED,TO_MALFORMED
	autolearn=no autolearn_force=no version=3.4.6
X-Original-To: vagrant@lab1
Delivered-To: vagrant@lab1
Received: from lab2 (lab2 [192.168.1.3])
	by lab1 (Postfix) with ESMTP id 70DE83FEB5
	for <vagrant@lab1>; Mon, 30 Jan 2023 19:54:42 +0000 (UTC)
Received: from vagrant by lab2 with local (Exim 4.95)
	(envelope-from <vagrant@lab2>)
	id 1pMaEk-00023I-BP
	for vagrant@lab1;
	Mon, 30 Jan 2023 19:54:42 +0000
To: vagrant@lab1
Subject: [cs-e4160] hi
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Message-Id: <E1pMaEk-00023I-BP@lab2>
From: vagrant@lab2
Date: Mon, 30 Jan 2023 19:54:42 +0000

This is a test
```

#### 4.3 Explain briefly the additional email headers (compared to step 4.2).

- X-Spam-Checker-Version is the version of the spam filter used.
- X-Spam-Status is the result of the spam filter. It contains the score, the required score, the tests used, and the version of the spam filter.
- X-Original-To is the original recipient of the email before procmail handles.

### 5. E-mail servers and DNS
#### 5.1 What information is stored in MX records in the DNS system?

MX records in the DNS system store information about the mail servers responsible for accepting email messages for a particular domain. Specifically, MX records contain the hostname and priority of a mail server. The priority is used to determine the order in which mail servers should be contacted if multiple servers are listed for a domain. When a client wants to send an email to a particular domain, it looks up the MX records for that domain and uses them to determine which server(s) to connect to in order to deliver the message.

#### 5.2 Explain briefly two ways to make redundant email servers using multiple email servers and the DNS system. Name at least two reasons why you would have multiple email servers for a single domain? Hint: Using multiple DNS servers is not the correct answer!

One way to make redundant email servers using multiple email servers and the DNS system is to have multiple MX records for a domain, each with a different priority. This allows for failover in case the primary mail server is unavailable. For example, if the primary mail server has a priority of 10, the secondary mail server can have a priority of 20. This way, if the primary mail server is down, the client will attempt to connect to the secondary mail server.

Another way to make redundant email servers is by using a load balancer. The load balancer will distribute the incoming email traffic among multiple email servers.

Reasons for having multiple email servers for a single domain include:

- Redundancy and failover: By having multiple servers, you can ensure that email service is not interrupted in case one of the servers goes down.
- Scalability: As the number of email users or the volume of email traffic increases, it may be necessary to distribute the load among multiple servers in order to maintain performance and avoid bottlenecks.
- Geographical distribution: To provide faster service to users in different regions, you may want to set up multiple email servers in different locations and use DNS to direct clients to the nearest server.
- Security: By having multiple servers, you can implement different security measures to mitigate different types of threats or vulnerabilities.
