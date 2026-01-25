# Homelab Docker Compose Projects

This repository contains all Docker Compose configurations for my homelab services, managed via [Arcane](https://getarcane.app).

## Overview

This homelab runs on a Synology NAS with Docker, managing 40+ services across various categories. The services were migrated from Portainer to Arcane for better Git-based management and automation.

### Service Categories

- **Media Management**: Sonarr, Radarr, Lidarr, Readarr, Prowlarr, Bazarr, Jackett
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

Arcane is already installed and running on `http://192.168.0.56:3552` with the following configuration:

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
  -e ENCRYPTION_KEY='up13FnseF34Yr0c31Xd851o+iM1SOyJXcGqU8xlU+NI=' \
  -e JWT_SECRET='JXoG+vwg9crqV28ClcNt4ghztcs8Wsx0qEv+6Kam+Js=' \
  ghcr.io/getarcaneapp/arcane:latest
```

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
   - This will import all 40+ projects at once

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
│   ├── media-management/    # Sonarr, Radarr, Lidarr, etc.
│   ├── media-servers/        # Plex, Jellyfin, Navidrome
│   ├── downloads/            # NZBGet, qBittorrent, Transmission, Gluetun
│   ├── books/                # Calibre, Calibre-Web, Kavita, etc.
│   ├── dashboards/           # Organizr, Heimdall, Homepage
│   ├── home-automation/      # Home Assistant, MQTT
│   ├── personal/             # Paperless, Mealie, Wallabag, Forgejo
│   ├── photos/               # iCloudPD, PhotoStructure, Immich
│   ├── database/             # PostgreSQL, pgAdmin
│   └── utilities/            # Omada, Syncarr, YouTube-DL, etc.
├── arcane-sync.json          # Bulk import configuration
├── MIGRATION.md              # Migration notes from Portainer
└── README.md                 # This file
```

Each project directory contains:
- `compose.yaml` - Docker Compose configuration
- `.env` (optional) - Environment variables
- `README.md` - Service-specific documentation

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

This repository contains:
- Environment variables in `.env` files
- API keys and passwords

**IMPORTANT**: Before pushing to a public Git repository:
1. Review all `.env` files
2. Use `.env.example` templates with placeholder values
3. Store actual secrets in Arcane's UI or a secrets manager
4. Add `.env` to `.gitignore` if needed

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
