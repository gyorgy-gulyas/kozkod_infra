# KözKód Infra

A **KözKód** kiszolgáló-infrastruktúrája **Ansible** playbookokkal. A teljes környezet
kódból, megismételhetően áll elő — kézi szerverbeállítások helyett **minden változtatás
a repón keresztül megy**.

## Mit tartalmaz

| Playbook | Cél |
|---|---|
| `01_base.yml` | SSH, csomagok, swap, alaphangolás |
| `02_nginx.yml` | Nginx + Certbot (TLS) a `platform.kozkod.hu`-hoz |
| `03_postgresql.yml` | PostgreSQL adatbázis a platformhoz |
| `04_gitlab.yml` | GitLab CE a `gitlab.kozkod.hu`-n (OmniAuth SSO, hozzáférés-korlátozás, ApplicationSetting) |
| `05_platform.yml` | A Django alkalmazás telepítése Gunicorn + systemd alatt |

## Struktúra

```
ansible/
├── group_vars/all.yml         # közös változók
├── playbooks/                 # 01..05 playbookok
└── templates/                 # Nginx és systemd sablonok, GitLab szkriptek
```

## Működés

Az Ansible a **szerveren, helyben** fut (`hosts: localhost`, `connection: local`) —
a lokális géphez nem kell Ansible. A változtatások menete:

1. Módosítás a playbookban/sablonban, majd `git push`.
2. A szerveren:

```bash
cd /opt/kozkod_infra && git pull origin main
ansible-playbook ansible/playbooks/<XX>.yml
```

## Környezet

Hetzner dedikált szerver · Ubuntu 24.04 LTS · Nginx · PostgreSQL · GitLab CE ·
Django + Gunicorn (systemd).

> A GitLab CE és a platform ugyanazon a gépen fut: a saját Nginx csak a
> `platform.kozkod.hu`-t szolgálja ki, a `gitlab.kozkod.hu`-t a GitLab beépített
> rétege; a same-host webhookokhoz az `allow_local_requests_from_web_hooks_and_services`
> engedélyezve van.

## Kapcsolódó repók

- **kozkod_platform** — a platform alkalmazása.
- **kozkod_webpage** — nyilvános marketing-weboldal.

## Licenc

EUPL 1.2.
