#!/bin/bash

# Updates installieren
echo "Updates werden installiert"
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

# Docker Pakete installieren
echo "Docker Pakete werden installiert"
apt install docker.io docker-compose -y

# wget, unzip und git installieren
echo "Zusatzpakete werden installiert"
apt install wget unzip git -y

# Invoice Ninja Dockerfiles herunterladen aus GIT
echo "Invoice Ninja Installations-Daten herunterladen"
git clone https://github.com/invoiceninja/dockerfiles.git
cd dockerfiles

# Ordnerberechtigungen anpassen
echo "Ordnerberechtigungen anpassen"
chmod 755 docker/app/public
sudo chown -R 1500:1500 docker/app

# APP_KEY generieren und in ENV-Datei einfügen
echo "APP_Key konfigurieren"
docker run --rm -it invoiceninja/invoiceninja php artisan key:generate --show > appkey.txt
key=$(cat appkey.txt)
echo "APP_Key in ENV-Datei einfügen"
sed -i "s|APP_KEY=<insert your generated key in here>|APP_KEY=$key|" ~/invoiceninja/dockerfiles/env

# IP-Adresse abrufen und in ENV-Datei einfügen
echo "Webadresse konfigurieren"
ip=$(hostname -I | cut -d' ' -f1)
sed -i "s|APP_URL=http://in.localhost:8003|APP_URL=http://$ip:8003|" ~/invoiceninja/dockerfiles/env

# PDF erzeugen auf TRUE
echo "Phantomjs PDF Generator anstellen"
sed -i "s|PHANTOMJS_PDF_GENERATION=false|PHANTOMJS_PDF_GENERATION=true|" ~/invoiceninja/dockerfiles/env

nano env

 