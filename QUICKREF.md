# Quick Reference Guide

Essential commands and information for managing your homelab with Arcane.

## Arcane Web UI

**URL**: http://192.168.0.56:3552

## Quick Setup (First Time)

1. **Add Git Repository** (Customize > Git Repositories):
   - Repository URL: `<your-git-repo-url>`
   - Name: `homelab`
   - Configure authentication (SSH key or PAT)

2. **Bulk Import Projects** (Projects page):
   - Click dropdown next to "Create Project"
   - Select "From Git Repo"
   - Import from `arcane-sync.json`
   - All 45 projects imported at once

3. **Enable Auto-Sync** (optional):
   - Each project can poll for changes
   - Default: 5 minute intervals
   - Auto-redeploys when changes detected

## Common Arcane Operations

### Start All Services in a Project
```
Click "Up" button in project view
```

### Stop All Services
```
Click "Down" button
```

### Restart Services (no rebuild)
```
Click "Restart" button
```

### Update and Redeploy
```
Click "Redeploy" button
Equivalent to: docker pull && docker up -d
```

### Destroy Project
```
Click "Destroy" button
Options: Remove volumes, Remove project files
```

## Git Workflow

### Making Changes

1. **Edit locally**:
   ```bash
   cd /Users/mike/src/homelab
   # Edit compose files as needed
   ```

2. **Commit changes**:
   ```bash
   git add .
   git commit -m "Description of changes"
   ```

3. **Push to remote**:
   ```bash
   git push origin main
   ```

4. **Arcane auto-syncs** (if enabled) or manually trigger sync

### Adding a New Service

1. **Create directory**:
   ```bash
   mkdir -p projects/<category>/<service-name>
   ```

2. **Create compose.yaml**:
   ```bash
   touch projects/<category>/<service-name>/compose.yaml
   # Edit with your compose configuration
   ```

3. **Add README** (optional but recommended):
   ```bash
   touch projects/<category>/<service-name>/README.md
   ```

4. **Commit and push**:
   ```bash
   git add .
   git commit -m "Add <service-name> service"
   git push
   ```

5. **Import in Arcane**:
   - Projects → Create Project → From Git Repo
   - Or update `arcane-sync.json` and re-import

## SSH into Synology NAS

```bash
ssh <username>@192.168.0.56
```

## Useful Docker Commands (on NAS)

### List Running Containers
```bash
docker ps
```

### View Container Logs
```bash
docker logs <container-name>
docker logs -f <container-name>  # Follow logs
```

### Restart a Container
```bash
docker restart <container-name>
```

### Check Container Stats
```bash
docker stats
```

### Access Container Shell
```bash
docker exec -it <container-name> /bin/bash
# or
docker exec -it <container-name> /bin/sh
```

## Important Paths on Synology

| Path | Purpose |
|------|---------|
| `/volume1/docker/` | Container config directories |
| `/volume1/data/media/` | Media files (movies, TV, music) |
| `/volume1/data/usenet/` | Usenet downloads |
| `/volume1/data/torrents/` | Torrent downloads |
| `/volume1/docker/arcane/data/` | Arcane data |
| `/volume1/docker/arcane/projects/` | Arcane projects directory |

## Common Port Mappings

Access services at `http://192.168.0.56:<port>`

### Media Management
- Sonarr: Check compose file
- Radarr: Check compose file  
- Prowlarr: Check compose file
- Bazarr: Check compose file

### Media Servers
- Plex: 32400
- Jellyfin: Check compose file

### Downloads
- NZBGet: 5678
- qBittorrent: Check compose file

### Dashboards
- Organizr: Check compose file
- Heimdall: Check compose file

### Utilities
- Arcane: 3552
- PostgreSQL: 2665
- pgAdmin: Check compose file

## Troubleshooting Quick Checks

### Service Won't Start
```bash
# Check logs in Arcane UI, or via SSH:
docker logs <container-name>

# Check if port is in use:
netstat -tulpn | grep <port>

# Verify volume paths exist:
ls -la /volume1/docker/<service>/
```

### Git Sync Not Working
- Check repository authentication in Arcane
- Verify branch name (should be `main`)
- Check compose file path in sync configuration
- Review Arcane logs

### Permission Errors
```bash
# Fix ownership (on NAS):
sudo chown -R 1027:100 /volume1/docker/<service>/
```

### Container Health
```bash
# Check container status:
docker inspect <container-name> | grep -A 10 Health

# Check if container is restarting:
docker ps -a | grep <container-name>
```

## Environment Variables

Standard environment variables used across services:

```yaml
environment:
  - PUID=1027          # Synology user ID
  - PGID=100           # Synology users group
  - TZ=America/Edmonton
```

## Backing Up Configuration

### Manual Backup
```bash
# Backup all config directories:
tar -czf docker-configs-$(date +%Y%m%d).tar.gz /volume1/docker/

# Backup just Arcane:
tar -czf arcane-backup-$(date +%Y%m%d).tar.gz /volume1/docker/arcane/
```

### Git Backup
Your compose files are automatically backed up in Git. To backup:
```bash
git push origin main
```

## Network Configuration

### Common Networks
- `media-network` - Used by media management tools
- `bridge` (default) - Standard Docker network

### Check Container Network
```bash
docker inspect <container-name> | grep NetworkMode
```

## Service Dependencies

Start services in this order when setting up from scratch:

1. **VPN** (Gluetun) - if using
2. **Download Clients** (NZBGet, qBittorrent)
3. **Indexers** (Prowlarr)
4. **Media Management** (Sonarr, Radarr, etc.)
5. **Media Servers** (Plex, Jellyfin)
6. **Utilities** (Bazarr, Tdarr, etc.)
7. **Dashboards** (Organizr, Heimdall)

## Updating Services

### Via Arcane (Recommended)
1. Click "Redeploy" on project
2. Pulls latest image and recreates container

### Via SSH
```bash
docker pull <image-name>
docker-compose -f /path/to/compose.yaml up -d
```

## Security Notes

### Exposed Ports
Review what ports are exposed to your network. Consider:
- Using a reverse proxy (Traefik, Nginx Proxy Manager)
- Restricting access via firewall rules
- Using VPN for remote access

### Secrets Management
- `.env` files are in Git (be careful with public repos)
- Consider using Arcane's UI for sensitive environment variables
- Use Docker secrets for production deployments

### Updates
- Keep Arcane updated for security patches
- Regularly update container images
- Monitor security advisories for your services

## Resources

- **Arcane Docs**: https://getarcane.app/docs
- **This Repo**: Check README.md and MIGRATION.md
- **Category Docs**: See README.md in each `projects/<category>/` directory

## Emergency Contacts / Info

- **NAS IP**: 192.168.0.56
- **Arcane Port**: 3552
- **Timezone**: America/Edmonton
- **PUID**: 1027
- **PGID**: 100

---

**Last Updated**: January 2026
