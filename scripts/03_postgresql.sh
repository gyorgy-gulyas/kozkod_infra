#!/bin/bash
# PostgreSQL telepítése és DB/user létrehozása
# Futtatás: bash scripts/03_postgresql.sh

set -e
source "$(dirname "$0")/config/vars.sh"

echo "==> [1/3] PostgreSQL telepítése"
apt-get install -y -qq postgresql postgresql-contrib

echo "==> [2/3] DB és user létrehozása"
# Jelszó generálása, ha még nincs
if [ ! -f /root/.kozkod_db_password ]; then
    DB_PASS=$(openssl rand -base64 24)
    echo "$DB_PASS" > /root/.kozkod_db_password
    chmod 600 /root/.kozkod_db_password
else
    DB_PASS=$(cat /root/.kozkod_db_password)
fi

sudo -u postgres psql <<SQL
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$DB_USER') THEN
        CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';
    END IF;
END
\$\$;

SELECT 'CREATE DATABASE $DB_NAME OWNER $DB_USER'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$DB_NAME')\gexec
SQL

echo ""
echo "KÉSZ. PostgreSQL beállítva."
echo "DB jelszó: /root/.kozkod_db_password"
echo "Következő: bash scripts/04_gitlab.sh"
