# Media Servers

This category contains media server applications that stream and organize your media content for viewing/listening.

## Services

### Plex
- **Directory**: `plex/`
- **Container**: plex
- **Image**: plexinc/pms-docker
- **Purpose**: Full-featured media server with streaming apps for all platforms
- **Features**:
  - Automatic metadata and artwork
  - Transcoding for multiple devices
  - Remote access
  - Watch status sync across devices
  - Live TV & DVR (with tuner)
- **Web UI**: http://192.168.0.56:32400/web
- **Note**: Most popular and feature-rich option

### Jellyfin
- **Directory**: `jellyfin/`
- **Container**: jellyfin
- **Purpose**: Free and open-source alternative to Plex
- **Features**:
  - No premium subscription required
  - Complete control over your data
  - Plugin system for extensibility
  - Hardware transcoding support
  - Live TV & DVR
- **Advantages**: No tracking, no account required, truly free
- **Web UI**: Check compose file for port

### Navidrome
- **Directory**: `navidrome/`
- **Container**: navidrome
- **Purpose**: Lightweight music streaming server
- **Features**:
  - Subsonic/Airsonic API compatible
  - Works with mobile apps (DSub, Ultrasonic, etc.)
  - Transcoding support
  - Playlist management
  - Multi-user support
- **Best For**: Music-only streaming
- **Integration**: Works alongside Lidarr for music management

### Tdarr
- **Directory**: `tdarr/`
- **Container**: tdarr
- **Purpose**: Media transcoding and library management
- **Features**:
  - Automated transcoding workflows
  - Cluster transcoding support
  - Health checks for media files
  - Plugin system for custom operations
  - GPU acceleration support
- **Use Case**: Batch convert media to save space or standardize formats

## Choosing Your Media Server

### Use Plex if:
- You want the most polished user experience
- You need remote access with minimal setup
- You want apps on every platform
- You're okay with a Plex account

### Use Jellyfin if:
- You want complete privacy and control
- You don't want to rely on external services
- You prefer open-source software
- You're comfortable with some manual configuration

### Use Both if:
- You want redundancy
- You're testing/comparing
- Different users have different preferences

### Use Navidrome for:
- Music-only streaming
- Subsonic API compatibility
- Lightweight music server separate from video

### Use Tdarr for:
- Reducing library size via transcoding
- Standardizing video/audio formats
- Automated quality management
- Health checking your media files

## Integration with Media Management

Both Plex and Jellyfin integrate with your Servarr stack:

```
Sonarr/Radarr → Downloads → Import → /volume1/data/media/ → Plex/Jellyfin scans
```

## Library Paths

Configure your media servers to watch these directories:

```
TV Shows: /volume1/data/media/tv/
Movies: /volume1/data/media/movies/
Music: /volume1/data/media/music/
Books/Audiobooks: /volume1/data/media/books/
```

## Hardware Transcoding

If your Synology supports hardware transcoding:

- **Plex**: Requires Plex Pass subscription
- **Jellyfin**: Free hardware transcoding support
- Enable via device passthrough in compose file: `/dev/dri`

## Performance Tips

- **Disable thumbnail generation** for large libraries (or do it once, then disable)
- **Pre-optimize media** with Tdarr to reduce transcoding load
- **Use direct play** when possible (matching client capabilities)
- **Consider network storage performance** when streaming 4K

## Remote Access

### Plex
- Built-in remote access via plex.tv
- Enable in Settings → Network → Remote Access

### Jellyfin
- Requires manual port forwarding or reverse proxy
- Consider using Cloudflare Tunnel or Tailscale for secure access

## Troubleshooting

**Library not updating**: Trigger manual scan, check folder permissions

**Transcoding failing**: Check hardware acceleration settings, verify device passthrough

**Buffering issues**: Check network speed, consider pre-transcoding with Tdarr

**Metadata wrong**: Check agents/scrapers, manually identify content, refresh metadata

**Can't connect remotely**: Verify port forwarding, check firewall rules

## Maintenance

- **Update regularly** via Arcane for security and features
- **Scan libraries** after adding new media
- **Clean bundles** periodically to free up space (Plex)
- **Optimize database** to maintain performance
- **Backup metadata** and watch status regularly
