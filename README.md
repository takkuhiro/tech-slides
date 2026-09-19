# tech-slides

技術カンファレンス登壇・社内勉強会・LT のスライドを Marp（Markdown）で作る Claude Code プラグイン。

- 白／淡いアイボリーの明るい背景、1 スライド 1 メッセージ、ヘッダー・フッター無し
- 各ページは「タイトル → リード文（一番伝えたい一文）→ 根拠の図解」で組む
- 図解パターン（並列・比較・フロー・サイクル・階層・マトリクス・数式・ビフォーアフター・数値・タイムライン等）をテーマ CSS の class として同梱
- Markdown の機械チェック（lint）→ PDF 描画 → コンタクトシートで目視、まで一気通貫

| スキル | フェーズ | 呼び出し | 役割 |
|---|---|---|---|
| `slide-plan` | 構想 | 「スライドの構成を考えたい」「登壇内容を整理したい」 | 伝えたいことを聞き、対話で構成を練る。枚ごとの主張・図解パターン・必要な画像素材を決め、`<slug>.plan.md` 1 ファイルに落とす。ユーザーの案にも聴衆の立場から代案を出す |
| `tech-slides` | 作成 | 「構成案からスライド化」「スライドを作って」 | 構成案から Marp デッキを書く。ロゴ・記事サムネイル・公開ページの画面は自分で収集し、取れない画面はユーザーに条件付きで依頼。lint → 描画 → QA → 納品 |
| `slide-review` | — | 「スライドをレビューして」 | 既存デッキ（md / pdf / pptx）を初見の聴衆として指摘 |

構想フェーズの成果物は Markdown 1 ファイルだけ。作成フェーズはそれを読んで作る。構成が無い状態で「作って」と言われた場合は構想フェーズに戻る。

## セットアップ

```bash
# 依存（marp-cli, lucide-static）
cd skills/tech-slides && npm install

# コンタクトシート（任意。無ければ pdftoppm + Pillow で代替）
pip install pymupdf

# 開発中のプラグインを読み込んで起動（セッション中に直したら /reload-plugins）
claude --plugin-dir /path/to/slides-plugin
```

常用するなら、`.claude-plugin/marketplace.json` を持つローカルマーケットプレイスに置き、
`/plugin marketplace add <path>` → `/plugin install tech-slides@<marketplace名>` で user スコープに入れる。

PDF 化には Chrome / Chromium / Edge / Brave のいずれかが必要（macOS は自動検出、他は `CHROME_PATH`）。
フォントは Noto Sans JP + JetBrains Mono を Google Fonts から読み込み、オフラインでは Hiragino Sans にフォールバックする。

## 手で使う

```bash
S=skills/tech-slides
cp $S/templates/deck-template.md talk.md          # 雛形
python3 $S/scripts/lint_slides.py talk.md           # 機械チェック
bash $S/scripts/build.sh talk.md                    # talk.pdf / talk.html / talk-preview/sheet-NN.png
bash $S/scripts/build.sh $S/templates/showcase.md   # 全パターンの見本を描く
node $S/scripts/icon.mjs --search cache             # 汎用アイコンを探す（Lucide）
node $S/scripts/icon.mjs --brand github docker      # ツールのロゴ（simple-icons、ブランド色）
bash $S/scripts/fetch_asset.sh <記事/YouTube/画像のURL> name   # サムネイルを assets/ に保存
bash $S/scripts/screenshot.sh https://example.com name        # 公開ページのスクリーンショット
```

`talk.html` をブラウザで開けばそのまま発表できる（矢印キーで送り、`p` でプレゼンターモード、`f` で全画面）。

## 構成

```
.claude-plugin/plugin.json
skills/slide-plan/
  SKILL.md                      構想フェーズ（対話で構成を練り、構成案 1 ファイルを作る）
  templates/plan-template.md    構成案の形式
skills/tech-slides/
  SKILL.md                      作成フェーズ（Phase 1〜5）
  themes/tech-light.css         テーマ。トークン・スライド型・図解パターン
  templates/deck-template.md    雛形
  templates/showcase.md         全パターンの実例（31 枚）
  references/design-principles.md   数値付きデザイン原則
  references/layout-patterns.md     図解パターンカタログ（HTML スニペット）+ 原典 39 パターン対応表
  references/assets.md              画像・ロゴ・サムネイルの要否判断、取得手順、ユーザーへの依頼の書き方
  references/story-structures.md    用途・時間別の構成テンプレート、骨子の書き方
  references/code-slides.md         コードの見せ方
  references/marp-notes.md          Marp の記法・落とし穴・PPTX・Mermaid
  references/qa-checklist.md        目視 QA
  scripts/build.sh              md → pdf / html / png / コンタクトシート
  scripts/lint_slides.py        機械チェック
  scripts/contact_sheet.py      pdf → 一覧画像
  scripts/icon.mjs              Lucide の汎用アイコン / simple-icons のロゴを 1 行 SVG で
  scripts/fetch_asset.sh        記事の OG 画像・YouTube サムネイル・画像 URL を assets/ に保存
  scripts/screenshot.sh         公開 Web ページのスクリーンショット
skills/slide-review/SKILL.md    レビュー
examples/showcase.{md,pdf}      見本（31 枚）と素材
references/                     参考にした他プラグイン（同梱しない）
```

## 設計メモ

- **Marp を選んだ理由**：技術資料の核であるコードブロックとダイアグラムをネイティブに扱え、Markdown は後から手で直しやすく、Git で差分が見える。図解は `--html` を有効にしてテーマの class で組む。PDF は Chrome で描くので CSS の表現力がそのまま使える
- **PPTX は主目的にしない**：登壇資料は PDF（Speaker Deck / Docswell）が主。必要なら画像 PPTX（`--pptx`）か、Anthropic の `pptx` スキルで作り直す
- **参考にしたもの**：CONE inc.「パワーポイントのデザインパターン大全」（39 パターン）、Assertion-Evidence 構造、Presentation Zen、伝わるデザイン、speaking.io、Anthropic 公式 pptx スキルの QA 手順、社内で使っているスライド生成スキルの「生成 → 機械監査 → 目視」の流れ
