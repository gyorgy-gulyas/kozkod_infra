#!/bin/bash
# GitLab CE telepítése
# Futtatás: bash scripts/04_gitlab.sh

set -e
source "$(dirname "$0")/config/vars.sh"

echo "==> [1/3] GitLab CE repo hozzáadása"
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash

echo "==> [2/3] GitLab CE telepítése ($GITLAB_DOMAIN)"
EXTERNAL_URL="https://$GITLAB_DOMAIN" apt-get install -y gitlab-ce

echo "==> [3/3] Nginx konfig GitLabhoz"
cat > /etc/nginx/sites-available/gitlab <<EOF
server {
    listen 80;
    server_name $GITLAB_DOMAIN;
    return 301 https://\$host\$request_uri;
}
EOF
# GitLab saját Nginx-et használ, ezt csak proxy-ként állítjuk be ha szükséges

echo ""
echo "KÉSZ. GitLab CE telepítve."
echo "Első belépés: https://$GITLAB_DOMAIN"
echo "Root jelszó: cat /etc/gitlab/initial_root_password"
echo "Következő: bash scripts/05_platform.sh"
