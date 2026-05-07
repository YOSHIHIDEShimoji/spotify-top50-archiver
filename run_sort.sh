#!/bin/bash
cd /Users/yoshihide/my-projects/spotify-playlist-tools
LOG=run.log
PYTHON=/Users/yoshihide/.pyenv/versions/spotify-playlist-tools-3.11.9/bin/python
PLAYLISTS=sort_playlists.txt

while IFS= read -r url || [[ -n "$url" ]]; do
    [[ -z "$url" || "$url" == \#* ]] && continue
    output=$("$PYTHON" playlist.py "$url" 2>&1)
    exit_code=$?
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] sort exit=$exit_code $url" >> "$LOG"
    echo "$output" >> "$LOG"
done < "$PLAYLISTS"
