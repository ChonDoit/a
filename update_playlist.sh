#!/bin/bash

playlist_path="/sdcard/a"
playlist="ar.m3u"

# Define the IDs you want to update
ids=(
    "ArKbAx1K-2U" #A24
    "Qr61waJ6AZg" #CNÑ
    "JC7f3EUDaqw" #Cronica
    "rBEBUQ0eljM" #Diputados
    "DVZ2rJQb_0g" #LN+
    "XhAYcYpPzTc" #Telefe Noticias
    "cb12KmMMDJA" #TodoNoticias
    "Bi7vMAqkYCg" #91.9
    "FV1MrtwGx20" #98.3
    "vGNglKWqwcQ" #Quiero
    "V6RlyFXQu6I" #Canal9
    "QcyJONgBcvM" #ElOnce
    "Hf3f-tlCFPw" #ElOnceRadio
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
    
    # Try Format 96 First with timeout protection (30 seconds max)
    new_url=$(timeout 30 yt-dlp -f 96 -g "https://www.youtube-nocookie.com/embed/$id" 2>/dev/null | grep -E '^https?://')
    if [ -n "$new_url" ]; then
        format_used="96"
    fi
    
    # Fallback to Format 95 if 96 is empty
    if [ -z "$new_url" ]; then
        echo "   [!] Format 96 not found or timed out. Trying fallback Format 95..."
        new_url=$(timeout 30 yt-dlp -f 95 -g "https://www.youtube-nocookie.com/embed/$id" 2>/dev/null | grep -E '^https?://')
        if [ -n "$new_url" ]; then
            format_used="95"
        fi
    fi
    
    # If both fail, try without format (let yt-dlp choose)
    if [ -z "$new_url" ]; then
        echo "   [!] Format 95 not found. Trying default (best available)..."
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