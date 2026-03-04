#!/bin/bash

playlist_path="/sdcard/a"
playlist="ar.m3u"

# Define the IDs you want to update
ids=(
    "ArKbAx1K-2U" #A24
    "SF06Qy1Ct6Y" #C5N
    "9wbcm196NT8" #C26
    "Qr61waJ6AZg" #CNÑ
    "JC7f3EUDaqw" #Cronica
    "G6W51ntv4M0" #Diputados
    "M_gUd2Bp9g0" #LN+
    "XhAYcYpPzTc" #Telefe Noticias
    "zrCQt4bm-Qc" #Telefe Rosario
    "cb12KmMMDJA" #TN
    "Bi7vMAqkYCg" #91.9
    "x5fbS_4RrFU" #97.5
    "FV1MrtwGx20" #98.3
    "7IGgrPGetoI" #101.5
    "vGNglKWqwcQ" #Quiero
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
    
    # Try Format 96 First
    new_url=`yt-dlp -f 96 -g "https://www.youtube-nocookie.com/embed/$id" 2>/dev/null | grep https`
    
    # Fallback to Format 95 if 96 is empty
    if [ -z "$new_url" ]; then
        new_url=`yt-dlp -f 95 -g "https://www.youtube-nocookie.com/embed/$id" 2>/dev/null | grep https`
    fi
    
    # Update the file if a URL was found
    if [ -n "$new_url" ]; then
        if grep -q "tvg-id=\"$id\"" "$playlist"; then
            sed -i "/tvg-id=\"$id\"/{n; s|.*|$new_url|;}" "$playlist"
            echo "   [+] Success (Format: $([[ "$new_url" == *"itag/96"* ]] && echo "96" || echo "95"))"
        else
            echo "   [-] ID $id not found in playlist file."
        fi
    else
        echo "   [X] Failed: No URL returned for 96 or 95."
    fi
done

echo ""
echo "• Commit changes"
git add logos
git commit --all -q -m "Regulary update"

echo "• Pushing changes"
git push -q -f

echo "• Process complete."
echo ""

popd
