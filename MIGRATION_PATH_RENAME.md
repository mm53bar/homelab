# Migration Guide: Project Consolidation

This guide covers the major changes made to reorganize and streamline the homelab setup.

## Overview of Changes

### 1. Synology Container Manager Setup
**Important**: Synology Container Manager automatically creates a `/volume1/docker/` shared folder. This is a reserved directory name and cannot be renamed.

All application configs are stored in: `/volume1/docker/<service>/`

### 2. Project Consolidation
**Removed**: 23 inactive projects  
**Consolidated**: media-management + downloads → media-automation  
**Result**: 14 active projects (down from 37)

### 3. Media Automation Stack
Complete media pipeline in one compose file:
- **Download Clients**: Gluetun (VPN killswitch), qBittorrent, NZBGet
- **Indexers**: FlareSolverr, Prowlarr, Jackett
- **Media Management**: Sonarr, Radarr, Lidarr, Readarr, Bazarr

## Migration Steps

### Step 1: Stop All Containers

**In Arcane**:
1. Go to Projects
2. For each project, click "Stop"
3. Wait for all containers to stop

**Or via Docker**:
```bash
docker stop $(docker ps -q)
```

### Step 2: Clean Up and Rename Configs

**IMPORTANT**: Move old media service configs to new names to preserve settings!

```bash
# SSH into your NAS
ssh admin@192.168.0.56

# Step 1: Move media automation configs (PRESERVES SETTINGS)
mv /volume1/docker/gluetun/ /volume1/docker/media-gluetun/
mv /volume1/docker/qbittorrent/ /volume1/docker/media-qbittorrent/
mv /volume1/docker/nzbget/ /volume1/docker/media-nzbget/
mv /volume1/docker/prowlarr/ /volume1/docker/media-prowlarr/
mv /volume1/docker/jackett/ /volume1/docker/media-jackett/
mv /volume1/docker/sonarr/ /volume1/docker/media-sonarr/
mv /volume1/docker/radarr/ /volume1/docker/media-radarr/
mv /volume1/docker/lidarr/ /volume1/docker/media-lidarr/
mv /volume1/docker/readarr/ /volume1/docker/media-readarr/
mv /volume1/docker/bazarr/ /volume1/docker/media-bazarr/

# Step 2: Delete unused configs (see CLEANUP_GUIDE.md for full list)
rm -rf /volume1/docker/arr-stack/
rm -rf /volume1/docker/transmission/
# ... etc (see CLEANUP_GUIDE.md)
```

**See `CLEANUP_GUIDE.md` for complete cleanup commands.**

### Step 3: Update Arcane Installation

Update Arcane to use the domain URL for SSL:

```bash
docker stop arcane
docker rm arcane

docker run -d \
  --name arcane \
  --restart unless-stopped \
  -p 3552:3552 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /volume1/docker/arcane/data:/app/data \
  -v /volume1/docker/arcane/projects:/app/data/projects \
  -e APP_URL='https://arcane.backson.boo' \
  -e PUID='1027' \
  -e PGID='100' \
  -e ENCRYPTION_KEY='<your_encryption_key>' \
  -e JWT_SECRET='<your_jwt_secret>' \
  ghcr.io/getarcaneapp/arcane:latest
```

### Step 4: Pull Updated Repository

**In Arcane**:
1. Go to Customize > Git Repositories
2. Click "Sync Now" on your homelab repo
3. Confirm it pulled the latest changes

**Or locally**:
```bash
cd /path/to/homelab
git pull origin main
```

### Step 5: Remove Old Projects from Arcane

These projects no longer exist in the repo:

**Media (consolidated into media-automation)**:
- arr-stack
- prowlarr, sonarr, radarr, lidarr, readarr, bazarr, jackett
- gluetun, qbittorrent, nzbget, transmission

**Inactive services**:
- calibre, calibre-web, kavita, lazylibrarian, lazylibrarian2, mylar3
- heimdall, homepage, organizr
- homeassistant, mqtt (run on different machines)
- jellyfin, navidrome, plex, tdarr (run on different machines)
- photostructure
- omada-controller, tellytv, youtube-dl, syncarr

**To remove from Arcane**:
1. Go to Projects
2. For each old project, click ⋮ menu → Delete
3. Confirm deletion (containers already stopped, so safe)

### Step 6: Import New media-automation Project

**Option A: Bulk Import (Recommended)**
1. Go to Projects in Arcane
2. Click arrow next to "Create Project" → From Git Repo
3. Click "Import Multiple"
4. Use the updated `arcane-sync.json` file
5. This will add media-automation project

**Option B: Manual Import**
1. Go to Projects → Create Project → From Git Repo
2. Enter:
   - **Sync Name**: media-automation
   - **Repository**: Select your homelab repo
   - **Branch**: main
   - **Compose File Path**: `projects/media-automation/compose.yaml`
   - **Auto Sync**: Enable
3. Click "Create Sync"

### Step 7: Configure Environment Variables

The media-automation stack requires VPN credentials:

1. Click "Edit" on the media-automation project
2. Go to "Environment Configuration (.env)" section
3. Add required variables (see `.env.example`):
   ```env
   OPENVPN_USER=your-vpn-username
   OPENVPN_PASSWORD=your-vpn-password
   PUID=1027
   PGID=100
   TZ=America/Edmonton
   ```
4. Click "Save"

### Step 7: Deploy media-automation

**Important**: Only deploy after moving the configs (Step 2)!

1. Click "Up" on the media-automation project
2. Wait for all containers to start
3. Check logs for any errors

**Verify containers are running**:
```bash
docker ps | grep media-
```

You should see 11 containers:
- media-gluetun (using moved config)
- media-qbittorrent (using moved config)
- media-nzbget (using moved config)
- media-flaresolverr
- media-prowlarr (using moved config)
- media-jackett (using moved config)
- media-sonarr (using moved config)
- media-radarr (using moved config)
- media-lidarr (using moved config)
- media-readarr (using moved config)
- media-bazarr (using moved config)

### Step 8: Verify Settings Were Preserved

Access each arr service and verify your settings are intact:

**Check Sonarr** (http://192.168.0.56:8989):
- Series library intact?
- Quality profiles still configured?
- Root folders correct?

**Check Radarr** (http://192.168.0.56:7878):
- Movie library intact?
- Quality profiles still configured?

**Check Prowlarr** (http://192.168.0.56:9696):
- Indexers still configured?
- API keys still work?

**Check qBittorrent** (http://192.168.0.56:8200):
- Categories still set up?
- Settings preserved?
- Can you log in?

If any settings are missing, stop containers and check the moved directories.

### Step 9: Update Download Client Hostnames

In each arr service, update download client settings to use new container names:

**qBittorrent**:
- Host: `media-gluetun` (was `gluetun`)
- Port: 8200
- Username/password: (unchanged)
- Category: (unchanged)

**NZBGet**:
- Host: `media-nzbget` (was `nzbget`)
- Port: 6789
- Username/password: (unchanged)
- Category: (unchanged)

**Everything else stays the same** - only the hostname changes!

### Step 10: Deploy Other Projects

Start the remaining 13 projects in Arcane:
1. Go through each project
2. Click "Up" to start
3. Verify services are accessible

### Step 11: Update Nginx Proxy Manager (if needed)

If any ports changed, update your NPM proxy hosts. Most ports stayed the same:

**Services that kept same ports**:
- Sonarr: 8989
- Radarr: 7878
- Lidarr: 8686
- Readarr: 8787
- Bazarr: 6767
- Prowlarr: 9696
- NZBGet: 5678 (was 6789 internally, but exposed as 5678)
- qBittorrent: 8200

No NPM changes needed for these!

## Verification Checklist

- [ ] All containers show as "running" in Arcane
- [ ] Can access web UIs for all services
- [ ] Sonarr/Radarr can communicate with download clients
- [ ] Prowlarr syncing indexers to arr services
- [ ] qBittorrent routes through VPN (check IP in WebUI)
- [ ] Media imports work correctly
- [ ] Nginx Proxy Manager proxies work

## Troubleshooting

### Services can't find config files

**Issue**: Containers exit immediately or can't find databases

**Fix**: Verify the directory structure:
```bash
ls -la /volume1/docker/<service>/
```

All service configs should be in `/volume1/docker/` (Synology Container Manager's default location).

### qBittorrent not accessible

**Issue**: Can't access qBittorrent WebUI

**Check**:
1. Gluetun is running: `docker ps | grep media-gluetun`
2. VPN connected: `docker logs media-gluetun | grep "ip"`
3. Access via Gluetun's port: http://192.168.0.56:8200

### Download clients not connecting

**Issue**: Arr services show "Unable to connect to download client"

**Fix**: Update host names:
- qBittorrent: `media-gluetun` (not `gluetun` or `qbittorrent`)
- NZBGet: `media-nzbget` (not `nzbget`)

### VPN not connecting

**Issue**: Gluetun fails to start or VPN won't connect

**Check**:
1. Verify VPN credentials in .env
2. Check VPN config file exists: `/volume1/docker/gluetun/getflix/Canada-Toronto_TCP1194_SMART.ovpn`
3. Check logs: `docker logs media-gluetun`

### Arcane can't find compose files

**Issue**: "Compose file not found" error

**Fix**: 
1. Verify Git sync worked: Check commit hash in Arcane matches GitHub
2. Manually sync: Customize > Git Repositories > Sync Now
3. Check file path in project settings

## Rollback Plan

If something goes wrong:

1. **Stop all containers**
2. **Revert Git repository**:
   ```bash
   git checkout <previous-commit-hash>
   ```
3. **Restore old Arcane project configuration from backup**

Note: No directory rename needed - `/volume1/docker/` is the standard Synology location.

## Benefits After Migration

✅ **Cleaner structure**: Only 14 active projects vs 37  
✅ **Standard paths**: `/volume1/docker/` (Synology default)  
✅ **Consolidated pipeline**: One media-automation stack  
✅ **VPN killswitch**: qBittorrent protected by Gluetun  
✅ **Environment variables**: Flexible configuration  
✅ **SSL access**: Arcane via `https://arcane.backson.boo`  
✅ **No Traefik clutter**: Clean compose files for NPM setup  

## Questions?

See the main README.md or individual project READMEs for detailed configuration guides.
