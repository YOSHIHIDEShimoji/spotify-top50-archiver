# spotify-top50-archiver

Spotify プレイリストを管理する2つのツール。

---

## ツール一覧

| ファイル | 役割 |
|---|---|
| `archive_top50.py` | Top 50 プレイリストの新着曲をアーカイブ用プレイリストに追記 |
| `playlist.py` | 指定プレイリストのソート・分析 |

---

## セットアップ

### 前提
- pyenv / pyenv-virtualenv インストール済み

### 仮想環境

```bash
pyenv virtualenv 3.11.9 spotify-top50-archiver-3.11.9
pyenv local spotify-top50-archiver-3.11.9
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

初回実行時にブラウザが開き、OAuth認証が走る。トークンは `.cache-spotify` にキャッシュされる。

---

## archive_top50.py

`playlists.txt` に設定したソースプレイリストの現在の曲を取得し、デスティネーションプレイリストに未追加の曲だけを追記する。毎日実行することで「過去にランクインした全曲」が蓄積されていく。

### 設定

```bash
cp playlists.txt.example playlists.txt
```

```
SOURCE_PLAYLIST_ID=<Top 50 などのプレイリストID>
DEST_PLAYLIST_ID=<アーカイブ先のプレイリストID>
```

### 実行

```bash
python archive_top50.py
```

---

## playlist.py

### ソート

プレイリストを **アーティスト曲数降順 → アーティスト名順 → リリース日昇順** に並べ替えて上書き保存する。

```bash
python playlist.py "<URL または ID>"
```

```
# 例
python playlist.py "https://open.spotify.com/playlist/3gWeVkYJPREpkdCpDRjHFw"
```

### 分析

プレイリストの構成をグラフで可視化する（プレイリストは変更しない）。

```bash
python playlist.py --analyze "<URL または ID>"
```

表示内容：

- Top 15 アーティスト別曲数（横棒グラフ）
- リリース年分布（ヒストグラム）
- 人気スコア分布（ヒストグラム）
- 人気スコア Top 10 曲一覧

---

## 自動実行

`run_sort.sh` を launchd に登録することで、毎日指定時刻に自動ソートを実行できる。

```bash
python /path/to/launchd_manager.py run_sort.sh
```

ログは `run.log` に追記される。

> **注意:** OAuth トークンが失効した場合は手動で `python playlist.py <URL>` を実行して再認証が必要。
