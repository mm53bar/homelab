# Media Management Stack (Arr Suite)

This consolidated compose file contains all media management services that work together in the "Servarr" ecosystem.

## Services Included

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

## Separate Instances

The following services have their own compose files for specific reasons:

### Sonarr-SD & Radarr-SD
**Location**: `sonarr-sd/` and `radarr-sd/`

**Why separate**: Dedicated instances for standard definition content with different quality profiles and root folders.

### Syncarr
**Location**: `syncarr/`

**Why separate**: Utility that syncs between multiple instances (HD ↔ SD), separate lifecycle.

## Setup Order

1. **Start arr-stack** (this file)
2. Configure **Prowlarr** first - add indexers
3. Configure **Sonarr/Radarr/Lidarr/Readarr** - link to Prowlarr and download clients
4. Configure **Bazarr** - link to Sonarr/Radarr for subtitle automation

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
