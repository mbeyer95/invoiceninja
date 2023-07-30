#!/bin/bash

echo "Updates werden installiert"
#sudo apt update
#sudo apt upgrade -y
#sudo apt autoremove -y

echo "Docker werden installiert?"
apt install docker.io docker-compose -y

echo "Zusatzpakete werden installiert"
apt install wget unzip git -y

echo "Git Repo clonen"
git clone https://github.com/invoiceninja/dockerfiles.git
cd dockerfiles

# Schlüssel generieren
echo "APP_Key generieren"
key=$(docker run --rm -it invoiceninja/invoiceninja php artisan key:generate --show)

# Schlüssel in die Datei einfügen
sed -i "s|APP_KEY=<insert your generated key in here>|APP_KEY=$key|" ~/invoiceninja/dockerfiles/env


echo "Ordner Berechtigung anpassen"
chmod 755 docker/app/public
sudo chown -R 1500:1500 docker/app

nano env

 