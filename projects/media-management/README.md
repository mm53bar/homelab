# Media Management (Servarr Stack)

This category contains the suite of media management tools commonly known as the "Servarr stack" - automated tools for organizing and acquiring media content.

## Services

### Sonarr (TV Shows)
- **Directory**: `sonarr/`
- **Port**: Check compose file
- **Purpose**: Automated TV show download and management
- **Features**: Episode tracking, quality upgrades, calendar, series monitoring

### Sonarr-SD (Standard Definition)
- **Directory**: `sonarr-sd/`
- **Purpose**: Separate Sonarr instance for standard definition TV content
- **Use Case**: Managing older or SD-only content separately from HD/4K content

### Radarr (Movies)
- **Directory**: `radarr/`
- **Port**: Check compose file
- **Purpose**: Automated movie download and management
- **Features**: Movie discovery, quality profiles, automatic upgrades
- **Note**: Has `.env` file with environment variables

### Radarr-SD (Standard Definition)
- **Directory**: `radarr-sd/`
- **Purpose**: Separate Radarr instance for standard definition movies
- **Note**: Has `.env` file with environment variables

### Lidarr (Music)
- **Directory**: `lidarr/`
- **Purpose**: Automated music collection management
- **Features**: Artist/album monitoring, quality management, metadata tagging

### Readarr (Books/Audiobooks)
- **Directory**: `readarr/`
- **Purpose**: Automated book and audiobook management
- **Features**: Author monitoring, edition management, metadata handling

### Prowlarr (Indexer Manager)
- **Directory**: `prowlarr/`
- **Purpose**: Centralized indexer management for all *arr apps
- **Features**: Sync indexers across Sonarr, Radarr, Lidarr, Readarr automatically
- **Important**: Configure this first before other *arr apps

### Bazarr (Subtitles)
- **Directory**: `bazarr/`
- **Purpose**: Automated subtitle download and management
- **Integration**: Works with Sonarr and Radarr to fetch subtitles for your media

### Jackett (Torrent Indexer Proxy)
- **Directory**: `jackett/`
- **Purpose**: API wrapper for torrent trackers
- **Note**: Consider migrating to Prowlarr for better integration

### Syncarr (Sync Tool)
- **Directory**: `syncarr/`
- **Purpose**: Sync content between multiple Sonarr/Radarr instances
- **Use Case**: Keeping your SD and HD instances in sync

## Network Configuration

Most services use the `media-network` Docker network for inter-service communication.

## Common Configuration

All services typically use:
- **PUID**: 1027
- **PGID**: 100
- **TZ**: America/Edmonton
- **Volume paths**: `/volume1/docker/<service>/` for configs
- **Media paths**: `/volume1/data/` for media storage

## Setup Order

1. **Prowlarr** - Set up indexers first
2. **Download client** (See downloads category) - Configure NZBGet or qBittorrent
3. **Sonarr/Radarr/Lidarr/Readarr** - Configure and link to Prowlarr
4. **Bazarr** - Link to Sonarr/Radarr for subtitle automation

## Typical Workflow

1. Add media to Sonarr/Radarr/Lidarr/Readarr
2. Services search indexers via Prowlarr
3. Send download to NZBGet/qBittorrent
4. Media is organized and renamed upon completion
5. Bazarr fetches subtitles automatically
6. Media appears in your media server (Plex/Jellyfin)

## Maintenance Tips

- Check for updates regularly via Arcane
- Monitor failed downloads in each service's Activity/Queue
- Verify Prowlarr indexers are syncing properly
- Clear old logs periodically
- Backup configuration directories regularly

## Troubleshooting

**Services can't communicate**: Verify they're on the same Docker network

**No search results**: Check Prowlarr indexers and sync status

**Files not importing**: Check file permissions (PUID/PGID) and folder paths

**Quality not upgrading**: Review quality profiles and cutoff settings in each service
