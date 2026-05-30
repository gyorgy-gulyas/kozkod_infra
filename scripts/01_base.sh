#!/bin/bash
# Szerver alap konfiguráció
# Futtatás: bash scripts/01_base.sh

set -e
source "$(dirname "$0")/config/vars.sh"

echo "==> [1/5] Rendszer frissítése"
apt-get update -qq && apt-get upgrade -y -qq

echo "==> [2/5] Alap csomagok"
apt-get install -y -qq \
    curl wget git vim htop \
    build-essential software-properties-common \
    ca-certificates gnupg lsb-release \
    unattended-upgrades apt-listchanges \
    fail2ban ufw

echo "==> [3/5] SSH port beállítása (2222)"
sed -i 's/^#Port 22/Port 2222/' /etc/ssh/sshd_config
sed -i 's/^Port 22/Port 2222/' /etc/ssh/sshd_config
grep -q "^Port 2222" /etc/ssh/sshd_config || echo "Port 2222" >> /etc/ssh/sshd_config
systemctl restart ssh

echo "==> [4/5] Automatikus biztonsági frissítések"
echo 'Unattended-Upgrade::Automatic-Reboot "false";' > /etc/apt/apt.conf.d/99kozkod

echo "==> [5/5] Swap (4GB) — ha még nincs"
if [ ! -f /swapfile ]; then
    fallocate -l 4G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    echo "Swap létrehozva."
else
    echo "Swap már létezik, kihagyva."
fi

echo ""
echo "KÉSZ. Fontos: az SSH port most 2222."
echo "Következő: bash scripts/02_nginx.sh"
