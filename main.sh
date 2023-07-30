#!/bin/bash

echo "Updates werden installiert"
#sudo apt update
#sudo apt upgrade -y
#sudo apt autoremove -y

echo "Docker Pakete werden installiert"
apt install docker.io docker-compose -y

echo "Zusatzpakete werden installiert"
apt install wget unzip git -y

echo "Git Repo clonen"
git clone https://github.com/invoiceninja/dockerfiles.git
cd dockerfiles

# APP_KEY generieren und in die Datei einfügen
echo "APP_Key konfigurieren"
docker run --rm -it invoiceninja/invoiceninja php artisan key:generate --show > appkey.txt
key=$(cat appkey.txt)
sed -i "s|APP_KEY=<insert your generated key in here>|APP_KEY=$key|" ~/invoiceninja/dockerfiles/env

# IP-Adresse abrufen und in ENV-Datei einfügen
echo "Webadresse konfigurieren"
ip=$(hostname -I | cut -d' ' -f1)
sed -i "s|APP_URL=http://in.localhost:8003|APP_URL=http://$ip:8003|" ~/invoiceninja/dockerfiles/env

# PDF erzeugen auf TRUE
echo "PDF Generator einstellen"
sed -i "s|PHANTOMJS_PDF_GENERATION=false|PHANTOMJS_PDF_GENERATION=true|" ~/invoiceninja/dockerfiles/env

echo "Ordner Berechtigung anpassen"
chmod 755 docker/app/public
sudo chown -R 1500:1500 docker/app

nano env

 