# spotify-playlist-tools

Spotify プレイリストを自動管理する3つのツール。

---

## ファイル構成

```
.
├── sort.py       # プレイリストのソート・分析
├── sort.sh       # sort.py の自動実行ラッパー
├── sort.txt      # ソート対象プレイリストURL一覧
│
├── archive.py    # Top 50 の新着曲をアーカイブ
├── archive.sh    # archive.py の自動実行ラッパー
├── archive.txt   # アーカイブ設定（SOURCE / DEST プレイリストID）
│
├── sync.py       # アーティスト別プレイリストへ自動振り分け・同期
├── sync.sh       # sync.py → sort.sh を順に実行するラッパー
├── sync.txt      # 同期設定（SOURCE プレイリストID + アーティスト→プレイリストID）
│
└── log/
    ├── sort.log
    ├── archive.log
    └── sync.log
```

---

## セットアップ

### 前提
- pyenv / pyenv-virtualenv インストール済み

### 仮想環境

```bash
pyenv virtualenv 3.11.9 spotify-playlist-tools-3.11.9
pyenv local spotify-playlist-tools-3.11.9
pip install -r requirements.txt
```

### 認証情報

[Spotify Developer Dashboard](https://developer.spotify.com/dashboard) でアプリを作成し、`.env` を用意する。

```bash
cp .env.example .env
```

```env
SPOTIPY_CLIENT_ID=your_client_id_here
SPOTIPY_CLIENT_SECRET=your_client_secret_here
SPOTIPY_REDIRECT_URI=http://127.0.0.1:8000/callback
```

初回実行時にブラウザが開き、OAuth 認証が走る。トークンは `.cache-spotify` にキャッシュされる。

---

## sort.py — プレイリストのソート・分析

プレイリストを **アーティスト曲数降順 → アーティスト名順 → リリース日昇順** で並べ替える。

### 設定

`sort.txt` にソート対象プレイリストの URL を1行ずつ記載する。

```
https://open.spotify.com/playlist/xxxxxx
https://open.spotify.com/playlist/yyyyyy
```

### 実行

```bash
# sort.txt の全プレイリストを一括ソート
bash sort.sh

# 単体実行
python sort.py "https://open.spotify.com/playlist/xxxxxx"

# 分析グラフ表示（プレイリストは変更しない）
python sort.py --analyze "https://open.spotify.com/playlist/xxxxxx"
```

---

## archive.py — Top 50 アーカイバ

ソースプレイリストの現在の曲を取得し、アーカイブ先に未追加の曲だけを追記する。
毎日実行することで「過去にランクインした全曲」を蓄積する。

### 設定

`archive.txt` に設定する。

```
SOURCE_PLAYLIST_ID=<Top 50 などのプレイリストID>
DEST_PLAYLIST_ID=<アーカイブ先のプレイリストID>
```

### 実行

```bash
bash archive.sh
# または
python archive.py
```

---

## sync.py — アーティスト別プレイリスト同期

ソースプレイリストを走査し、各アーティストの曲を個別プレイリストへ追加する（重複なし）。
`AUTO_DETECT_THRESHOLD`（デフォルト: 20）曲以上持つ未設定アーティストは自動検出し、
プレイリストを新規作成して `sync.txt` と `sort.txt` に自動追記する。

### 設定

`sync.txt` に設定する。

```
SOURCE_PLAYLIST_ID=<同期元プレイリストID>

Charlie Puth=<プレイリストID>
Taylor Swift=<プレイリストID>
OneRepublic=<プレイリストID>
# アーティスト名=プレイリストID の形式で追加
```

### 実行

```bash
# sync → sort の順で実行（推奨）
bash sync.sh

# 単体実行
python sync.py
```

---

## 自動実行（launchd）

| launchd ラベル | スクリプト | スケジュール |
|---|---|---|
| `com.yoshihide.run_sync` | `sync.sh` | 毎日 12:00 |
| `com.yoshihide.run_spotify_top50_archive` | `archive.sh` | 毎日 12:00 |

`sync.sh` は内部で `sort.sh` を呼ぶため、sort の launchd 登録は不要。

ログは `log/` に記録される。OAuth トークンが失効した場合は macOS 通知で警告される。
