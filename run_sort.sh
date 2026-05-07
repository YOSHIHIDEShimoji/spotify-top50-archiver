#!/bin/bash
cd /Users/yoshihide/my-projects/spotify-playlist-tools
mkdir -p log
LOG=log/sort.log
PYTHON=/Users/yoshihide/.pyenv/versions/spotify-playlist-tools-3.11.9/bin/python
PLAYLISTS=sort_playlists.txt

notify() {
    osascript -e "display notification \"$2\" with title \"$1\" sound name \"Basso\""
}

errors=()

while IFS= read -r url || [[ -n "$url" ]]; do
    [[ -z "$url" || "$url" == \#* ]] && continue
    output=$("$PYTHON" playlist.py "$url" 2>&1)
    exit_code=$?
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] sort exit=$exit_code $url" >> "$LOG"
    echo "$output" >> "$LOG"
    if [[ $exit_code -ne 0 ]]; then
        if echo "$output" | grep -qi "oauth\|token\|auth\|unauthorized\|401"; then
            errors+=("AUTH:$url")
        else
            errors+=("ERR:$url")
        fi
    fi
done < "$PLAYLISTS"

if [[ ${#errors[@]} -gt 0 ]]; then
    auth_errors=$(printf '%s\n' "${errors[@]}" | grep -c '^AUTH:')
    if [[ $auth_errors -gt 0 ]]; then
        notify "Spotify Sort: 認証エラー" "再ログインが必要です（${auth_errors}件）"
    else
        notify "Spotify Sort: エラー" "${#errors[@]}件のプレイリストでエラーが発生しました"
    fi
fi
