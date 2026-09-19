#!/usr/bin/env bash
# fetch_asset.sh — スライドに貼る画像を URL から取得して assets/ に保存する
#
#   scripts/fetch_asset.sh <url> [name] [--dir assets]
#
#   対応:
#     YouTube の動画 URL          → サムネイル（maxresdefault → hqdefault の順に試す）
#     画像 URL（png/jpg/gif/svg/webp） → そのまま保存
#     記事・Web ページの URL       → og:image（無ければ twitter:image）を保存
#   出力: <dir>/<name>.<ext> のパスを 1 行で表示。取得できなければ非 0 で終了し、理由を表示する
#
#   取得した画像は「引用」として使う。出典（URL・サイト名）を figcaption か .note に必ず書く。
set -euo pipefail

URL="${1:-}"; NAME="${2:-}"; DIR="assets"
[ -n "$URL" ] || { echo "usage: fetch_asset.sh <url> [name] [--dir assets]" >&2; exit 2; }
shift || true
while [ $# -gt 0 ]; do
  case "$1" in
    --dir) DIR="$2"; shift ;;
    *) [ -z "$NAME" ] && NAME="$1" ;;
  esac
  shift
done
[ "$NAME" = "--dir" ] && NAME=""
mkdir -p "$DIR"

UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128 Safari/537.36"
slug() { echo "$1" | tr -c 'A-Za-z0-9._-' '-' | sed -E 's/-+/-/g; s/^-|-$//g' | cut -c1-60; }

ext_of() {
  case "$(echo "$1" | tr 'A-Z' 'a-z')" in
    *.png*) echo png ;; *.jpg*|*.jpeg*) echo jpg ;; *.gif*) echo gif ;; *.svg*) echo svg ;; *.webp*) echo webp ;;
    *) echo "" ;;
  esac
}

download() { # url out
  curl -sSL -A "$UA" --max-time 30 -o "$2" "$1" || return 1
  [ -s "$2" ] || return 1
  # 拡張子が不明なら中身で決める
  local kind; kind="$(file -b --mime-type "$2")"
  case "$kind" in
    image/png|image/jpeg|image/gif|image/svg+xml|image/webp) return 0 ;;
    *) rm -f "$2"; return 1 ;;
  esac
}

# 1) YouTube
if echo "$URL" | grep -qE 'youtube\.com/watch|youtu\.be/|youtube\.com/shorts/'; then
  ID="$(echo "$URL" | sed -E 's#.*(v=|youtu\.be/|shorts/)([A-Za-z0-9_-]{11}).*#\2#')"
  [ -n "$NAME" ] || NAME="yt-$ID"
  OUT="$DIR/$NAME.jpg"
  for q in maxresdefault sddefault hqdefault; do
    if download "https://img.youtube.com/vi/$ID/$q.jpg" "$OUT"; then
      # maxresdefault が無いとき 120x90 のダミーが返ることがある
      if [ "$(stat -f%z "$OUT" 2>/dev/null || stat -c%s "$OUT")" -gt 5000 ]; then echo "$OUT"; exit 0; fi
    fi
  done
  echo "YouTube サムネイルを取得できませんでした: $URL" >&2; exit 1
fi

# 2) 直接の画像
EXT="$(ext_of "$URL")"
if [ -n "$EXT" ]; then
  [ -n "$NAME" ] || NAME="$(slug "$(basename "${URL%%\?*}" | sed -E 's/\.[^.]+$//')")"
  OUT="$DIR/$NAME.$EXT"
  download "$URL" "$OUT" && { echo "$OUT"; exit 0; }
  echo "画像を取得できませんでした: $URL" >&2; exit 1
fi

# 3) ページの og:image
HTML="$(curl -sSL -A "$UA" --max-time 30 "$URL" || true)"
[ -n "$HTML" ] || { echo "ページを取得できませんでした: $URL" >&2; exit 1; }
IMG="$(echo "$HTML" | tr '\n' ' ' | grep -oE '<meta[^>]+(property|name)="(og:image|twitter:image)(:src)?"[^>]*>' | head -1 | grep -oE 'content="[^"]+"' | head -1 | sed -E 's/^content="//; s/"$//')"
if [ -z "$IMG" ]; then
  IMG="$(echo "$HTML" | tr '\n' ' ' | grep -oE '<meta[^>]+content="[^"]+"[^>]+(property|name)="(og:image|twitter:image)"' | head -1 | grep -oE 'content="[^"]+"' | sed -E 's/^content="//; s/"$//')"
fi
[ -n "$IMG" ] || { echo "og:image が見つかりません。scripts/screenshot.sh でページ全体を撮るか、ユーザーに画像を依頼してください: $URL" >&2; exit 1; }
IMG="$(echo "$IMG" | sed 's/&amp;/\&/g')"
case "$IMG" in /*) IMG="$(echo "$URL" | grep -oE '^https?://[^/]+')$IMG" ;; esac
[ -n "$NAME" ] || NAME="og-$(slug "$(echo "$URL" | sed -E 's#^https?://##')")"
EXT="$(ext_of "$IMG")"; [ -n "$EXT" ] || EXT="jpg"
OUT="$DIR/$NAME.$EXT"
if download "$IMG" "$OUT"; then
  # 実体に合わせて拡張子を直す
  kind="$(file -b --mime-type "$OUT")"; real="${kind#image/}"; real="${real/jpeg/jpg}"; real="${real/svg+xml/svg}"
  if [ "$real" != "$EXT" ]; then mv "$OUT" "$DIR/$NAME.$real"; OUT="$DIR/$NAME.$real"; fi
  echo "$OUT"; exit 0
fi
echo "og:image を取得できませんでした: $IMG" >&2; exit 1
