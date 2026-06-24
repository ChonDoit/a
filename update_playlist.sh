#!/bin/bash

playlist_path="/sdcard/a"
playlist="ar.m3u"

# Define the IDs you want to update
ids=(
    "ArKbAx1K-2U" #A24
    "Qr61waJ6AZg" #CNÑ
    "JC7f3EUDaqw" #Cronica
    "eKfPZ6f0SQw" #Diputados
    "FEWZjXJ7M0c" #LN+
    "cb12KmMMDJA" #TodoNoticias
    "VWhQ6xspnSc" #C5N
    "xZFnLFX6C1Y" #TVPublica
)

pushd $playlist_path

# 1. Create a Backup
backup_file="${playlist}.$(date +%Y%m%d_%H%M).bak"
cp "$playlist" "backups/$backup_file"
echo "Backup created: $backup_file"

# 2. Iterate through IDs
echo "Starting update: $(date)"
for id in "${ids[@]}"; do
    echo ""
    echo "Processing ID: $id"
    
    format_used=""
    new_url=""
    
    # Try Format 96 first
    new_url=$(timeout 30 yt-dlp -f 96 -g "https://www.youtube-nocookie.com/embed/$id" 2>/dev/null | grep -E '^https?://')
    if [ -n "$new_url" ]; then
        format_used="96"
    fi
    
    # Fallback to Format 95 if 96 is empty
    if [ -z "$new_url" ]; then
        echo "   [!] Format 96 not found."
        new_url=$(timeout 30 yt-dlp -f 95 -g "https://www.youtube-nocookie.com/embed/$id" 2>/dev/null | grep -E '^https?://')
        if [ -n "$new_url" ]; then
            format_used="95"
        fi
    fi
    
    # If both fail, try without format (let yt-dlp choose)
    if [ -z "$new_url" ]; then
        echo "   [!] Format 95 not found."
        new_url=$(timeout 30 yt-dlp -g "https://www.youtube-nocookie.com/embed/$id" 2>/dev/null | grep -E '^https?://')
        if [ -n "$new_url" ]; then
            format_used="default (auto-selected)"
        fi
    fi
    
    # Update the file if a URL was found
    if [ -n "$new_url" ]; then
        if grep -q "tvg-id=\"$id\"" "$playlist"; then
            sed -i "/tvg-id=\"$id\"/{n; s|.*|$new_url|;}" "$playlist"
            echo "   [+] Success (Format: $format_used)"
        else
            echo "   [-] ID $id not found in playlist file."
        fi
    else
        echo "   [X] Failed: No URL returned after trying all formats."
    fi
done

echo ""
echo "• Commit changes"
git add logos
# git add $playlist
git commit --all -q -m "Regulary update"

echo "• Pushing changes"
git push -q -f

echo "• Pushing release"
gh release upload --clobber AR $playlist

echo "• Process complete."
echo ""

popd