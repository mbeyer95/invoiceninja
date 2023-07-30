#!/bin/bash

# Abfragen
read -p "Bitte geben Sie eine Login E-Mail an: " usermail
read -s -p "Bitte geben Sie ein Passwort für den Login ein: " userpw

read -p "Bitte geben Sie die Postausgangs E-Mail Adresse ein: " mailusername
read -s -p "Bitte geben Sie das Passwort ein: " mailpw
read -p "Bitte geben Sie den E-Mail Host ein: " mailhost
read -p "Bitte geben Sie SSL oder SMTP ein: " ssl
read -p "Bitte geben Sie einen den Postausgangsport ein: " mailport
read -p "Bitte geben Sie den Absendernamen ein: " mailfrom


# Updates installieren
echo "Updates werden installiert."
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

# Docker Pakete installieren
echo "Docker Pakete werden installiert."
apt install docker.io docker-compose -y

# wget, unzip und git installieren
echo "Zusatzpakete werden installiert."
apt install wget unzip git -y

# Invoice Ninja Dockerfiles herunterladen aus GIT
echo "Invoice Ninja Installations-Dateien werden heruntergeladen."
git clone https://github.com/invoiceninja/dockerfiles.git
cd dockerfiles

# Ordnerberechtigungen anpassen
echo "Ordnerberechtigungen weren angepasst."
chmod 755 docker/app/public
sudo chown -R 1500:1500 docker/app

# APP_KEY generieren und in ENV-Datei einfügen
echo "APP_Key wird konfiguriert."
#docker run --rm -it invoiceninja/invoiceninja php artisan key:generate --show > appkey.txt
#key=$(cat appkey.txt)
##echo "APP_Key in ENV-Datei einfügen"
#sed -i "s|APP_KEY=<insert your generated key in here>|APP_KEY=$key|" ~/invoiceninja/dockerfiles/env
# Generiere den Schlüssel und speichere ihn in einer Datei
docker run --rm -it invoiceninja/invoiceninja php artisan key:generate --show | sed 's/\x1b\[[0-9;]*m//g' > appkey.txt
appkey=$(cat ~/invoiceninja/dockerfiles/appkey.txt)
sed -i "s|APP_KEY=<insert your generated key in here>|APP_KEY=$appkey|" ~/invoiceninja/dockerfiles/env

# IP-Adresse abrufen und in ENV-Datei einfügen
echo "Webadresse konfigurieren"
ip=$(hostname -I | cut -d' ' -f1)
sed -i "s|APP_URL=http://in.localhost:8003|APP_URL=http://$ip:8003|" ~/invoiceninja/dockerfiles/env

# PDF erzeugen auf TRUE
echo "Phantomjs PDF Generator wird angestellt."
sed -i "s|PHANTOMJS_PDF_GENERATION=false|PHANTOMJS_PDF_GENERATION=true|" ~/invoiceninja/dockerfiles/env

# Datenbank Passwort generieren und in ENV-Datei einfügen
echo "Datenbankpasswort wird generiert."
DB_PASSWORD=$(openssl rand -base64 16)
sed -i "s|DB_PASSWORD=ninja|DB_PASSWORD=$DB_PASSWORD|" ~/invoiceninja/dockerfiles/env
sed -i "s|MYSQL_PASSWORD=ninja|MYSQL_PASSWORD=$DB_PASSWORD|" ~/invoiceninja/dockerfiles/env

# MYSQL Root Passwort generieren und einfügen
echo "MYSQL Root Passwort wird generiert."
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 16)
sed -i "s|MYSQL_ROOT_PASSWORD=ninjaAdm1nPassword|MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD|" ~/invoiceninja/dockerfiles/env

# Erste Logindaten konfigurieren
sed -i "s|IN_USER_EMAIL=|IN_USER_EMAIL=$usermail|" ~/invoiceninja/dockerfiles/env
sed -i "s|IN_PASSWORD=|IN_PASSWORD=$userpw|" ~/invoiceninja/dockerfiles/env

# E-Mail Postausgangs-Einstellungen konfigurieren.
sed -i "s|MAIL_MAILER=log|MAIL_MAILER=smtp|" ~/invoiceninja/dockerfiles/env
sed -i "s|MAIL_HOST=smtp.mailtrap.io|MAIL_HOST=$mailhost|" ~/invoiceninja/dockerfiles/env
sed -i "s|MAIL_PORT=2525|MAIL_PORT=$mailport|" ~/invoiceninja/dockerfiles/env
sed -i "s|MAIL_USERNAME=null|MAIL_USERNAME=$mailusername|" ~/invoiceninja/dockerfiles/env
sed -i "s|MAIL_PASSWORD=null|MAIL_PASSWORD=$mailpw|" ~/invoiceninja/dockerfiles/env
sed -i "s|MAIL_ENCRYPTION=null|MAIL_ENCRYPTION=$ssl|" ~/invoiceninja/dockerfiles/env
sed -i "s|MAIL_FROM_ADDRESS='user@example.com'|MAIL_FROM_ADDRESS=$mailusername|" ~/invoiceninja/dockerfiles/env
sed -i "s|MAIL_FROM_NAME='Self Hosted User'|MAIL_FROM_NAME=$mailfrom|" ~/invoiceninja/dockerfiles/env

nano env

 