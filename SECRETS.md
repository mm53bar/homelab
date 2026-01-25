# Secrets Management Guide

This repository is designed to be **public-safe** - no secrets are committed to Git.

## Strategy

1. **Compose files use environment variable references** - No hardcoded secrets
2. **.env files are gitignored** - Create locally or manage in Arcane UI
3. **.env.example templates provided** - Show required variables without values
4. **Secrets managed in Arcane** - Use Arcane's UI to set environment variables

## How It Works

### In Git (Public)
```yaml
# compose.yaml
environment:
  - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
  - API_KEY=${API_KEY}
```

### In Arcane (Private)
- Edit project in Arcane UI
- Use the "Environment Configuration (.env)" editor
- Arcane stores these locally, never pushed to Git

### Locally (Private)
```bash
# .env (not in Git)
POSTGRES_PASSWORD=your_secure_password
API_KEY=your_api_key
```

## Setting Up Secrets

### Method 1: Arcane UI (Recommended for Production)

1. Import project from Git
2. Click "Edit" on the project
3. Use "Environment Configuration (.env)" section
4. Add your secrets
5. Click "Save"

Arcane stores these in `/volume1/docker/arcane/projects/<project>/.env`

### Method 2: Manual .env Files (For Local Testing)

1. Copy `.env.example` to `.env`:
   ```bash
   cp projects/database/postgresql/.env.example projects/database/postgresql/.env
   ```

2. Edit `.env` with your actual values:
   ```bash
   # .env
   POSTGRES_PASSWORD=your_actual_password
   PGADMIN_DEFAULT_PASSWORD=your_actual_password
   ```

3. Never commit `.env` files (already in .gitignore)

### Method 3: Docker Secrets (Advanced)

For production deployments, consider Docker Secrets:
```yaml
secrets:
  db_password:
    file: ./db_password.txt

services:
  db:
    secrets:
      - db_password
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
```

## Required Secrets by Service

### PostgreSQL + pgAdmin
Create: `projects/database/postgresql/.env`
```bash
POSTGRES_USER=root
POSTGRES_PASSWORD=your_secure_password_here
POSTGRES_DB=backson_DB
PGADMIN_DEFAULT_EMAIL=admin@example.com
PGADMIN_DEFAULT_PASSWORD=your_secure_password_here
```

### Transmission (VPN)
Create: `projects/downloads/transmission/.env`
```bash
OPENVPN_PROVIDER=your_vpn_provider
OPENVPN_USERNAME=your_vpn_username
OPENVPN_PASSWORD=your_vpn_password
LOCAL_NETWORK=192.168.0.0/24
```

### Gluetun (VPN)
Create: `projects/downloads/gluetun/.env`
```bash
VPN_SERVICE_PROVIDER=your_vpn_provider
VPN_TYPE=openvpn
OPENVPN_USER=your_vpn_username
OPENVPN_PASSWORD=your_vpn_password
SERVER_COUNTRIES=your_preferred_country
```

### Add More As Needed
As you configure services, create `.env.example` templates and corresponding `.env` files.

## Arcane Installation Secrets

The Arcane installation command contains sensitive keys. Store these securely:

```bash
# DO NOT commit these values
ENCRYPTION_KEY='<generate_new_key>'
JWT_SECRET='<generate_new_key>'
```

Generate new keys:
```bash
# Generate random base64 keys
openssl rand -base64 32
```

## Best Practices

### DO:
- Use `.env` files for secrets
- Create `.env.example` templates for documentation
- Manage secrets in Arcane UI for production
- Use different secrets for dev/staging/prod
- Rotate secrets periodically
- Use strong, unique passwords

### DON'T:
- Commit `.env` files with real values
- Hardcode secrets in compose.yaml files
- Use default passwords (change them!)
- Share secrets in plain text
- Reuse passwords across services
- Commit Arcane encryption keys

## Migrating Existing Secrets

If you already have secrets in compose files:

1. **Extract to .env**:
   ```bash
   # Before (in compose.yaml)
   POSTGRES_PASSWORD: mypassword
   
   # After (in compose.yaml)
   POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
   
   # In .env (not committed)
   POSTGRES_PASSWORD=mypassword
   ```

2. **Update compose file** to reference variables
3. **Create .env.example** template
4. **Test locally** to ensure it works
5. **Commit compose.yaml** changes
6. **Add secrets to Arcane UI** after import

## Secrets Checklist

Before making repo public:

- [ ] All secrets moved to .env files
- [ ] .env files in .gitignore
- [ ] .env.example templates created
- [ ] No passwords in compose files
- [ ] No API keys in compose files
- [ ] No Arcane encryption keys in docs
- [ ] README updated with secrets instructions
- [ ] Tested: compose files work with .env

## Emergency: Secrets Exposed

If you accidentally commit secrets:

1. **Immediately rotate all exposed secrets**
2. **Remove from Git history**:
   ```bash
   # Use BFG Repo Cleaner or git filter-branch
   git filter-branch --force --index-filter \
     'git rm --cached --ignore-unmatch projects/database/postgresql/.env' \
     --prune-empty --tag-name-filter cat -- --all
   ```
3. **Force push** (if remote exists):
   ```bash
   git push origin --force --all
   ```
4. **Change passwords** in all services
5. **Update Arcane** with new secrets

## Questions?

- Arcane docs: https://getarcane.app/docs/features/projects
- Docker secrets: https://docs.docker.com/engine/swarm/secrets/
- Environment files: https://docs.docker.com/compose/environment-variables/

---

**Remember**: Secrets in Git = Secrets exposed. Keep them in .env files and Arcane UI only.
