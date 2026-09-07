---
description: Déployer TaxCollect sur un VPS avec Docker et Portainer
---

# Déploiement TaxCollect sur VPS (Portainer)

## Prérequis
- VPS avec Docker + Portainer installés
- Accès SSH au VPS
- Les fichiers du projet sur le VPS (git clone ou scp)

## Étapes

### 1. Préparer le fichier .env

```bash
cp .env.example .env
nano .env
```

Remplir avec des mots de passe forts :
- `DB_PASSWORD` — mot de passe PostgreSQL
- `LDAP_ADMIN_PASSWORD` — mot de passe LDAP
- `KEYCLOAK_ADMIN_PASSWORD` — mot de passe admin Keycloak
- `KEYCLOAK_ADMIN_CLIENT_SECRET` — secret client Keycloak

### 2. Option A — Déploiement via Portainer

1. Dans Portainer, aller dans **Stacks** > **Add stack**
2. Nom: `taxcollect`
3. Sélectionner **Web editor** et coller le contenu de `docker-compose.prod.yaml`
4. Dans **Environment variables**, ajouter les variables du fichier `.env`
   (ou activer "Use .env file" si Portainer le supporte)
5. Cliquer **Deploy the stack**

### 2. Option B — Déploiement via CLI (SSH)

```bash
cd /opt/taxcollect  # ou le chemin du projet
cp .env.example .env
# Éditer .env avec les bonnes valeurs
docker compose -f docker-compose.prod.yaml up -d --build
```

### 3. Vérifier le déploiement

```bash
# Conteneurs actifs
docker compose -f docker-compose.prod.yaml ps

# Logs backend
docker logs taxcollect-backend -f

# Logs frontend
docker logs taxcollect-frontend -f
```

### 4. Accès aux services

| Service | URL | Port |
|---------|-----|------|
| Frontend | http://VPS_IP:3000 | 3000 |
| Backend API | http://VPS_IP:9091 | 9091 |
| Keycloak | http://VPS_IP:8080 | 8080 |
| Prometheus | http://127.0.0.1:9095 | 9095 (local only) |
| phpLDAPadmin | http://127.0.0.1:6443 | 6443 (local only) |
| PostgreSQL | 127.0.0.1:5440 | 5440 (local only) |
| Redis | 127.0.0.1:6379 | 6379 (local only) |

### 5. Sécurité — Pare-feu (ufw)

```bash
# Autoriser uniquement les ports publics nécessaires
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 3000/tcp  # Frontend
sudo ufw allow 9091/tcp  # Backend API
sudo ufw allow 8080/tcp  # Keycloak
sudo ufw enable
```

### 6. Mise à jour

```bash
git pull
docker compose -f docker-compose.prod.yaml up -d --build
```

### 7. Sauvegarde

```bash
# Sauvegarde PostgreSQL
docker exec postgresTax pg_dump -U $DB_USERNAME taxCollect > backup_$(date +%Y%m%d).sql

# Sauvegarde volumes
docker run --rm -v taxcollect_pg_data:/data -v $(pwd):/backup alpine tar czf /backup/pg_data.tar.gz /data
```
