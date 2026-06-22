#!/bin/bash

playlist_path="/sdcard/a"
playlist="ar.m3u"

# Define the IDs you want to update
ids=(
    "ArKbAx1K-2U" #A24
    "Qr61waJ6AZg" #CNÑ
    "JC7f3EUDaqw" #Cronica
    "eKfPZ6f0SQw" #Diputados
    "DVZ2rJQb_0g" #LN+
    "cb12KmMMDJA" #TodoNoticias
    "VWhQ6xspnSc" #C5N
    "BjvTYTgBhUY" #TVPublica
)

pushd $playlist_path

# 1. Create a Backup
backup_file="${playlist}.$(date +%Y%m%d_%H%M).bak"
cp "$playlist" "backups/$backup_file"
echo "Backup created: $backup_file"

# 2. Iterate through IDs
echo "Starting update: $(date)"


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