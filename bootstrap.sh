#!/bin/bash
# Egyszeri futtatás a szerveren: Ansible + repo klónozás
# Használat: bash <(curl -sS https://raw.githubusercontent.com/gyorgy-gulyas/kozkod_infra/main/bootstrap.sh)

set -e

REPO="https://github.com/gyorgy-gulyas/kozkod_infra.git"
INFRA_DIR="/opt/kozkod_infra"

echo "==> Csomagok frissítése"
apt-get update -qq

echo "==> Ansible telepítése"
apt-get install -y -qq software-properties-common
apt-add-repository --yes --update ppa:ansible/ansible
apt-get install -y -qq ansible git

echo "==> Repo klónozása"
if [ -d "$INFRA_DIR" ]; then
    cd "$INFRA_DIR" && git pull
else
    git clone "$REPO" "$INFRA_DIR"
fi

echo ""
echo "KÉSZ. Következő lépés:"
echo "  cd $INFRA_DIR"
echo "  ansible-playbook ansible/playbooks/01_base.yml"
