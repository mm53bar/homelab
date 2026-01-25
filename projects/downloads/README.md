# Downloads

This category contains download clients and VPN services for safely and efficiently downloading content.

## Services

### NZBGet
- **Directory**: `nzbget/`
- **Type**: Usenet downloader
- **Port**: 5678 (mapped from 6789)
- **Purpose**: Lightweight, efficient Usenet/NZB downloader
- **Features**: RSS feeds, post-processing scripts, category management
- **Network**: media-network

### qBittorrent
- **Directory**: `qbittorrent/`
- **Type**: Torrent client
- **Purpose**: Feature-rich BitTorrent client with web interface
- **Features**: Web UI, RSS feeds, sequential downloading, search plugins

### Transmission
- **Directory**: `transmission/`
- **Type**: Torrent client with OpenVPN
- **Image**: `haugene/transmission-openvpn:dev`
- **Purpose**: BitTorrent client with built-in VPN support
- **Features**: Automatic VPN connection, torrent management, web interface
- **Security**: All traffic routed through VPN

### Gluetun
- **Directory**: `gluetun/`
- **Type**: VPN client
- **Purpose**: Lightweight VPN client that other containers can route through
- **Features**: Multi-provider support, killswitch, port forwarding
- **Use Case**: Route other containers (like qBittorrent) through VPN

## Integration with Media Management

All download clients integrate with the Servarr stack (Sonarr, Radarr, Lidarr, Readarr):

1. *arr apps search for content via Prowlarr
2. Download is sent to NZBGet or qBittorrent/Transmission
3. Client downloads and notifies *arr app when complete
4. *arr app imports, renames, and organizes the media

## Configuration Notes

### NZBGet Setup
- Configure Usenet server details in settings
- Set up categories matching your *arr apps
- Enable post-processing scripts if needed
- Map download paths correctly to match *arr apps

### qBittorrent Setup
- Set up download paths
- Configure categories for different media types
- Enable web UI authentication
- Consider routing through Gluetun for VPN

### Transmission Setup
- Configure VPN credentials in environment variables
- Set LOCAL_NETWORK to allow LAN access
- Map volumes for downloads and config

### Gluetun Setup
- Configure VPN provider credentials
- Set up port forwarding if needed
- Other containers can use `network_mode: "service:gluetun"`

## Security Best Practices

1. **Use VPN for torrent traffic**: Route qBittorrent through Gluetun or use Transmission with built-in VPN
2. **Don't use VPN for Usenet**: NZBGet traffic is already encrypted via SSL
3. **Verify killswitch**: Ensure no traffic leaks if VPN disconnects
4. **Check IP**: Test download client is showing VPN IP, not your real IP

## Paths Configuration

Ensure consistent paths between download clients and media management:

```
/volume1/data/
├── usenet/           # NZBGet downloads
│   ├── complete/
│   └── incomplete/
├── torrents/         # qBittorrent/Transmission downloads  
│   ├── complete/
│   └── incomplete/
└── media/           # Final media location
    ├── tv/
    ├── movies/
    ├── music/
    └── books/
```

## Performance Tips

- **NZBGet**: Adjust ArticleCache and WriteBuffer for your system
- **qBittorrent**: Limit active torrents to prevent resource exhaustion
- **Transmission**: Adjust peer limits based on your connection
- **Gluetun**: Monitor VPN connection stability

## Troubleshooting

**Download client not connecting**: Check VPN connection if using Gluetun

**Import failures**: Verify paths match between download client and *arr apps

**Slow downloads**: Check connection limits, VPN speed, server congestion

**VPN disconnects**: Check credentials, try different VPN servers

**Cannot access web UI**: Verify port mappings and network configuration
