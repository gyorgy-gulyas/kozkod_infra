#!/bin/bash
# Nginx + Certbot SSL telepítése
# Futtatás: bash scripts/02_nginx.sh

set -e
source "$(dirname "$0")/config/vars.sh"

echo "==> [1/4] Nginx telepítése"
apt-get install -y -qq nginx

echo "==> [2/4] Certbot telepítése"
apt-get install -y -qq certbot python3-certbot-nginx

echo "==> [3/4] Nginx alap konfig"
cat > /etc/nginx/sites-available/kozkod <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN $PLATFORM_DOMAIN $GITLAB_DOMAIN;
    return 301 https://\$host\$request_uri;
}
EOF
ln -sf /etc/nginx/sites-available/kozkod /etc/nginx/sites-enabled/kozkod
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx

echo "==> [4/4] SSL tanúsítványok"
certbot --nginx \
    -d "$DOMAIN" \
    -d "www.$DOMAIN" \
    -d "$PLATFORM_DOMAIN" \
    --email "$SSL_EMAIL" \
    --agree-tos \
    --non-interactive

echo ""
echo "KÉSZ. Nginx + SSL beállítva."
echo "Következő: bash scripts/03_postgresql.sh"
