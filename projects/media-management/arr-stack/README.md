# Media Management Stack (Arr Suite)

This consolidated compose file contains all media management services that work together in the "Servarr" ecosystem.

## Services Included

- **FlareSolverr** - Cloudflare bypass for protected indexers (port 8191)
- **Prowlarr** - Centralized indexer manager (port 9696)
- **Sonarr** - TV show management (port 8989)
- **Radarr** - Movie management (port 7878)
- **Lidarr** - Music management (port 8686)
- **Readarr** - Book/audiobook management (port 8787)
- **Bazarr** - Subtitle management (port 6767)
- **Jackett** - Torrent indexer proxy (port 9117) - *Legacy, consider migrating to Prowlarr*

## Why Consolidated?

All these services:
- Share the same Docker network (`media-network`)
- Need to communicate with each other
- Use the same volume structure (`/volume1/data`)
- Have similar configuration (PUID, PGID, TZ)
- Work as a cohesive media automation pipeline

## Key Features

### FlareSolverr Integration
Helps Prowlarr bypass Cloudflare protection on indexers. No manual configuration needed - Prowlarr can detect and use it automatically at `http://arr-flaresolverr:8191`.

### Environment Variables
Flexible configuration using environment variables with sensible defaults:
- `PUID` / `PGID` - User/group IDs (default: 1027/100)
- `TZ` - Timezone (default: America/Edmonton)
- `DOCKER_VOLUME_STORAGE` - Config storage path (default: /volume1/docker)
- `MEDIA_STORAGE` - Media storage path (default: /volume1/data)
- Port overrides available for all services

See `.env.example` for all options.

### Container Naming
All containers use `arr-` prefix for easy identification:
- `arr-prowlarr`, `arr-sonarr`, `arr-radarr`, etc.

### Reverse Proxy Ready
Commented Traefik labels included for easy reverse proxy setup. Simply uncomment and configure for HTTPS access via domain names.

## Separate Instances

The following service has its own compose file:

### Syncarr
**Location**: `syncarr/`

**Why separate**: Utility for syncing library metadata between multiple Sonarr/Radarr instances. Has different lifecycle than the main arr services.

## Setup Order

1. **Start arr-stack** (this file)
2. **Configure FlareSolverr in Prowlarr** (Settings > Indexers > Add FlareSolverr):
   - Tags: `flaresolverr`
   - Host: `http://arr-flaresolverr:8191`
   - Add the tag to indexers that need Cloudflare bypass
3. Configure **Prowlarr** - add indexers
4. Configure **Sonarr/Radarr/Lidarr/Readarr** - link to Prowlarr and download clients
5. Configure **Bazarr** - link to Sonarr/Radarr for subtitle automation

## Network Configuration

All services use the `media-network` Docker network. Create it if it doesn't exist:

```bash
docker network create media-network
```

Or let Docker Compose create it by removing the `external: true` line.

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
- http://192.168.0.56:9696 - Prowlarr
- http://192.168.0.56:8989 - Sonarr
- http://192.168.0.56:7878 - Radarr
- http://192.168.0.56:8686 - Lidarr
- http://192.168.0.56:8787 - Readarr
- http://192.168.0.56:6767 - Bazarr
- http://192.168.0.56:9117 - Jackett

## Updating

Use Arcane's "Redeploy" button to pull latest images and restart all services.

## Troubleshooting

**Services can't find each other**: Verify all are on `media-network`

**Import failures**: Check volume paths are consistent across all services

**Prowlarr not syncing**: Check API keys and connections in each *arr app

**Cloudflare-protected indexers failing**: 
1. Ensure FlareSolverr is running: `docker ps | grep arr-flaresolverr`
2. Add FlareSolverr in Prowlarr (Settings > Indexers > FlareSolverr)
3. Tag indexers with `flaresolverr` to enable bypass
4. Check FlareSolverr logs: `docker logs arr-flaresolverr`

**Environment variables not working**: Copy `.env.example` to `.env` and customize values
