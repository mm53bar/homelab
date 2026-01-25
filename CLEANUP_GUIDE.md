# Cleaning Up /volume1/docker/ Directory

After rsync completes, clean up old config directories to start fresh with Arcane.

## Step 1: Move Media Automation Configs (PRESERVE SETTINGS)

**IMPORTANT**: Don't delete these - MOVE them to preserve all your settings!

```bash
# Move old configs to new names (keeps all your indexers, quality profiles, etc.)
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
```

**Note**: If any of these directories don't exist, that's fine - skip them.

**Special case - Shelfmark:**
```bash
# If you have the old calibre-web-automated-book-downloader directory, rename it:
if [ -d "/volume1/docker/calibre-web-automated-book-downloader" ]; then
  mv /volume1/docker/calibre-web-automated-book-downloader/ /volume1/docker/shelfmark/
  echo "Renamed calibre-web-automated-book-downloader → shelfmark"
fi
```

## Step 2: Delete Unused Service Configs

Now delete configs for services that are no longer used:

```bash
# Old compose structure (no longer used)
rm -rf /volume1/docker/arr-stack/

# Unused download client
rm -rf /volume1/docker/transmission/

# Inactive book services
rm -rf /volume1/docker/calibre/
rm -rf /volume1/docker/calibre-web/
rm -rf /volume1/docker/kavita/
rm -rf /volume1/docker/lazylibrarian/
rm -rf /volume1/docker/lazylibrarian2/
rm -rf /volume1/docker/mylar3/

# Inactive dashboards
rm -rf /volume1/docker/heimdall/
rm -rf /volume1/docker/homepage/
rm -rf /volume1/docker/organizr/

# Inactive media servers (run on different machines or unused)
rm -rf /volume1/docker/jellyfin/
rm -rf /volume1/docker/navidrome/
rm -rf /volume1/docker/plex/
rm -rf /volume1/docker/tdarr/

# Home Assistant (runs on different machine)
rm -rf /volume1/docker/homeassistant/
rm -rf /volume1/docker/home-assistant/

# Inactive utilities
rm -rf /volume1/docker/omada-controller/
rm -rf /volume1/docker/tellytv/
rm -rf /volume1/docker/syncarr/
rm -rf /volume1/docker/photostructure/

# Note: youtube-dl config is KEPT (still in use, will migrate later)
```

## STOP - Important Notes

**Before running cleanup:**

1. **Verify rsync completed** from `/volume1/configs/` to `/volume1/docker/`
2. **Read through ALL commands** - understand what's being moved vs deleted
3. **Consider taking a Synology snapshot** of `/volume1/docker/` first

**After cleanup:**

1. **Deploy media-automation** from Arcane
2. **Verify all services start** and can access their configs
3. **Test one arr service** - can it connect to download clients?
4. **If something's wrong**, restore from `/volume1/configs/` backup

## Optional: Clean Up Large Files

### Database Backups
```bash
# PostgreSQL backups (if you have external backups)
du -sh /volume1/docker/postgresql/backups/
# Consider keeping only recent backups

# Paperless backups
du -sh /volume1/docker/paperless-ngx/export/
```

### Container Logs
```bash
# Find large log files
find /volume1/docker/ -name "*.log" -size +100M -exec ls -lh {} \;

# Truncate logs (be careful!)
# Example: truncate large log file
# > /volume1/docker/service/large.log
```

### Immich/Photo Libraries
```bash
# Immich can be VERY large
du -sh /volume1/docker/immich/

# This is your photo library - don't delete without backups!
# But you can check for duplicates or failed uploads
```

### Download Client Cache
```bash
# qBittorrent session/resume data (only after moving to media-qbittorrent)
du -sh /volume1/docker/media-qbittorrent/qBittorrent/BT_backup/

# NZBGet temp files (only after moving to media-nzbget)
du -sh /volume1/docker/media-nzbget/tmp/
```

## After Migration is Complete

Once everything is working in Arcane:

```bash
# Remove the configs shared folder entirely
# Via DSM: Control Panel → Shared Folder → Delete "configs"

# Or via SSH:
sudo synoshare --del configs

# This frees up the directory name
```

## Recommended Cleanup Order

1. ✅ **Complete rsync** from configs to docker
2. **Run Step 1** - Move media automation configs (mv commands)
3. **Run Step 2** - Delete unused configs (rm commands)
4. **Run Step 3** - Verify active configs remain
5. **Deploy media-automation** from Arcane
6. **Test services** - verify everything works
7. **After success** - optionally delete `/volume1/configs/`

## Step 3: Verify Active Service Configs Remain

These are your 14 active projects - **verify these directories still exist**:

```bash
# Media Automation (new - will be created after mv commands)
/volume1/docker/media-gluetun/
/volume1/docker/media-qbittorrent/
/volume1/docker/media-nzbget/
/volume1/docker/media-prowlarr/
/volume1/docker/media-jackett/
/volume1/docker/media-sonarr/
/volume1/docker/media-radarr/
/volume1/docker/media-lidarr/
/volume1/docker/media-readarr/
/volume1/docker/media-bazarr/

# Books
/volume1/docker/calibre-web-automated/
/volume1/docker/shelfmark/  # Renamed from calibre-web-automated-book-downloader

# Dashboards
/volume1/docker/homer/

# Database
/volume1/docker/postgresql/

# Personal
/volume1/docker/forgejo/
/volume1/docker/mealie/
/volume1/docker/paperless-ngx/
/volume1/docker/wallabag/

# Photos
/volume1/docker/icloudpd/
/volume1/docker/immich/

# Utilities
/volume1/docker/isponsorblock/
/volume1/docker/pinchflat/
/volume1/docker/trmnl/
/volume1/docker/youtube-dl/

# Arcane
/volume1/docker/arcane/
```

**Quick check**:
```bash
ls /volume1/docker/ | grep -E "(media-|calibre-web-automated|homer|postgresql|forgejo|mealie|paperless-ngx|wallabag|icloudpd|immich|isponsorblock|pinchflat|trmnl|arcane)"
```

## Summary

### What This Cleanup Does:

✅ **Moves** media automation configs (preserves your settings)  
✅ **Deletes** unused service configs (frees 5-20GB)  
✅ **Keeps** all 14 active project configs intact  

### Space Savings Estimate:
- Old inactive services: ~2-5GB
- Home Assistant history/logs: 1-10GB
- Transmission cache: ~100-500MB
- **Total: 5-20GB freed**

### After Running These Commands:

1. `/volume1/docker/` will have:
   - 10 renamed media-automation configs (media-*)
   - 14 other active service configs
   - No old/unused configs

2. `/volume1/configs/` still has backups of everything

3. Ready to deploy from Arcane!

## Safety Tips

✅ **Do**: Make a snapshot/backup before major deletions  
✅ **Do**: Test one service first before mass cleanup  
✅ **Do**: Check disk space: `df -h /volume1/`  
❌ **Don't**: Delete active service configs  
❌ **Don't**: Delete database files without backups  
❌ **Don't**: Rush - verify each step  

## If Something Goes Wrong

If you accidentally delete something needed:

1. **Stop containers**
2. **Re-run rsync** from `/volume1/configs/` (if you haven't deleted it yet)
3. **Or restore from Synology snapshot/backup**
4. **Redeploy from Arcane** (will recreate config dirs with defaults)

---

**Current Status**: Your rsync is moving files from `/volume1/configs/` → `/volume1/docker/`  
**Next Step**: Wait for rsync to complete, then test deploying from Arcane  
**Then**: Clean up old/inactive configs safely
