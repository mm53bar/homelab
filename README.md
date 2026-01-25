# Homelab Docker Compose Projects

This repository contains all Docker Compose configurations for my homelab services, managed via [Arcane](https://getarcane.app).

## Overview

This homelab runs on a Synology NAS with Docker, managing 40+ services across various categories organized into 39 projects. The services were migrated from Portainer to Arcane for better Git-based management and automation.

**Key Features**:
- Consolidated arr-stack (Sonarr, Radarr, Prowlarr, etc.) in single compose file
- Secrets managed via .env files (not committed to Git)
- Automatic sync from Git repository
- Categorized by function for easy navigation

### Service Categories

- **Media Management** (arr-stack): Consolidated compose file with Sonarr, Radarr, Lidarr, Readarr, Prowlarr, Bazarr, Jackett + separate Sonarr-SD, Radarr-SD, Syncarr
- **Media Servers**: Plex, Jellyfin, Navidrome, Tdarr
- **Download Clients**: NZBGet, qBittorrent, Transmission, Gluetun (VPN)
- **Books & Comics**: Calibre, Calibre-Web, LazyLibrarian, Mylar3, Kavita
- **Dashboards**: Organizr, Heimdall, Homepage, Homer
- **Home Automation**: Home Assistant, MQTT
- **Personal Apps**: Paperless-NGX, Mealie, Wallabag, Forgejo
- **Photos**: iCloudPD, PhotoStructure, Immich
- **Database**: PostgreSQL, pgAdmin
- **Utilities**: Omada Controller, Syncarr, YouTube-DL, iSponsorBlockTV, TRMNL

## Quick Start

### Prerequisites

- Synology NAS with Docker installed
- Arcane running on your network
- Git installed (for local cloning/editing)

### Arcane Installation

Arcane is installed and running on `http://192.168.0.56:3552`.

**Installation command** (for reference - contains sensitive keys):
```bash
docker run -d \
  --name arcane \
  --restart unless-stopped \
  -p 3552:3552 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /volume1/docker/arcane/data:/app/data \
  -v /volume1/docker/arcane/projects:/app/data/projects \
  -e APP_URL='http://192.168.0.56:3552' \
  -e PUID='1027' \
  -e PGID='100' \
  -e ENCRYPTION_KEY='<your_encryption_key>' \
  -e JWT_SECRET='<your_jwt_secret>' \
  ghcr.io/getarcaneapp/arcane:latest
```

> **Note**: Encryption keys are stored securely outside this repo. See SECRETS.md for details.

### Setting Up Git Sync in Arcane

1. **Add this repository to Arcane**:
   - Navigate to Arcane at `http://192.168.0.56:3552`
   - Go to `Customize > Git Repositories`
   - Click `Add Repository`
   - Enter your repository URL
   - Configure authentication (SSH key or Personal Access Token)
   - Click `Save`

2. **Bulk Import All Projects**:
   - Go to the `Projects` page in Arcane
   - Click the arrow next to "Create Project" → select `From Git Repo`
   - Click `Import Multiple` 
   - Use the `arcane-sync.json` file from this repository
   - This will import all 39 projects at once

3. **Enable Auto-Sync** (Optional):
   - Each project can be configured to automatically poll for changes
   - Arcane will pull updates and redeploy services when changes are detected
   - Default sync interval: 5 minutes

### Manual Project Import

If you prefer to import projects individually:

1. Go to `Projects` in Arcane
2. Click the arrow next to "Create Project" → `From Git Repo`
3. Enter:
   - **Sync Name**: e.g., "plex"
   - **Repository**: Select your connected repo
   - **Branch**: main
   - **Compose File Path**: e.g., `projects/media-servers/plex/compose.yaml`
   - **Auto Sync**: Enable if desired
4. Click `Create Sync`

## Repository Structure

```
homelab/
├── projects/
│   ├── media-management/     # arr-stack (consolidated) + SD variants
│   │   └── arr-stack/        # Sonarr, Radarr, Lidarr, Readarr, Prowlarr, Bazarr, Jackett
│   ├── media-servers/        # Plex, Jellyfin, Navidrome
│   ├── downloads/            # NZBGet, qBittorrent, Transmission, Gluetun
│   ├── books/                # Calibre, Calibre-Web, Kavita, etc.
│   ├── dashboards/           # Organizr, Heimdall, Homepage
│   ├── home-automation/      # Home Assistant, MQTT
│   ├── personal/             # Paperless, Mealie, Wallabag, Forgejo
│   ├── photos/               # iCloudPD, PhotoStructure, Immich
│   ├── database/             # PostgreSQL, pgAdmin
│   └── utilities/            # Omada, Syncarr, YouTube-DL, etc.
├── arcane-sync.json          # Bulk import configuration (39 projects)
├── SECRETS.md                # Secrets management guide
├── MIGRATION.md              # Migration notes from Portainer
└── README.md                 # This file
```

Each project directory contains:
- `compose.yaml` - Docker Compose configuration
- `.env` (optional) - Environment variables (NOT in Git)
- `.env.example` - Template showing required variables
- `README.md` - Service-specific documentation

## Secrets Management

**This repository is public-safe** - no secrets are committed to Git.

### How Secrets Work

1. **Compose files use environment variable references**: `${POSTGRES_PASSWORD}`
2. **.env files are gitignored**: Create them locally or in Arcane UI
3. **.env.example templates provided**: Show required variables without values
4. **Secrets managed in Arcane**: Use Arcane's environment editor (recommended)

### Setting Up Secrets

**Method 1: Arcane UI (Recommended)**
1. Import project from Git
2. Click "Edit" on the project
3. Use "Environment Configuration (.env)" section
4. Add your secrets
5. Click "Save"

**Method 2: Local .env Files**
```bash
# Copy template
cp projects/database/postgresql/.env.example projects/database/postgresql/.env

# Edit with your values
nano projects/database/postgresql/.env

# Never commit .env files (already in .gitignore)
```

See **[SECRETS.md](SECRETS.md)** for complete secrets management guide.

## Environment Configuration

### Network Settings
- **Timezone**: `America/Edmonton`
- **PUID**: `1027` (Synology user ID)
- **PGID**: `100` (Synology users group)

### Volume Paths
All services use Synology volume paths:
- Docker configs: `/volume1/docker/<service>/`
- Media: `/volume1/data/`
- Shared data paths maintained for compatibility

### Networks
Some services use Docker networks:
- `media-network` - Used by media management tools
- Custom networks per-service as needed

## Important Notes

### Arcane Git Sync Behavior

- **Read-Only Compose Files**: When synced from Git, compose files are read-only in Arcane
- **Editable .env**: Environment files can still be edited in Arcane's UI
- **Auto-Redeploy**: Only happens if the project is currently running
- **Projects Directory**: Arcane treats `/app/data/projects` as the source of truth

### Path Adjustments

If you're running Arcane on a different machine than the services, you may need to adjust volume paths. The current setup assumes:
- Arcane runs on the same Synology NAS as the containers
- Access to `/volume1/docker/` and `/volume1/data/` paths

### Secrets & Sensitive Data

**This repository is PUBLIC-SAFE**:
- `.env` files are gitignored and never committed
- `.env.example` templates provided as documentation
- Compose files use environment variable references
- Actual secrets stored in Arcane UI or local .env files

**See [SECRETS.md](SECRETS.md) for complete guide**.

## Maintenance

### Updating Services

1. **Via Git** (Recommended):
   - Edit compose files in this repo
   - Commit and push changes
   - Arcane will auto-sync if enabled, or manually trigger sync

2. **Via Arcane UI**:
   - Edit `.env` files directly in Arcane
   - Use Arcane's controls: Up, Down, Restart, Redeploy

### Adding New Services

1. Create a new directory under the appropriate category in `projects/`
2. Add `compose.yaml` file
3. Add `README.md` with service documentation
4. Add `.env` file if needed
5. Commit and push
6. Import in Arcane via Git Sync

### Removing Services

1. In Arcane, click `Destroy` on the project
2. Select whether to remove volumes
3. Select whether to remove project files
4. Remove from Git repository if no longer needed

## Troubleshooting

### Service Won't Start
- Check Arcane logs for the project
- Verify volume paths exist on NAS
- Check port conflicts (use `docker ps` on NAS)
- Verify environment variables in `.env`

### Git Sync Issues
- Check repository authentication in Arcane
- Verify branch name is correct
- Check compose file path is accurate
- Review Arcane logs for sync errors

### Volume Permission Issues
- Verify PUID=1027 and PGID=100 are correct for your Synology user
- Check folder permissions on NAS: `/volume1/docker/<service>/`

## Resources

- [Arcane Documentation](https://getarcane.app/docs)
- [Arcane Projects Guide](https://getarcane.app/docs/features/projects)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Synology Docker](https://www.synology.com/en-us/dsm/feature/docker)

## Migration History

This repository was created by migrating from Portainer to Arcane. See [MIGRATION.md](MIGRATION.md) for details about the migration process and original Portainer structure.

---

**Last Updated**: January 2026
**Arcane Version**: Latest
**NAS**: Synology (192.168.0.56)
