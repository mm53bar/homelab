#!/bin/bash
# Cleanup script for /volume1/docker/ after rsync completes
# Run this on your Synology NAS via SSH

set -e  # Exit on error

echo "======================================"
echo "Homelab Config Cleanup Script"
echo "======================================"
echo ""
echo "This script will:"
echo "1. MOVE media automation configs (preserves settings)"
echo "2. DELETE unused service configs"
echo ""
read -p "Have you verified rsync completed? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted. Complete rsync first."
    exit 1
fi

echo ""
echo "======================================"
echo "Step 1: Moving Media Automation Configs"
echo "======================================"

# Function to safely move directory
move_if_exists() {
    if [ -d "$1" ]; then
        echo "Moving $1 → $2"
        mv "$1" "$2"
    else
        echo "Skipping $1 (doesn't exist)"
    fi
}

move_if_exists "/volume1/docker/gluetun" "/volume1/docker/media-gluetun"
move_if_exists "/volume1/docker/qbittorrent" "/volume1/docker/media-qbittorrent"
move_if_exists "/volume1/docker/nzbget" "/volume1/docker/media-nzbget"
move_if_exists "/volume1/docker/prowlarr" "/volume1/docker/media-prowlarr"
move_if_exists "/volume1/docker/jackett" "/volume1/docker/media-jackett"
move_if_exists "/volume1/docker/sonarr" "/volume1/docker/media-sonarr"
move_if_exists "/volume1/docker/radarr" "/volume1/docker/media-radarr"
move_if_exists "/volume1/docker/lidarr" "/volume1/docker/media-lidarr"
move_if_exists "/volume1/docker/readarr" "/volume1/docker/media-readarr"
move_if_exists "/volume1/docker/bazarr" "/volume1/docker/media-bazarr"

echo ""
echo "======================================"
echo "Step 2: Deleting Unused Configs"
echo "======================================"

# Function to safely delete directory
delete_if_exists() {
    if [ -d "$1" ]; then
        echo "Deleting $1"
        rm -rf "$1"
    else
        echo "Skipping $1 (doesn't exist)"
    fi
}

# Old compose structure
delete_if_exists "/volume1/docker/arr-stack"

# Unused download client
delete_if_exists "/volume1/docker/transmission"

# Inactive book services
delete_if_exists "/volume1/docker/calibre"
delete_if_exists "/volume1/docker/calibre-web"
delete_if_exists "/volume1/docker/kavita"
delete_if_exists "/volume1/docker/lazylibrarian"
delete_if_exists "/volume1/docker/lazylibrarian2"
delete_if_exists "/volume1/docker/mylar3"

# Inactive dashboards
delete_if_exists "/volume1/docker/heimdall"
delete_if_exists "/volume1/docker/homepage"
delete_if_exists "/volume1/docker/organizr"

# Inactive media servers
delete_if_exists "/volume1/docker/jellyfin"
delete_if_exists "/volume1/docker/navidrome"
delete_if_exists "/volume1/docker/plex"
delete_if_exists "/volume1/docker/tdarr"

# Home Assistant (runs elsewhere)
delete_if_exists "/volume1/docker/homeassistant"
delete_if_exists "/volume1/docker/home-assistant"

# Inactive utilities
delete_if_exists "/volume1/docker/omada-controller"
delete_if_exists "/volume1/docker/tellytv"
delete_if_exists "/volume1/docker/youtube-dl"
delete_if_exists "/volume1/docker/syncarr"
delete_if_exists "/volume1/docker/photostructure"

echo ""
echo "======================================"
echo "Step 3: Verifying Active Configs"
echo "======================================"

EXPECTED_DIRS=(
    "media-gluetun"
    "media-qbittorrent"
    "media-nzbget"
    "media-prowlarr"
    "media-jackett"
    "media-sonarr"
    "media-radarr"
    "media-lidarr"
    "media-readarr"
    "media-bazarr"
    "calibre-web-automated"
    "calibre-web-automated-book-downloader"
    "homer"
    "postgresql"
    "forgejo"
    "mealie"
    "paperless-ngx"
    "wallabag"
    "icloudpd"
    "immich"
    "isponsorblock"
    "pinchflat"
    "trmnl"
    "arcane"
)

echo "Checking for active service configs..."
MISSING=0
for dir in "${EXPECTED_DIRS[@]}"; do
    if [ -d "/volume1/docker/$dir" ]; then
        echo "✓ $dir"
    else
        echo "✗ $dir (MISSING!)"
        MISSING=$((MISSING + 1))
    fi
done

echo ""
if [ $MISSING -gt 0 ]; then
    echo "⚠️  WARNING: $MISSING expected directories are missing!"
    echo "   This might be okay if you didn't have those services configured."
else
    echo "✓ All expected directories found!"
fi

echo ""
echo "======================================"
echo "Cleanup Complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. Deploy media-automation from Arcane"
echo "2. Verify all services start correctly"
echo "3. Check that settings were preserved"
echo "4. Update download client hostnames in arr services"
echo ""
echo "Backup still available in /volume1/configs/"
