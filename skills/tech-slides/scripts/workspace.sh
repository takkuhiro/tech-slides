#!/usr/bin/env bash
# workspace.sh — スライドの置き場所（ワークスペース）を 1 度だけ決めて覚え、デッキごとのディレクトリを切る
#
#   scripts/workspace.sh get             設定済みのワークスペースを表示（未設定なら exit 1）
#   scripts/workspace.sh set <dir>       ワークスペースを保存（~ と相対パスは絶対化。無ければ作る）
#   scripts/workspace.sh new <slug>      <ws>/<slug>/ と <ws>/<slug>/assets/ を作り、パスを表示
#   scripts/workspace.sh list            ワークスペース内のデッキ一覧（plan / md / pdf の有無）
#
# 設定ファイル: ${XDG_CONFIG_HOME:-~/.config}/tech-slides/config.json  {"workspace": "/abs/path"}
# プラグイン本体は更新で差し替わるので、ユーザーの設定はその外に置く。
set -euo pipefail

CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tech-slides"
CONF="$CONF_DIR/config.json"

read_ws() {
  [ -f "$CONF" ] || return 1
  python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("workspace",""))' "$CONF" 2>/dev/null
}

cmd="${1:-}"; shift || true
case "$cmd" in
  get)
    ws="$(read_ws || true)"
    if [ -z "$ws" ]; then
      echo "ワークスペース未設定。ユーザーにスライドの置き場所（例: ~/develop/slides）を 1 度だけ聞き、'workspace.sh set <dir>' で保存する" >&2
      exit 1
    fi
    [ -d "$ws" ] || { echo "設定済みのワークスペースが存在しない: $ws（作り直すなら 'workspace.sh set <dir>'）" >&2; exit 1; }
    echo "$ws" ;;
  set)
    dir="${1:-}"; [ -n "$dir" ] || { echo "usage: workspace.sh set <dir>" >&2; exit 2; }
    dir="${dir/#\~/$HOME}"
    mkdir -p "$dir"; dir="$(cd "$dir" && pwd)"
    mkdir -p "$CONF_DIR"
    python3 - "$CONF" "$dir" <<'PY'
import json, sys, os
conf, ws = sys.argv[1], sys.argv[2]
data = json.load(open(conf)) if os.path.exists(conf) else {}
data["workspace"] = ws
json.dump(data, open(conf, "w"), ensure_ascii=False, indent=2)
PY
    echo "$dir" ;;
  new)
    slug="${1:-}"; [ -n "$slug" ] || { echo "usage: workspace.sh new <slug>" >&2; exit 2; }
    case "$slug" in *[!A-Za-z0-9._-]*) echo "slug は英数字と . _ - だけ: $slug" >&2; exit 2 ;; esac
    ws="$("$0" get)" || exit 1
    mkdir -p "$ws/$slug/assets"
    echo "$ws/$slug" ;;
  list)
    ws="$("$0" get)" || exit 1
    for d in "$ws"/*/; do
      [ -d "$d" ] || continue
      s="$(basename "$d")"
      printf '%-32s' "$s"
      [ -f "$d/$s.plan.md" ] && printf ' plan' || printf '     '
      [ -f "$d/$s.md" ] && printf ' md' || printf '   '
      [ -f "$d/$s.pdf" ] && printf ' pdf' || printf '    '
      printf '\n'
    done ;;
  *) sed -n '2,10p' "$0"; exit 2 ;;
esac
