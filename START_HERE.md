# Start Here (Future You)

Hey, it's been 6 months and you forgot everything. Start here.

## What Is This?

Your entire homelab Docker infrastructure in Git, managed by Arcane.

**37 projects** running on Synology NAS (192.168.0.56):
- Media automation (Plex, Sonarr, Radarr, etc.)
- Download clients
- Books, photos, dashboards
- Everything you have running

## Quick Facts

- **Arcane Web UI**: http://192.168.0.56:3552
- **Synology SSH**: `ssh <user>@192.168.0.56`
- **Git Repo**: This directory
- **Projects**: 37 (down from original 45 - consolidated arr-stack, removed SD variants)
- **Public Safe**: Yes, no secrets in Git

## Most Common Tasks

### View Services
```
Open http://192.168.0.56:3552
```

### Restart a Service
1. Open Arcane
2. Find project
3. Click "Restart" or "Redeploy"

### Update a Service
1. Edit compose file in this repo
2. `git commit` and `git push`
3. Arcane auto-syncs (if enabled) or manually sync

### Add Secrets
1. Open Arcane
2. Edit project
3. Use "Environment Configuration (.env)" section
4. Add variables, click Save

## Important Files

| File | Purpose |
|------|---------|
| **README.md** | Complete overview, setup guide |
| **SECRETS.md** | How to manage passwords/API keys |
| **QUICKREF.md** | Common commands and operations |
| **MIGRATION.md** | How we got here from Portainer |
| **arcane-sync.json** | Bulk import all 37 projects |

## Read These in Order

1. **README.md** - Start here for the big picture
2. **SECRETS.md** - If dealing with passwords/keys
3. **QUICKREF.md** - For quick commands
4. **MIGRATION.md** - For history/context

## Key Concepts

### Arr-Stack (Important!)
Sonarr, Radarr, Lidarr, Readarr, Prowlarr, Bazarr, and Jackett are **consolidated into ONE compose file**:
- Location: `projects/media-management/arr-stack/`
- Reason: They share a network and work together
- Import as: Single "arr-stack" project in Arcane

Separate instance:
- `syncarr/` - Syncs library metadata between multiple instances

### Secrets (Very Important!)
**NO SECRETS IN GIT**
- Secrets stored in Arcane UI (recommended)
- Or in `.env` files (not in Git)
- Templates in `.env.example` files
- See SECRETS.md for details

### Networks
- `media-network` - arr-stack and download clients
- Most services use this for communication

## Emergency: Something's Broken

### Service Won't Start
```bash
# Check logs in Arcane UI, or via SSH:
ssh <user>@192.168.0.56
docker logs <container-name>
```

### Can't Remember Ports
Check QUICKREF.md or individual compose.yaml files

### Forgot How Secrets Work
Read SECRETS.md

### Want to Roll Back
```bash
git log  # Find the commit you want
git checkout <commit-hash>
git push origin main --force  # Be careful!
```

### Lost Arcane Access
```bash
ssh <user>@192.168.0.56
docker restart arcane
# Access at http://192.168.0.56:3552
```

## Directory Structure

```
homelab/
├── projects/
│   ├── media-management/
│   │   ├── arr-stack/        ← 7 services in one file!
│   │   └── syncarr/
│   ├── media-servers/         ← Plex, Jellyfin
│   ├── downloads/             ← NZBGet, qBittorrent, VPN
│   ├── books/                 ← Calibre, Kavita, etc.
│   ├── dashboards/            ← Organizr, Heimdall
│   ├── home-automation/       ← Home Assistant
│   ├── personal/              ← Paperless, Mealie, Wallabag
│   ├── photos/                ← iCloudPD, Immich
│   ├── database/              ← PostgreSQL
│   └── utilities/             ← Misc tools
└── [documentation files]
```

## What Changed from Portainer

- **Before**: Numbered directories (compose/2, compose/5, etc.)
- **After**: Categorized (projects/media-servers/plex/, etc.)
- **Before**: 45 separate projects
- **After**: 37 projects (arr-stack consolidated, SD variants removed)
- **Before**: Secrets in compose files
- **After**: Secrets in .env (not in Git)

See MIGRATION.md for complete mapping.

## Common Questions

**Q: Where are my services running?**
A: Synology NAS at 192.168.0.56

**Q: How do I update a service?**
A: Edit compose file, commit, push. Arcane syncs automatically.

**Q: Can I push this repo to public GitHub?**
A: Yes! No secrets are in Git. See SECRETS.md.

**Q: Where are the passwords?**
A: In Arcane's environment editor or local .env files (not in Git)

**Q: What's the arr-stack?**
A: Sonarr, Radarr, etc. in one compose file: `projects/media-management/arr-stack/`

**Q: How many projects should I see in Arcane?**
A: 37 projects (down from 45 - arr services consolidated, SD variants removed)

## Getting Re-oriented

1. **Check what's running**: Open http://192.168.0.56:3552
2. **Review services**: Look at projects/ directories
3. **Read README.md**: Full documentation
4. **Check Git history**: `git log` to see changes
5. **Look at QUICKREF.md**: Common operations

## Pro Tips

- Arcane can auto-sync from Git every 5 minutes
- Start services in order: VPN → Downloads → arr-stack → Media servers
- Always test compose files locally before pushing
- Keep SECRETS.md handy when configuring new services
- The arr-stack README has good setup order

## Still Confused?

Read the docs in this order:
1. This file (you are here)
2. README.md
3. QUICKREF.md  
4. Category README (e.g., projects/media-management/README.md)

---

**You created this on**: January 2026  
**Why**: Migrated from Portainer to Arcane for Git-based management  
**Current status**: Production, working, public-safe
