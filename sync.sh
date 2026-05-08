#!/bin/bash
cd /Users/yoshihide/my-projects/spotify-playlist-tools
mkdir -p log
LOG=log/sync.log
PYTHON=/Users/yoshihide/.pyenv/versions/spotify-playlist-tools-3.11.9/bin/python

if ! nc -zw3 accounts.spotify.com 443 2>/dev/null; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ネットワーク未接続のためスキップ" >> "$LOG"
    exit 0
fi

NOTIFIER=~/Applications/Notifiers/spotify-playlist-tools.app
notify() {
    open -W -n "$NOTIFIER" --args -title "$1" -message "$2"
}

output=$("$PYTHON" sync.py 2>&1)
exit_code=$?
echo "[$(date '+%Y-%m-%d %H:%M:%S')] sync exit=$exit_code" >> "$LOG"
echo "$output" >> "$LOG"

if [[ $exit_code -ne 0 ]]; then
    if echo "$output" | grep -qi "oauth\|token\|auth\|unauthorized\|401"; then
        notify "Spotify Sync: 認証エラー" "再ログインが必要です"
    else
        notify "Spotify Sync: エラー" "sync.py が失敗しました"
    fi
fi

new_count=$(echo "$output" | grep -c "→ created playlist" || true)
if [[ $new_count -gt 0 ]]; then
    notify "Spotify Sync" "新プレイリストを${new_count}件作成しました"
fi

DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$DIR/sort.sh"
