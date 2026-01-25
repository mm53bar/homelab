# Secrets to Add in Arcane UI

After rsync completes and you deploy the updated stacks, add these secrets through Arcane's UI.

## Critical Secrets (Add Before Deployment)

### 1. Paperless-NGX
**Project:** `paperless-ngx`

```bash
# Generate secret key:
python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
# OR:
openssl rand -base64 32
```

**Add in Arcane UI:**
- `PAPERLESS_SECRET_KEY` = (paste generated key)
- `PAPERLESS_ADMIN_PASSWORD` = (choose strong password)

---

### 2. Immich
**Project:** `immich`

```bash
# Generate ONE password for both:
openssl rand -base64 32
```

**Add in Arcane UI (use SAME password for both!):**
- `IMMICH_DB_PASSWORD` = (paste generated password)
- `IMMICH_POSTGRES_PASSWORD` = (paste SAME password)

---

### 3. iCloudPD
**Project:** `icloudpd`

**Add in Arcane UI:**
- `ICLOUDPD_MIKE_APPLE_ID` = `mike@aream.ca`
- `ICLOUDPD_SHEILA_APPLE_ID` = `sheila@aream.ca`

**Note:** After first deployment, you'll need to complete 2FA authentication in container logs.

---

### 4. Media Automation (VPN)
**Project:** `media-automation`

**Add in Arcane UI:**
- `OPENVPN_USER` = `VPN-218333` (your Getflix username)
- `OPENVPN_PASSWORD` = `WLWRFTFT` (your Getflix password)

---

## How to Add Secrets

1. Go to https://arcane.backson.boo
2. Navigate to: Projects → {project-name} → Edit
3. Scroll to: "Environment Configuration (.env)"
4. Add each secret variable and value
5. Click "Save"
6. Deploy the stack

Arcane will encrypt all these values using your `ENCRYPTION_KEY` - they're secure!

---

## Reference

See `SECRETS_SETUP.md` for complete guide and troubleshooting.
