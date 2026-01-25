# Media Automation Stack

Complete media automation pipeline with download clients, indexers, and media management tools. All services work together to automatically find, download, organize, and manage your media library.

## Services Included

### Download Clients
- **Gluetun** - VPN killswitch container (all torrent traffic routes through VPN)
- **qBittorrent** - Torrent client (port 8200) - Routes through Gluetun VPN
- **NZBGet** - Usenet client (port 5678)

### Indexers & Search
- **FlareSolverr** - Cloudflare bypass for protected indexers (port 8191)
- **Prowlarr** - Centralized indexer manager (port 9696)
- **Jackett** - Legacy torrent indexer proxy (port 9117) - *Consider migrating to Prowlarr*

### Media Management
- **Sonarr** - TV show management (port 8989)
- **Radarr** - Movie management (port 7878)
- **Lidarr** - Music management (port 8686)
- **Readarr** - Book/audiobook management (port 8787)
- **Bazarr** - Subtitle management (port 6767)

## Why One Stack?

All these services form a cohesive automation pipeline:
- Download clients (qBittorrent, NZBGet) are ONLY used by the arr services
- Prowlarr syncs indexers to all arr services
- Arr services send downloads to qBittorrent/NZBGet
- All services share the same Docker network
- VPN killswitch ensures torrents never expose your IP
- Consolidated management and updates

## Key Features

### VPN Killswitch (Critical)
Gluetun provides a **VPN killswitch** for qBittorrent:
- qBittorrent uses `network_mode: service:gluetun`
- ALL qBittorrent traffic routes through the VPN
- If VPN drops, qBittorrent loses connectivity (no IP leaks)
- qBittorrent WebUI accessed through Gluetun's port mapping

**IMPORTANT**: Never change qBittorrent's network mode. The killswitch only works because qBittorrent uses Gluetun's network stack.

### Environment Variables
Flexible configuration with sensible defaults:
- `PUID`/`PGID` - User/group IDs (default: 1027/100)
- `TZ` - Timezone (default: America/Edmonton)
- `CONFIG_STORAGE` - Config storage path (default: /volume1/configs)
- `MEDIA_STORAGE` - Media storage path (default: /volume1/data)
- `OPENVPN_USER`/`OPENVPN_PASSWORD` - VPN credentials (REQUIRED)
- Port overrides available for all services

See `.env.example` for all options.

### Container Naming
All containers use `media-` prefix for easy identification:
- `media-gluetun`, `media-qbittorrent`, `media-nzbget`
- `media-prowlarr`, `media-sonarr`, `media-radarr`, etc.

## Setup Order

1. **Copy and configure .env file**:
   ```bash
   cp .env.example .env
   nano .env  # Add your VPN credentials
   ```

2. **Ensure VPN config file exists**:
   - File: `/volume1/docker/gluetun/getflix/Canada-Toronto_TCP1194_SMART.ovpn`
   - Or update path in compose.yaml

3. **Create media-network** (if it doesn't exist):
   ```bash
   docker network create media-network
   ```

4. **Start the stack** in Arcane or via Docker Compose

5. **Configure services in order**:
   1. **FlareSolverr** - No config needed, runs automatically
   2. **Prowlarr** (http://192.168.0.56:9696)
      - Add FlareSolverr: Settings > Indexers > FlareSolverr
        - Host: `http://media-flaresolverr:8191`
        - Tag: `flaresolverr`
      - Add indexers (tag with `flaresolverr` for protected sites)
   3. **Download Clients**:
      - Add qBittorrent in Prowlarr/arr services
        - Host: `media-gluetun` (not `media-qbittorrent`!)
        - Port: 8200
      - Add NZBGet in arr services
        - Host: `media-nzbget`
        - Port: 6789
   4. **Sonarr/Radarr/Lidarr/Readarr** - Link to Prowlarr and download clients
   5. **Bazarr** - Link to Sonarr/Radarr for subtitle automation

## Network Configuration

All services use the `media-network` Docker network. This allows them to communicate using container names:
- Prowlarr talks to FlareSolverr at `media-flaresolverr:8191`
- Arr services talk to qBittorrent at `media-gluetun:8200` (through VPN)
- Arr services talk to NZBGet at `media-nzbget:6789`

**Exception**: qBittorrent uses Gluetun's network stack, so other services reference `media-gluetun` for qBittorrent.

## Volume Structure

```
/volume1/data/
├── media/          # Final media location
│   ├── tv/
│   ├── movies/
│   ├── music/
│   └── books/
├── torrents/       # Torrent downloads
│   ├── complete/
│   └── incomplete/
└── usenet/         # Usenet downloads
    ├── complete/
    └── incomplete/
```

## Configuration Paths

Each service stores its config in `/volume1/docker/<service>/`

## Access Services

Once running, access services at:
- http://192.168.0.56:8200 - qBittorrent
- http://192.168.0.56:5678 - NZBGet  
- http://192.168.0.56:9696 - Prowlarr
- http://192.168.0.56:8989 - Sonarr
- http://192.168.0.56:7878 - Radarr
- http://192.168.0.56:8686 - Lidarr
- http://192.168.0.56:8787 - Readarr
- http://192.168.0.56:6767 - Bazarr
- http://192.168.0.56:9117 - Jackett

**Nginx Proxy Manager**: Configure reverse proxy rules in NPM pointing to these IPs and ports. No special Docker labels needed.

## Updating

Use Arcane's "Redeploy" button to pull latest images and restart all services.

## Troubleshooting

**Services can't find each other**: 
- Verify all are on `media-network`
- Check container names match expectations

**qBittorrent not accessible**:
- Access via Gluetun's port: http://192.168.0.56:8200
- Check Gluetun container is running: `docker ps | grep media-gluetun`
- Check VPN connection: `docker logs media-gluetun`

**VPN not connecting**:
1. Verify credentials in `.env` file
2. Check VPN config file exists and path is correct
3. Check Gluetun logs: `docker logs media-gluetun`
4. Ensure `/dev/net/tun` device is available

**Cloudflare-protected indexers failing**:
1. Ensure FlareSolverr is running: `docker ps | grep media-flaresolverr`
2. Add FlareSolverr in Prowlarr (Settings > Indexers > FlareSolverr)
3. Tag indexers with `flaresolverr` to enable bypass
4. Check FlareSolverr logs: `docker logs media-flaresolverr`

**Import failures**: 
- Check volume paths are consistent across all services
- Verify PUID/PGID permissions

**Prowlarr not syncing**: 
- Check API keys and connections in each *arr app
- Verify network connectivity between containers

**Environment variables not working**: 
- Copy `.env.example` to `.env` and customize values
- Ensure `.env` file is in same directory as compose.yaml

**Torrent IP leak concerns**:
- Verify qBittorrent is using Gluetun network: `docker inspect media-qbittorrent | grep NetworkMode`
- Should show: `"NetworkMode": "container:media-gluetun"`
- Test IP: Go to qBittorrent WebUI and check connection status
- Download a torrent from https://torguard.net/checkmytorrentipaddress.php to verify VPN IP

## Migration from Old Structure

If migrating from separate arr-stack and downloads stacks:

1. **Stop old stacks** in Arcane/Portainer
2. **Config directories stay the same** - No need to move files
3. **Deploy new media-automation stack**
4. **Update download client settings** in arr services to use new container names:
   - qBittorrent host: `media-gluetun` (was `gluetun`)
   - NZBGet host: `media-nzbget` (was `nzbget`)
5. **Remove old projects** from Arcane after confirming everything works

## Security Notes

- VPN credentials stored in `.env` file (gitignored)
- Never commit `.env` to Git
- Gluetun killswitch prevents IP leaks if VPN drops
- qBittorrent has no direct network access without VPN
