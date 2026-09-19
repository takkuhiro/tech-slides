#!/usr/bin/env bash
# build.sh — Marp Markdown を PDF / HTML（/ PNG）に変換し、確認用のコンタクトシートを作る
#
#   使い方:  scripts/build.sh deck.md [--png] [--no-sheet] [--theme path/to/theme.css]
#   出力:    deck.pdf, deck.html（同じディレクトリ）
#            deck-preview/sheet-*.png（全ページの一覧。目視 QA 用）
#            --png を付けると deck-preview/slide-NNN.png（1枚ずつ）も出す
#
# 前提: このスキルのルートで `npm install` 済み（@marp-team/marp-cli）。
#       PDF 化には Chrome / Chromium / Edge のいずれかが必要（macOS は自動検出）。
set -euo pipefail

SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MARP="$SKILL_ROOT/node_modules/@marp-team/marp-cli/marp-cli.js"
THEME="$SKILL_ROOT/themes/tech-light.css"
PNG=0; SHEET=1; INPUT=""

while [ $# -gt 0 ]; do
  case "$1" in
    --png) PNG=1 ;;
    --no-sheet) SHEET=0 ;;
    --theme) THEME="$2"; shift ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) INPUT="$1" ;;
  esac
  shift
done

[ -n "$INPUT" ] || { echo "usage: build.sh deck.md [--png] [--no-sheet] [--theme theme.css]" >&2; exit 2; }
[ -f "$INPUT" ] || { echo "not found: $INPUT" >&2; exit 2; }
if [ ! -f "$MARP" ]; then
  echo "marp-cli が見つかりません。次を実行してください: (cd \"$SKILL_ROOT\" && npm install)" >&2
  exit 3
fi

# Chrome の検出（macOS）。他 OS では PATH 上の chrome / chromium を marp-cli が探す
if [ -z "${CHROME_PATH:-}" ]; then
  for c in "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
           "/Applications/Chromium.app/Contents/MacOS/Chromium" \
           "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" \
           "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"; do
    if [ -x "$c" ]; then export CHROME_PATH="$c"; break; fi
  done
fi

DIR="$(cd "$(dirname "$INPUT")" && pwd)"
BASE="$(basename "${INPUT%.*}")"
MD="$DIR/$BASE.md"
PREVIEW="$DIR/$BASE-preview"

# 入力ファイルを先に置くこと。--theme-set は配列オプションなので、後ろに置いた入力を飲み込む
COMMON=(--html --allow-local-files --theme-set "$THEME" --browser-timeout 60)
# marp-cli v4 は CHROME_PATH を見ない。自動探索が稀に固まるので、見つかっていれば明示する
if [ -n "${CHROME_PATH:-}" ]; then COMMON+=(--browser chrome --browser-path "$CHROME_PATH"); fi

# 監視付き実行：LIMIT 秒で終わらなければ殺して 1 回だけやり直す（無言で止まる事故への保険）
LIMIT="${MARP_TIMEOUT:-150}"
run_marp() {
  local attempt
  for attempt in 1 2; do
    node "$MARP" "$@" & local pid=$!
    local waited=0
    while kill -0 "$pid" 2>/dev/null; do
      sleep 1; waited=$((waited + 1))
      if [ "$waited" -ge "$LIMIT" ]; then
        echo "[build] marp が ${LIMIT}s 応答しないため中断します（試行 $attempt）" >&2
        kill "$pid" 2>/dev/null; sleep 1; kill -9 "$pid" 2>/dev/null || true
        pkill -f "marp-cli-" 2>/dev/null || true   # puppeteer の一時プロファイルを持つ Chrome
        break
      fi
    done
    if wait "$pid" 2>/dev/null; then return 0; fi
    [ "$attempt" = 1 ] && echo "[build] やり直します" >&2
  done
  echo "[build] marp の実行に失敗しました。残っている marp-cli.js / headless Chrome を終了して再実行してください" >&2
  return 1
}

echo "[build] PDF  → $DIR/$BASE.pdf"
run_marp "$MD" "${COMMON[@]}" --pdf --pdf-notes --pdf-outlines -o "$DIR/$BASE.pdf"
echo "[build] HTML → $DIR/$BASE.html"
run_marp "$MD" "${COMMON[@]}" -o "$DIR/$BASE.html"

if [ "$PNG" = 1 ]; then
  mkdir -p "$PREVIEW"
  rm -f "$PREVIEW"/slide.*.png
  echo "[build] PNG  → $PREVIEW/slide.NNN.png"
  run_marp "$MD" "${COMMON[@]}" --images png --image-scale 1 -o "$PREVIEW/slide.png"
fi

if [ "$SHEET" = 1 ]; then
  mkdir -p "$PREVIEW"
  python3 "$SKILL_ROOT/scripts/contact_sheet.py" "$DIR/$BASE.pdf" "$PREVIEW"
fi
echo "[build] done"
