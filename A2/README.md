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

1p


### 3. Sending email
Send a message from lab2 to <user>@lab1 using mail(1). Replace the <user> with your username. Read the message on lab1. See also email message headers. See incoming message information from /var/log/mail.log using tail(1).

3.1

Explain shortly the incoming mail log messages

2p

3.2

Explain shortly the email headers. At what point is each header added?

2p


4. Configuring procmail and spamassassin
Procmail is configured by writing instruction sets caller recipes to a configuration file procmailrc(5). Edit (create if necessary) /etc/procmailrc and begin by piping your arriving emails into spamassassin with the following recipe:

:0fw
| /usr/bin/spamassassin

In postfix main.cf, you have to enable procmail with mailbox_command line:

/usr/bin/procmail -a "$USER"

Remember to reload postfix configuration after editing it.

You may need to start the spamassassin daemon after flipping the enabling bit in the configuration file /etc/default/spamassassin.

Send an email message from lab2 to <user>@lab1. Read the message on lab1. See email headers. If you do not see spamassassin headers there is something wrong, go back to previous step and see /var/log/mail.log.

Write additional procmail recipes to:

●     Automatically filter spam messages to a different folder.

●     Add a filter for your user to automatically save a copy of a message with header [cs-e4160] in the subject field to a different folder.

●     Forward a copy of the message with the same [cs-e4160] header to testuser1@lab1 (create user if necessary).

  Hint: You can use file .procmailrc in user's home directory for user-specific rules.

4.1

How can you automatically filter spam messages to a different folder using procmail? Demonstrate by sending a message that gets flagged as spam.

2p

4.2

Demonstrate the filter rules created for messages with [cs-e4160] in the subject field by sending a message from lab2 to <user>@lab1 using the header.

2p

4.3

Explain briefly the additional email headers (compared to step 4.2).

1p


5. E-mail servers and DNS
5.1

What information is stored in MX records in the DNS system?

1p

5.2

Explain briefly two ways to make redundant email servers using multiple email servers and the DNS system. Name at least two reasons why you would have multiple email servers for a single domain?

Hint: Using multiple DNS servers is not the correct answer!

2p


6. Finishing your work
When finishing your work, please remember to backup files related to the  assignment and after your demo possibly reset the configuration changes that you did to the lab environment (Lab1, Lab2, Lab3) to start the next assignment with a clean slate.