# Secrets Setup Guide

This guide explains how to securely configure secrets for your homelab services using Arcane's built-in encryption.

## Overview

Arcane encrypts all environment variables using a master `ENCRYPTION_KEY`. This means:
- ✅ Secrets are encrypted at rest in Arcane's database
- ✅ Only one master key to secure (`ENCRYPTION_KEY`)
- ✅ No plaintext secrets in Git
- ✅ Easy management through Arcane's UI

## Critical Secrets to Configure

### 1. **Paperless-NGX** (Document Management)
**Project:** `projects/personal/paperless-ngx`

**Required Secrets:**
```bash
PAPERLESS_SECRET_KEY=<generate-new-key>
PAPERLESS_ADMIN_PASSWORD=<strong-password>
```

**Generate Secret Key:**
```bash
# Option 1: Using Python (Django method)
python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'

# Option 2: Using OpenSSL
openssl rand -base64 32
```

**Steps:**
1. Generate a new secret key using one of the commands above
2. Choose a strong admin password
3. Add in Arcane UI: Projects → paperless-ngx → Edit → Environment Configuration
4. Add both variables with their values
5. Deploy the stack

---

### 2. **Immich** (Photo Management)
**Project:** `projects/photos/immich`

**Required Secrets:**
```bash
IMMICH_DB_PASSWORD=<strong-password>
IMMICH_POSTGRES_PASSWORD=<same-as-above>
```

**⚠️ IMPORTANT:** Both passwords MUST be identical!

**Generate Password:**
```bash
openssl rand -base64 32
```

**Steps:**
1. Generate ONE strong password
2. Add in Arcane UI: Projects → immich → Edit → Environment Configuration
3. Add `IMMICH_DB_PASSWORD` with the password
4. Add `IMMICH_POSTGRES_PASSWORD` with the **same** password
5. Deploy the stack

---

### 3. **iCloudPD** (iCloud Photo Sync)
**Project:** `projects/photos/icloudpd`

**Required Secrets:**
```bash
ICLOUDPD_MIKE_APPLE_ID=mike@aream.ca
ICLOUDPD_SHEILA_APPLE_ID=sheila@aream.ca
```

**Steps:**
1. Add in Arcane UI: Projects → icloudpd → Edit → Environment Configuration
2. Add `ICLOUDPD_MIKE_APPLE_ID` with Mike's Apple ID email
3. Add `ICLOUDPD_SHEILA_APPLE_ID` with Sheila's Apple ID email
4. Deploy the stack
5. **Follow 2FA authentication** in container logs after first start

---

## How to Add Secrets in Arcane

### Via Web UI (Recommended)

1. **Navigate to Project:**
   - Go to https://arcane.backson.boo
   - Click "Projects" in sidebar
   - Find your project (e.g., "paperless-ngx")

2. **Edit Environment:**
   - Click the ⋮ menu → "Edit"
   - Scroll to "Environment Configuration (.env)"
   - Add each variable with its value:
     ```
     PAPERLESS_SECRET_KEY=your_generated_key_here
     PAPERLESS_ADMIN_PASSWORD=your_strong_password
     ```

3. **Save & Deploy:**
   - Click "Save"
   - Click "Up" to deploy with new secrets
   - Arcane encrypts these using your `ENCRYPTION_KEY`

### Via API (Advanced)

If you prefer automation, use Arcane's API:

```bash
# Get your API token from Arcane UI: Settings → API Tokens

# Add environment variable to project
curl -X POST https://arcane.backson.boo/api/projects/{project_id}/env \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "PAPERLESS_SECRET_KEY",
    "value": "your_generated_key_here"
  }'
```

---

## Security Best Practices

### ✅ DO:
- **Use Arcane's UI** to configure secrets (they're encrypted automatically)
- **Generate strong, unique keys** for each service
- **Keep your `ENCRYPTION_KEY` secure** - it's your master key
- **Use `.env.example` files** as templates (committed to Git)
- **Never commit `.env` or `.env.secrets`** to Git (already in .gitignore)
- **Backup your Arcane database** - it contains encrypted secrets
- **Rotate secrets periodically** (annually at minimum)

### ❌ DON'T:
- **Never commit actual secrets** to Git
- **Don't use default passwords** (like "admin" or "postgres")
- **Don't share secrets** via insecure channels (email, Slack, etc.)
- **Don't reuse passwords** across services
- **Don't lose your `ENCRYPTION_KEY`** - you can't decrypt secrets without it

---

## File Structure

Each project with secrets has three files:

```
projects/
└── personal/
    └── paperless-ngx/
        ├── compose.yaml          # Uses ${VARIABLE} placeholders
        ├── .env.example          # Template (committed to Git)
        └── .env.secrets          # Your actual secrets (NOT in Git)
```

**Workflow:**
1. `.env.secrets` = Your local reference (gitignored)
2. Copy secrets from `.env.secrets` → Arcane UI
3. Arcane encrypts them with `ENCRYPTION_KEY`
4. Deploy stack - Docker Compose gets decrypted values

---

## Verifying Secrets Are Set

### Check Required Secrets

All critical compose files use `:?` syntax to require secrets:

```yaml
environment:
  PAPERLESS_SECRET_KEY: ${PAPERLESS_SECRET_KEY:?PAPERLESS_SECRET_KEY must be set}
```

If you try to deploy without setting the secret, you'll get a clear error:

```
Error: PAPERLESS_SECRET_KEY must be set
```

### Test Deployment

1. Deploy the stack in Arcane
2. Check container logs for errors
3. Verify the service is accessible
4. Test login with your credentials

---

## Backing Up Your Encryption Key

Your `ENCRYPTION_KEY` is critical - without it, you can't decrypt secrets!

### Where Is It?

Check your Arcane container environment:
```bash
docker inspect arcane | grep ENCRYPTION_KEY
```

### Store It Securely

Choose ONE of these methods:

1. **Password Manager** (Recommended)
   - Store in 1Password, Bitwarden, LastPass, etc.
   - Label: "Arcane Master Encryption Key"

2. **Hardware Security Key**
   - Use YubiKey or similar
   - Store encrypted copy

3. **Offline Backup**
   - Write it down
   - Store in safe/safety deposit box

**⚠️ CRITICAL:** If you lose this key, you lose ALL your secrets!

---

## Rotating Secrets

### When to Rotate:
- Annually (minimum)
- After a security breach
- When team member leaves
- If key is potentially compromised

### How to Rotate:

1. **Generate New Secret:**
   ```bash
   openssl rand -base64 32
   ```

2. **Update in Arcane UI:**
   - Projects → {service} → Edit → Environment
   - Change the secret value
   - Save

3. **Redeploy Stack:**
   - Click "Down" then "Up"
   - Or click "Restart"

4. **Verify:**
   - Check service still works
   - Test authentication

---

## Troubleshooting

### "Secret Key Must Be Set" Error

**Problem:** Compose validation fails before starting
**Solution:** Add the required secret in Arcane UI

### Service Won't Start After Adding Secret

**Problem:** Wrong secret format or value
**Solution:** 
1. Check container logs: `docker logs <container_name>`
2. Verify secret matches expected format
3. For database passwords, ensure both variables match

### Can't Access Arcane UI

**Problem:** Forgot admin password or lost `ENCRYPTION_KEY`
**Solution:**
- If you have access to the host: Check Arcane container env
- If `ENCRYPTION_KEY` is lost: You'll need to reconfigure all secrets
- Backup your Arcane database regularly to avoid this!

### Secrets Not Being Applied

**Problem:** Old values still in use
**Solution:**
1. Click "Down" to stop all containers
2. Wait for complete shutdown
3. Click "Up" to restart with new secrets
4. Check logs to verify new values loaded

---

## Quick Reference: All Secrets

| Service | Secret Variable | How to Generate |
|---------|----------------|-----------------|
| **paperless-ngx** | `PAPERLESS_SECRET_KEY` | `openssl rand -base64 32` |
| | `PAPERLESS_ADMIN_PASSWORD` | Strong password (12+ chars) |
| **immich** | `IMMICH_DB_PASSWORD` | `openssl rand -base64 32` |
| | `IMMICH_POSTGRES_PASSWORD` | Same as `IMMICH_DB_PASSWORD` |
| **icloudpd** | `ICLOUDPD_MIKE_APPLE_ID` | `mike@aream.ca` |
| | `ICLOUDPD_SHEILA_APPLE_ID` | `sheila@aream.ca` |
| **media-automation** | `OPENVPN_USER` | From VPN provider |
| | `OPENVPN_PASSWORD` | From VPN provider |

---

## Getting Help

If you run into issues:
1. Check the `.env.secrets` file for the specific project
2. Review container logs: `docker logs <container_name>`
3. Verify secrets are set in Arcane UI
4. Check the project's `.env.example` for required variables

---

**Last Updated:** 2026-01-25
**Related Files:**
- `.gitignore` - Blocks `.env` and `.env.secrets` from Git
- `projects/*/. env.example` - Templates for each service
- `projects/*/.env.secrets` - Secret reference (your copy only)
