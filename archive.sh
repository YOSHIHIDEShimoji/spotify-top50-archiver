#!/bin/bash
cd /Users/yoshihide/my-projects/spotify-playlist-tools
mkdir -p log
LOG=log/archive.log
PYTHON=/Users/yoshihide/.pyenv/versions/spotify-playlist-tools-3.11.9/bin/python

NOTIFIER=~/Applications/Notifiers/spotify-playlist-tools.app
notify() {
    open -W -n "$NOTIFIER" --args -title "$1" -message "$2"
}

output=$("$PYTHON" archive.py 2>&1)
exit_code=$?
echo "[$(date '+%Y-%m-%d %H:%M:%S')] archive exit=$exit_code" >> "$LOG"
echo "$output" >> "$LOG"

if [[ $exit_code -ne 0 ]]; then
    if echo "$output" | grep -qi "oauth\|token\|auth\|unauthorized\|401"; then
        notify "Spotify Archive: 認証エラー" "再ログインが必要です"
    else
        notify "Spotify Archive: エラー" "archive.py が失敗しました"
    fi
fi
