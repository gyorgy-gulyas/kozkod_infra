#!/bin/bash
# Egyszeri futtatás a szerveren — klónozza a repót és előkészít mindent
# Használat: bash bootstrap.sh

set -e

REPO="https://github.com/gyorgy-gulyas/kozkod_infra.git"
INFRA_DIR="/opt/kozkod_infra"

echo "==> Csomagok frissítése"
apt-get update -qq

echo "==> Git telepítése"
apt-get install -y -qq git

echo "==> Repo klónozása: $INFRA_DIR"
if [ -d "$INFRA_DIR" ]; then
    cd "$INFRA_DIR" && git pull
else
    git clone "$REPO" "$INFRA_DIR"
fi

echo "==> Scriptek futtatható jelölése"
chmod +x "$INFRA_DIR/scripts/"*.sh

echo ""
echo "OK. Következő lépés:"
echo "  cd $INFRA_DIR && bash scripts/01_base.sh"
