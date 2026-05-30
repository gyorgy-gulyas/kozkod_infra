#!/bin/bash
# Django platform telepítése (Gunicorn + Nginx)
# Futtatás: bash scripts/05_platform.sh

set -e
source "$(dirname "$0")/config/vars.sh"

echo "==> [1/5] Python és pip"
apt-get install -y -qq python3 python3-pip python3-venv

echo "==> [2/5] Platform repo klónozása"
if [ -d "$PLATFORM_DIR" ]; then
    cd "$PLATFORM_DIR" && git pull
else
    git clone "$REPO_PLATFORM" "$PLATFORM_DIR"
fi

echo "==> [3/5] Python venv és csomagok"
python3 -m venv "$PLATFORM_DIR/backend/.venv"
"$PLATFORM_DIR/backend/.venv/bin/pip" install --quiet -r "$PLATFORM_DIR/backend/requirements.txt"
"$PLATFORM_DIR/backend/.venv/bin/pip" install --quiet gunicorn

echo "==> [4/5] .env fájl létrehozása (ha nincs)"
if [ ! -f "$PLATFORM_DIR/backend/.env" ]; then
    DB_PASS=$(cat /root/.kozkod_db_password)
    SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(50))")
    cat > "$PLATFORM_DIR/backend/.env" <<EOF
SECRET_KEY=$SECRET_KEY
DEBUG=False
ALLOWED_HOSTS=$PLATFORM_DOMAIN,localhost
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASS
DB_HOST=localhost
DB_PORT=5432
CORS_ALLOWED_ORIGINS=https://$PLATFORM_DOMAIN
EOF
    chmod 600 "$PLATFORM_DIR/backend/.env"
fi

echo "==> [5/5] Systemd service + Nginx konfig"
cat > /etc/systemd/system/kozkod-platform.service <<EOF
[Unit]
Description=KözKód Platform Gunicorn
After=network.target

[Service]
User=www-data
WorkingDirectory=$PLATFORM_DIR/backend
ExecStart=$PLATFORM_DIR/backend/.venv/bin/gunicorn config.wsgi:application --bind 127.0.0.1:8001 --workers 3
Restart=always
EnvironmentFile=$PLATFORM_DIR/backend/.env

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/nginx/sites-available/platform <<EOF
server {
    listen 443 ssl;
    server_name $PLATFORM_DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$PLATFORM_DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$PLATFORM_DOMAIN/privkey.pem;

    location /api/ {
        proxy_pass http://127.0.0.1:8001;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    location / {
        root $PLATFORM_DIR/frontend/dist;
        try_files \$uri \$uri/ /index.html;
    }
}
EOF
ln -sf /etc/nginx/sites-available/platform /etc/nginx/sites-enabled/platform

systemctl daemon-reload
systemctl enable kozkod-platform
systemctl start kozkod-platform
nginx -t && systemctl reload nginx

echo ""
echo "KÉSZ. Platform fut: https://$PLATFORM_DOMAIN"
