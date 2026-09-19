---
name: tech-slides
description: スライドの「作成フェーズ」。構成案（<slug>.plan.md、slide-plan スキルの成果物）または承認済みの骨子から、Marp（Markdown）でスライド本体を作り、画像素材を集め、lint と PDF 描画で QA して納品する。技術カンファレンス登壇・社内勉強会・LT 向け。「スライドを作って」「構成案からスライド化」「デッキを直して」「Marp で」「PDF にして」で使う。構成がまだ無ければ先に slide-plan スキルで構想フェーズを行う。顧客向け提案書・見積もりは対象外。
---

# tech-slides — 作成フェーズ

構成案（`<slug>.plan.md`）を Marp の Markdown（`<slug>.md`）にし、描画して QA する。
**書く内容は構成案、見た目はテーマ `themes/tech-light.css`**が持つ。座標や色を Markdown 側で指定しない。
着手前に `references/lessons.md`（過去の指摘と規則）を読む。

## 入口の判定

| 状況 | 動き |
|---|---|
| `<slug>.plan.md` がある、または承認済みの骨子（型・タイトル・リード文の一覧）が会話にある | このスキルで作る |
| 構成が無い（「〇〇の話でスライド作って」だけ） | **`slide-plan` スキルに渡す**（構想フェーズ）。急ぎと言われた場合だけ、簡易の骨子をテキストで 1 度見せて承認後に作る |
| 既存の Marp デッキの修正 | 指示箇所だけ直して Phase 3〜4 |
| 記事・README・PDF/PPTX からの変換 | 構成に組み替えるので `slide-plan` へ。文章をそのまま貼らない |

## 既定値

| 項目 | 既定 |
|---|---|
| 背景 | 淡いアイボリー（`class: ivory`）。構成案に white とあれば `class:` 行を削る |
| 強調色 | teal。構成案の指定で `accent-indigo / coral / slate / plum` を `class:` に足す。1 デッキ 1 色 |
| 1 枚の構成 | `# タイトル` → リード文（主張の一文、`#` の直後の段落が自動でそうなる）→ 根拠の図解。ヘッダー・フッター・ページ番号なし |
| 出力 | `<slug>.md`（正）、`<slug>.pdf`、`<slug>.html`、`<slug>-preview/sheet-NN.png`、`assets/` |

## 進め方

### Phase 1 — 構成案を読み、素材を集める

1. 構成案の各枚の「型・タイトル・リード文・根拠・素材」を確認する。構成案に無い枚を勝手に足さない。足したほうがよいと思えば提案して止まる
2. **素材リストを処理する**（`references/assets.md`）：
   - 「こちらで取得」→ 今取る。ロゴは `node scripts/icon.mjs --brand <slug>`、記事・動画・画像 URL は `bash scripts/fetch_asset.sh <url> <name>`、公開ページの画面は `bash scripts/screenshot.sh <url> <name>`。`assets/` に保存し、構成案の状態を「取得済み」に更新
   - 「依頼：ユーザー」で未着 → 構成案の条件をそのまま一覧にして依頼する。**待たずに先へ進み**、該当枚は `<div class="card dashed">` のプレースホルダー（何の画像が入るかを書く）で組む
   - 構成案に素材が無いが画像が根拠になる枚（アプリの画面、ツールのロゴ、参考記事）に気づいたら、取れるものは取り、取れないものは依頼に加える。黙って文字だけで済ませない
3. 取得した画像は出典を `figcaption` か `.note` に書く

### Phase 2 — Markdown を書く

1. `templates/deck-template.md` を `<slug>.md` にコピーし、構成案の枚を順に埋める。型の HTML は `references/layout-patterns.md`（該当箇所だけ読む）。実例は `templates/showcase.md`
2. **`<div>` の途中に空行を入れない**。HTML の中では Markdown が効かない
3. 汎用アイコンは `node scripts/icon.mjs <name>`（`--search` で探す）。1 枚 3〜4 個、並列要素の識別にだけ使う
4. コードは `references/code-slides.md`。8 行以内、1 行 64 字以内、焦点は `pre.focus` + `<mark>`
5. スピーカーノートは構成案の「ノート」を HTML コメントで各枚に入れる
6. 各枚を書き終えるごとに自問する：**リード文だけで主張が伝わるか。図解・画像はその根拠か。削れる要素は無いか**

守る量（`references/design-principles.md`）：タイトル 30 字・リード文 60 字・並列要素 6 個・箇条書き 5 項目・本文 220 字・コード 15 行。

### Phase 3 — lint

```bash
python3 "${SKILL_ROOT}/scripts/lint_slides.py" <slug>.md
```
error（見出し重複・header/footer・未知の class・HTML の分断）を 0 にする。warn は理由を言えるなら残せる。

### Phase 4 — 描画して目視する（3 段階）

```bash
bash "${SKILL_ROOT}/scripts/build.sh" <slug>.md --png    # PDF + HTML + コンタクトシート + 1 枚ずつの PNG
```
1. **全体**：`<slug>-preview/sheet-NN.png` をすべて開き、流れ・型の偏り・余白の揃いを見る
2. **原寸**：`<slug>-preview/slide.NNN.png` を **1 枚ずつ全部**開く。コンタクトシートでは見えない崩れ（図形の重なり、折り返し、画像と地の境界、色の沈み）はここでしか見つからない。`references/qa-checklist.md` の項目を順に当てる
3. **別の目**：作った本人は見たいものを見てしまう。`slide-review` スキルを **Agent ツールで別エージェントとして起動**し、`<slug>.md` と PNG のディレクトリを渡して枚ごとの指摘を受ける。指摘は「直す／理由を付けて残す」のどちらかに必ず振り分ける

直したら `build.sh` を再実行し、そのページだけ拡大して再確認する（古い PDF を見て「直っていない」と誤認しやすい）。

### Phase 4.5 — 指摘を仕組みに落とす

ユーザーやレビューから見た目・構成の指摘を受けたら、その枚を直すだけで終わらせない。
同じ型を使う他の枚・次のデッキでも起きるなら **テーマ / lint / チェックリスト / SKILL.md のどこかに落とし、`references/lessons.md` に 1 行残す**。
落とし先が決まらない指摘も「未対応」として lessons.md に残す。

### Phase 5 — 納品

報告に含める：出力ファイルのパス、枚数と目安の分数、**プレースホルダーのまま残っている枚とその素材の依頼内容**、`<TBD>` の一覧、warn を残した箇所と理由。
発表方法を 1 行：`<slug>.html` をブラウザで開いて矢印キー（`p` でプレゼンターモード、`f` で全画面）、または PDF。
素材が届いたら `assets/` に置いてもらい、該当枚を差し替えて Phase 3〜4 をやり直す。

## PPTX・Mermaid・背景画像

`references/marp-notes.md`。PPTX は画像 PPTX（`--pptx`）か Anthropic の `pptx` スキルで作り直す。

## やらないこと

- 構成案なしに全体を作る（`slide-plan` へ）。構成案に無い枚を黙って足す・削る
- 画像が根拠になる枚を、素材の確認なしに文字だけで済ませる
- ヘッダー・フッター・ページ番号・ロゴ・飾り線・意味のない図形を置く
- 強調色を 2 色以上使う、1 枚に主役（`emph`）を 2 つ置く
- 空白を埋めるために要素やアイコンを足す。下が空くのはよい
- 数値・固有名詞・日付を推測で書く。取得した画像の出典を省く
- プレースホルダーのままの枚を「完成」として報告する

## セットアップ（初回のみ）

```bash
cd "${SKILL_ROOT}" && npm install        # @marp-team/marp-cli, lucide-static, simple-icons
```
PDF 化と screenshot.sh には Chrome / Chromium / Edge / Brave のいずれかが必要（macOS は自動検出。他 OS は `CHROME_PATH`）。
コンタクトシートは PyMuPDF（`pip install pymupdf`）があると速い。無ければ `pdftoppm` + Pillow で代替する。
フォントは Google Fonts から読み込む。オフラインでは Hiragino Sans にフォールバックするので、本番の PDF はオンラインで書き出す。

`${SKILL_ROOT}` はこの SKILL.md があるディレクトリ。プラグインとして読み込まれている場合は `${CLAUDE_PLUGIN_ROOT}/skills/tech-slides`。

## ファイル構成

| パス | 役割 |
|---|---|
| `themes/tech-light.css` | テーマ。トークン・スライド型・図解パターン・画像用 class。**見た目の正解はここだけ** |
| `templates/deck-template.md` | 新規デッキの雛形 |
| `templates/showcase.md` | 全パターンの実例。型の書き方を確認するときに該当箇所だけ読む |
| `references/layout-patterns.md` | 図解パターンのカタログ + 原典 39 パターンとの対応表 |
| `references/assets.md` | 画像・ロゴ・サムネイルの要否判断、取得手順、ユーザーへの依頼の書き方 |
| `references/design-principles.md` | 数値付きのデザイン原則、AI っぽさの回避 |
| `references/story-structures.md` | 構成の型と枚数目安（構想フェーズが主に使う） |
| `references/code-slides.md` | コードの見せ方 |
| `references/marp-notes.md` | Marp の記法と落とし穴、画像、PPTX、Mermaid |
| `references/qa-checklist.md` | 目視 QA のチェックリスト |
| `references/lessons.md` | ユーザーからの指摘と、仕組みに落とした先。着手前に読む。指摘を受けたら追記する |
| `scripts/build.sh` | Markdown → PDF / HTML / PNG / コンタクトシート |
| `scripts/lint_slides.py` | 機械チェック（E01〜E04 / W01〜W08 / I01〜I02） |
| `scripts/contact_sheet.py` | PDF → 一覧画像 |
| `scripts/icon.mjs` | Lucide の汎用アイコン、simple-icons のブランドロゴを 1 行 SVG で出力 |
| `scripts/fetch_asset.sh` | URL（記事 / YouTube / 画像）→ `assets/` に画像を保存 |
| `scripts/screenshot.sh` | 公開 Web ページのスクリーンショット |
