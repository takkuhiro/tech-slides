#!/usr/bin/env bash
# screenshot.sh — Web ページのスクリーンショットをヘッドレス Chrome で撮る
#
#   scripts/screenshot.sh <url> [name] [--dir assets] [--size 1280x800] [--wait 1500]
#
#   出力: <dir>/<name>.png のパスを 1 行で表示
#   ログイン後の画面・ローカルアプリ・デスクトップアプリは撮れない → ユーザーに依頼する
set -euo pipefail

URL="${1:-}"; NAME=""; DIR="assets"; SIZE="1280x800"; WAIT=1500
[ -n "$URL" ] || { echo "usage: screenshot.sh <url> [name] [--dir assets] [--size WxH] [--wait ms]" >&2; exit 2; }
shift
while [ $# -gt 0 ]; do
  case "$1" in
    --dir) DIR="$2"; shift ;;
    --size) SIZE="$2"; shift ;;
    --wait) WAIT="$2"; shift ;;
    *) [ -z "$NAME" ] && NAME="$1" ;;
  esac
  shift
done
[ -n "$NAME" ] || NAME="shot-$(echo "$URL" | sed -E 's#^https?://##' | tr -c 'A-Za-z0-9._-' '-' | sed -E 's/-+/-/g; s/^-|-$//g' | cut -c1-50)"
mkdir -p "$DIR"
OUT="$(cd "$DIR" && pwd)/$NAME.png"

CHROME="${CHROME_PATH:-}"
if [ -z "$CHROME" ]; then
  for c in "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
           "/Applications/Chromium.app/Contents/MacOS/Chromium" \
           "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" \
           "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"; do
    [ -x "$c" ] && { CHROME="$c"; break; }
  done
fi
[ -n "$CHROME" ] || CHROME="$(command -v google-chrome || command -v chromium || command -v chromium-browser || true)"
[ -n "$CHROME" ] || { echo "Chrome が見つかりません（CHROME_PATH を設定）" >&2; exit 3; }

"$CHROME" --headless=new --disable-gpu --hide-scrollbars --no-first-run --no-default-browser-check \
  --window-size="${SIZE/x/,}" --virtual-time-budget="$WAIT" --screenshot="$OUT" "$URL" >/dev/null 2>&1 || true
[ -s "$OUT" ] || { echo "スクリーンショットを撮れませんでした: $URL" >&2; exit 1; }
echo "$OUT"
