#!/bin/bash

echo "Updates werden installiert"
sudo apt update && sudo apt upgrades -y && sudo apt autoremove -y

echo "Docker werden installiert?"
apt install docker.io docker-compose

echo "Zusatzpakete werden installiert"
apt install wget unzip git

echo "Ordner erstellen"
mkdir /invoiceninja
cd /invoiceninja

echo "Git Repo clonen"
git clone https://github.com/invoiceninja/dockerfiles.git
cd dockerfiles

