# Marp の使い方と落とし穴

## frontmatter（毎回同じ）

```yaml
---
marp: true
theme: tech-light
paginate: false
class: ivory            # 白背景なら行ごと削除。強調色を変えるなら "ivory accent-indigo"
title: <デッキのタイトル>   # PDF のメタデータ・HTML の <title>
---
```

- `html: true` は frontmatter に書いても CLI では無効。`scripts/build.sh` が `--html` を付ける
- `header:` `footer:` `paginate: true` は使わない（lint E02）

## スライドの区切りと 1 枚だけの設定

- `---`（前後に空行）で区切る。コードフェンス内の `---` は区切りにならない
- 1 枚だけ class を付ける：`<!-- _class: ivory section -->`（`_` 付き）。frontmatter の `class` は上書きされるので、アイボリーのデッキでは `ivory` を毎回書き足す
- 全体に効かせる：`<!-- class: ivory -->`（`_` なし。その位置以降すべて）
- スピーカーノート：スライド内の HTML コメント `<!-- ここで PR を見せる -->`。`--pdf-notes` で PDF に注釈として入る。`_class` などのディレクティブと同じコメントに混ぜない

## 見出しとリード文

- `# タイトル` の直後の段落が自動でリード文になる（テーマの `h1 + p`）
- リードの後に本文段落を置きたいときは、間に図解を挟むか `<p class="body">` にする
- `<!-- fit -->` を見出しに付けると 1 行に収まるよう自動縮小される。表紙の長いタイトルにだけ使う

## 画像

- ローカル画像は Markdown から相対パス。PDF 化には `--allow-local-files` が必要（`build.sh` が付ける）
- 背景画像：`![bg](img.png)` 全面、`![bg right:45%](img.png)` 右 45%、`![bg left:40%](img.png)`。`![bg fit](…)` で収める、`![bg cover](…)` で覆う
- サイズ指定：`![w:600](img.png)`、`![h:400](img.png)`
- 全面写真に白文字を載せるときは `<!-- _class: invert -->`。ただし写真は原則使わない（技術の話に写真は要らない）
- スクリーンショットは `<img class="shot" …>` で枠と影が付く。`![alt](img.png)` の Markdown 記法なら角丸だけ

## HTML ブロック

- `<div …>` で始まる行から、**空行まで**が 1 つの HTML ブロック。途中に空行を入れると残りが Markdown として解釈され、閉じタグが文字として表示される（lint E04）
- HTML ブロックの中では Markdown（`**太字**`、`- 箇条書き`）は効かない。`<strong>` `<ul><li>` を使う
- 1 行に詰めて書いてよい。可読性のためにインデントを付けた複数行でも、空行が無ければ 1 ブロック

## 描画・確認

```bash
scripts/build.sh deck.md            # PDF + HTML + コンタクトシート（deck-preview/sheet-NN.png）
scripts/build.sh deck.md --png      # 上に加えて 1 枚ずつの PNG
pdftoppm -png -r 96 -f 7 -l 7 deck.pdf deck-preview/p   # 7 枚目だけ大きく
python3 scripts/lint_slides.py deck.md                    # 機械チェック
```

- `--theme-set` は配列オプション。入力ファイルを後ろに置くと飲み込まれて入力待ちで止まる。`build.sh` は入力を先頭に置いている
- PDF 化は Chrome を使う。**marp-cli v4 は `CHROME_PATH` を見ない**ので、`build.sh` が macOS のアプリを探して `--browser chrome --browser-path` で明示する。自動探索に任せると稀に無言で固まる
- それでも止まったら：`build.sh` は 150 秒（`MARP_TIMEOUT` で変更可）で中断して 1 回やり直す。手で回復するなら `pkill -f marp-cli.js` と headless Chrome の終了
- HTML 出力（`deck.html`）はブラウザで開けばそのまま発表できる（矢印キーで送り、`p` でプレゼンターモード、`f` で全画面）
- フォントは Google Fonts から読み込む。オフラインでは Hiragino Sans にフォールバックし、字幅が少し変わる。本番 PDF はオンラインで書き出す
- `--pdf-outlines` で見出しが PDF のしおりになる（`build.sh` が付ける）

## PPTX が必要なとき

- `node node_modules/@marp-team/marp-cli/marp-cli.js deck.md --html --theme-set themes/tech-light.css --pptx -o deck.pptx`
  → 各ページが画像として入る PPTX（文字は編集できない。Google Slides / Keynote に貼るには十分）
- 文字を編集できる PPTX が必要なら `--pptx-editable`（実験的。LibreOffice が必要で再現性は低い）。代わりに Anthropic の `pptx` スキル（pptxgenjs）で作り直すほうが確実

## Mermaid / D2 を使いたいとき

Marp 本体に Mermaid は無い。次のいずれか：
1. `npx -y @mermaid-js/mermaid-cli -i fig.mmd -o fig.svg -b transparent -t neutral` で SVG にして `![w:900](fig.svg)`（Chrome を含む依存を初回に取得する）
2. テーマの `flow` / `layers` / `nest` / `cycle` で言い換える（多くのアーキテクチャ図はこれで足りる）
3. Excalidraw で描いて SVG 書き出し

いずれも色は強調色 1 色 + グレーに揃える。Mermaid の既定配色のまま貼らない。
