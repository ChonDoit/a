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
