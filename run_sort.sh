#!/bin/bash
cd /Users/yoshihide/my-projects/spotify-playlist-tools
LOG=run.log

output=$(/Users/yoshihide/.pyenv/versions/spotify-playlist-tools-3.11.9/bin/python \
  playlist.py \
  "https://open.spotify.com/playlist/3gWeVkYJPREpkdCpDRjHFw?si=cdbafcbffb9e4b9a" 2>&1)
exit_code=$?

echo "[$(date '+%Y-%m-%d %H:%M:%S')] sort exit=$exit_code" >> "$LOG"
echo "$output" >> "$LOG"
