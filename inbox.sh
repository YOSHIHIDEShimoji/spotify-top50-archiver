#!/bin/bash
cd /Users/yoshihide/my-projects/spotify-playlist-tools
mkdir -p log
LOG=log/inbox.log
PYTHON=/Users/yoshihide/.pyenv/versions/spotify-playlist-tools-3.11.9/bin/python

if ! nc -zw3 accounts.spotify.com 443 2>/dev/null; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ネットワーク未接続のためスキップ" >> "$LOG"
    exit 0
fi

"$PYTHON" -u inbox.py 2>&1 | tee -a "$LOG"
