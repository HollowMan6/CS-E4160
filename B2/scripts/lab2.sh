#!/usr/bin/env bash

cat >> ~/.ssh/authorized_keys <<EOL
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLS+lOidBwey5z6gSoHuio4Ik3iV4t/QcgSlopXW5ym songlin.jiang@aalto.fi
EOL

sudo apt install -y apache2

sudo openssl req -x509 -batch -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/lab2.key -out /etc/ssl/certs/lab2.pem
# https://www.arubacloud.com/tutorial/how-to-enable-https-protocol-with-apache-2-on-ubuntu-20-04.aspx
sudo tee -a /etc/apache2/conf-available/ssl-params.conf <<EOL
SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH    
SSLProtocol All -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
SSLHonorCipherOrder On
Header always set X-Frame-Options DENY
Header always set X-Content-Type-Options nosniff
# Requires Apache >= 2.4
SSLCompression off
SSLUseStapling on
SSLStaplingCache "shmcb:logs/stapling-cache(150000)"
# Requires Apache >= 2.4.11
SSLSessionTickets Off
EOL

sudo sed -i 's/ssl-cert-snakeoil/lab2/g' /etc/apache2/sites-available/default-ssl.conf
sudo a2enmod ssl
sudo a2enmod headers
sudo a2enconf ssl-params
sudo a2ensite default-ssl
sudo apache2ctl configtest
sudo systemctl restart apache2

mkdir ~/public_html
cat > ~/public_html/index.html <<EOL
<html><head></head><body><h1>Hello World!</h1></body></html>
EOL
mkdir ~/public_html/secure_secrets
cat > ~/public_html/secure_secrets/index.html <<EOL
<html><head></head><body><h1>Secure Secrets</h1></body></html>
EOL
cat > ~/public_html/secure_secrets/.htaccess <<EOL
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
EOL

chmod 755 ~
sudo a2enmod userdir
sudo a2enmod rewrite
sudo sed -i 's/AllowOverride/AllowOverride Options/g' /etc/apache2/mods-available/userdir.conf
sudo systemctl restart apache2

sudo apt install -y lynx unzip mariadb-server mariadb-client php php-mysqli php-gd libapache2-mod-php
wget https://github.com/digininja/DVWA/archive/master.zip
unzip master.zip
sudo mv DVWA-master/* /var/www/html/
cd /var/www/html
sudo cp config/config.inc.php.dist config/config.inc.php
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html/dvwa
