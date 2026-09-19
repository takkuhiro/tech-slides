# レイアウトパターン カタログ

CONE inc.「パワーポイントのデザインパターン大全」の 39 パターンを技術登壇向けに再編し、
テーマ `tech-light.css` の class として実装したもの。**要素間の関係**で型を選ぶ。

```
関係がある  ─┬─ 並列（対等）        → cols / rows
            ├─ 比較・対比          → compare / table / stats
            ├─ 順序・時間          → flow / timeline / cycle
            ├─ 階層・包含          → pyramid / layers / nest / venn
            ├─ 因果・構成          → formula / matrix
            └─ 変化               → compare.arrow（ビフォーアフター）
関係がない  ─┬─ 数値               → stats
            ├─ コード             → ```lang / pre.focus / diff / terminal
            ├─ 画像・キャプチャ    → two + figure / ![bg right]
            ├─ 表                 → table
            └─ 文だけ             → message / quote / callout
ページ項目  ─── 表紙 / 章扉 / まとめ / 締め / DEMO
```

**HTML を書くときの規則**
- `<div>` ブロックの中に空行を入れない（Markdown が HTML を分断する）。lint が E04 で検出する
- HTML の中は Markdown が効かない。`<h3>` `<p>` `<ul><li>` `<strong>` を直接書く
- アイコンは `node scripts/icon.mjs <name>` の出力（1 行 SVG）を `<div class="icon">` の中に貼る
- 主役は `emph`、従は無指定、背景に沈めるなら `muted` / `soft`、未確定は `dashed`。1 枚に主役は 1 つ

---

## A. 関係がある

### A1. 並列・横並び — `.cols.cols-N > .card`
用途：対等な 2〜4 要素（原因・選択肢・特徴）。テキスト量が少ないとき。
```html
<div class="cols cols-3">
  <div class="card"><div class="icon">SVG</div><h3>見出し</h3><p>説明 1〜2 行</p></div>
  <div class="card emph"><div class="icon">SVG</div><h3>主役</h3><p>説明</p></div>
  <div class="card"><div class="icon">3</div><h3>見出し</h3><p>説明</p></div>
</div>
```
- `.card` → 枠付き。`.card.soft` → 面のみ。`.item` → 枠なし（PDF の「オブジェクトを入れずに並べる」）
- `.icon` の中はアイコン SVG か 1 文字（番号・記号）。`.icon.lg` で大きく、`.center-text` で中央揃え
- 4 個以上のテキスト量が多い並列は 2 段組みではなく **A2 縦並び**か 2 枚に分ける

### A2. 並列・縦並び — `.rows > .row`
用途：テキスト量が多い並列、まとめ（テイクアウェイ 3 点）、手順でない列挙。
```html
<div class="rows">
  <div class="row"><div class="num">1</div><div><h3>見出し</h3><p>説明</p></div></div>
  <div class="row"><div class="icon">SVG</div><div><h3>見出し</h3><p>説明</p></div></div>
</div>
```
- 左は `.num`（番号）か `.icon`。`.row.boxed` で枠付き、`.row.wide` で「見出し | 説明」の 2 列

### A3. 複数羅列（4〜6 個） — `.cols.cols-3` を 2 段、または `.cols.cols-4`
用途：機能一覧・チーム構成など 4 個以上。文字は見出し + 1 行に絞る。7 個以上は 2 枚に分ける（lint W06）。

### A4. 比較・左右 — `.compare > .side .vs .side`
用途：A 案 vs B 案、自前 vs ライブラリ。片方を `emph` にして結論を示す。
```html
<div class="compare">
  <div class="side"><h3>A 案</h3><ul><li>…</li></ul></div>
  <div class="vs">vs</div>
  <div class="side emph"><h3>B 案（採用）</h3><ul><li>…</li></ul></div>
</div>
```

### A5. ビフォーアフター — `.compare.arrow`
用途：変更前後、移行前後。中央を `<div class="vs">→</div>` にする。数値の変化は `.big` で。
```html
<div class="compare arrow">
  <div class="side muted"><h3>Before</h3><div class="big">6 件/月</div><p>不整合バグの報告</p></div>
  <div class="vs">→</div>
  <div class="side emph"><h3>After</h3><div class="big">0 件/月</div><p>移行後 3 か月</p></div>
</div>
```

### A6. 表での比較 — Markdown テーブル
用途：観点が 3 つ以上ある比較。採用行を `**太字**` にする。行 5 以内、列 4 以内。
```markdown
| 戦略 | コスト | 整合性 | 採否 |
|---|---|---|---|
| **無効化を一本化** | **中** | **更新直後から最新** | **採用** |
```
- 文字が多いなら `<table class="compact">` を HTML で書く

### A7. 規模比較・数値 — `.stats > .stat`
用途：KPI、Before/After の数値、ベンチマーク結果。2〜3 個。
```html
<div class="stats">
  <div class="stat emph"><div class="value">0<span class="unit">件/月</span></div><div class="label">不整合バグ</div></div>
  <div class="stat"><div class="value">14<span class="unit">→ 3</span></div><div class="label">呼び出し箇所</div></div>
</div>
```
- `.stats.boxed` で枠付き。`.delta` で増減を添える。数値は 1 枚 3 個まで

### A8. フロー・横型 — `.flow > .step`
用途：手順・パイプライン・時系列（3〜5 段）。矢印は自動。
```html
<div class="flow">
  <div class="step"><span class="num">1</span><h3>棚卸し</h3><p>説明</p></div>
  <div class="step emph"><span class="num">2</span><h3>実装</h3><p>説明</p></div>
  <div class="step"><span class="num">3</span><h3>切替</h3><p>説明</p></div>
</div>
```
- 文字が少なくアイコンで見せるなら `.step.plain` + `.icon`（PDF の「横型・アイコンあり」）
- 項目が 5 つを超える、または説明が長いなら `.flow.vertical`（縦型）

### A9. フロー・縦型 — `.flow.vertical > .step`
用途：段数が多い、各段の説明が長い。4 段まで。それ以上はタイムラインか 2 枚。

### A10. サイクル — `.cycle.n3 / .cycle.n4 > .node` + `.center`
用途：循環するプロセス（観測→分析→改善）。3〜4 要素。
```html
<div class="cycle n3">
  <div class="node emph"><h3>観測</h3><p>説明</p></div>
  <div class="node"><h3>棚卸し</h3><p>説明</p></div>
  <div class="node"><h3>修正</h3><p>説明</p></div>
  <div class="center">月次レビュー</div>
</div>
```

### A11. タイムライン — `.timeline > .event`
用途：月単位の経緯、リリース履歴。3〜5 点。過去や未確定は `.event.muted`。
```html
<div class="timeline">
  <div class="event muted"><span class="time">2026-04</span><h3>障害</h3><p>説明</p></div>
  <div class="event"><span class="time">2026-05</span><h3>計測開始</h3><p>説明</p></div>
</div>
```

### A12. 階段・段階 — `.flow` の `.step` を `emph` で段階的に、または `.pyramid`
用途：成熟度モデル、導入レベル。段階の高低を示すなら A13。

### A13. ピラミッド・逆ピラミッド — `.pyramid(.inverted) > .tier`
用途：土台から積み上げる関係（観測 → テスト → 設計）、優先度。3〜4 段。
```html
<div class="pyramid">
  <div class="tier emph">最上段<small>補足</small></div>
  <div class="tier">中段</div>
  <div class="tier">土台</div>
</div>
```
- 最初の `.tier` が頂点。`.inverted` で漏斗（下に行くほど小さい）

### A14. レイヤー（積層） — `.layers > .layer`
用途：アーキテクチャの層、責務の分担。左に層名、右に `.chip` で構成要素。3〜5 層。
```html
<div class="layers">
  <div class="layer"><h3>Controller</h3><div class="chips"><span class="chip gray">認可</span></div></div>
  <div class="layer emph"><h3>Repository</h3><div class="chips"><span class="chip">DB 更新</span><span class="chip">無効化</span></div></div>
</div>
```

### A15. 包括（入れ子） — `.nest > h3 + .inner > .card.soft`
用途：全体の中の部分、モジュールと内部関数、スコープ。
```html
<div class="nest"><h3>UserRepository</h3>
  <div class="inner"><div class="card soft"><h3>update()</h3><p>…</p></div><div class="card soft"><h3>find()</h3><p>…</p></div></div>
</div>
```

### A16. ベン図 — `.venn > .a .b .ab`
用途：2 概念の重なり（正しさ × 速さ）。3 円は作らない（読みにくい）。
```html
<div class="venn"><div class="a">正しさ</div><div class="b">速さ</div><div class="ab">更新時に無効化</div></div>
```

### A17. マトリクス（2×2） — `.matrix > .axis-y + .cell×4 + .axis-x`
用途：2 軸での位置づけ・選定理由。右上が主役になるように軸を選ぶ。
```html
<div class="matrix">
  <div class="axis-y">縦軸ラベル →</div>
  <div class="cell"><h3>左上</h3><p>…</p></div><div class="cell emph"><h3>右上</h3><p>…</p></div>
  <div class="cell"><h3>左下</h3><p>…</p></div><div class="cell"><h3>右下</h3><p>…</p></div>
  <div class="axis-x">横軸ラベル →</div>
</div>
```

### A18. 数式（足し算・掛け算） — `.formula > .term .op .term`
用途：「A × B × C で決まる」「A + B = C」。指標の分解、コストの内訳。
```html
<div class="formula">
  <div class="term emph"><h3>書き手の数</h3><p>…</p></div><div class="op">×</div>
  <div class="term"><h3>呼び忘れ率</h3><p>…</p></div><div class="op">=</div>
  <div class="term"><h3>不整合の確率</h3></div>
</div>
```

### A19. ツリー図 — 未実装
テーマに専用 class は無い。Mermaid で SVG にして画像で貼る（`references/marp-notes.md` 参照）か、A14 レイヤーか A15 入れ子で言い換える。

---

## B. 関係がない

### B1. コード — フェンス ` ```lang `
- 8 行以内が理想、15 行が上限（lint W05）。1 行 64 字以内
- 焦点：`<pre class="focus"><code>…<mark>注目行</mark>…</code></pre>`（他の行は薄くなる）。HTML なので `<` `>` `&` はエスケープする
- 差分：` ```diff `。変更が 3 行以内のときに最も速く伝わる
- ターミナル：`<!-- _class: terminal -->` でそのスライドのコードブロックだけ黒背景

### B2. 本文 + 図 — `.two(.wide-left|.wide-right) > div + figure`
用途：スクリーンショット・グラフと説明。図を大きく、説明は 3 行以内。
```html
<div class="two wide-right">
  <div><ul><li>読み取り 1</li><li>読み取り 2</li></ul></div>
  <figure><img class="shot" src="img/dashboard.png" alt="…"><figcaption>出典</figcaption></figure>
</div>
```
- 画像を全面に敷くなら Marp の背景画像：`![bg right:45%](img.png)`（右 45% に画像、左に本文）
- キャプチャは 1 枚を大きく。2 枚並べるなら `.cols.cols-2` に `figure` を入れる

### B3. グラフ
- 数値が 3 つ以内なら B4 の `.stats` にする（グラフ不要）
- それ以上は matplotlib / Vega 等で **背景色と同じ色・強調色 1 色・グレー**で描いた PNG/SVG を貼る。凡例は消し、系列名を直接添える
- 見せたい 1 系列だけ強調色、他はグレー

### B4. 数値の押し出し — `.stats`（A7 と同じ）

### B5. 表 — Markdown テーブル。行 6 以内・列 4 以内。それ以上は「読ませる資料」なので Appendix に

### B6. 文だけ — `<!-- _class: message -->` + `#` の一文（56px）。区切りや強い主張に。3 枚に 1 枚以上使うと単調になる

### B7. 引用 — `<!-- _class: quote -->` + `> 引用文` + `<cite>出典</cite>`

### B8. 注記・補足 — `.callout`（面）、`.callout.accent`（強調）、`.callout.warn`（注意）。出典は `.note`

### B9. Q&A — 質問を `#`、答えをリード文に。1 枚 1 問

---

## C. ページ項目で決まる型

| 型 | class | 中身 |
|---|---|---|
| 表紙 | `title` | `#` タイトル（2 行まで）→ 段落でサブタイトル → `<div class="meta"><strong>名前</strong><span>所属</span><span>イベント名</span></div>` |
| 章扉 | `section` | `<div class="num">01</div>` → `#` 章名 → 段落でその章のねらい |
| メッセージ | `message` | `#` の一文だけ。補足があれば段落を 1 つ |
| DEMO | `demo` | `# DEMO` → 段落で見せる内容 |
| まとめ | （通常） | `# まとめ` → リード文に 1 文の結論 → `.rows` でテイクアウェイ 3 点（最後の 1 点は「明日やること」） |
| 締め | `end` | `# ありがとうございました` → 段落 → `<div class="links"><div><strong>Slides</strong>URL</div>…</div>` |

- 自己紹介は 1 枚・4 項目以内（名前、所属、今の仕事、この話との接点）。`.two` で写真 + 箇条書き
- 目次（アジェンダ）は 20 分以上の発表だけ。`.rows` の `.num` で 3〜5 項目
- 「ご質問はありますか？」だけのスライドは作らない。まとめを表示したまま Q&A に入る

---

## 付録：原典 39 パターンとの対応表

CONE inc.「パワーポイントのデザインパターン大全」の 39 パターンを、このテーマでどう作るかの対応。
「使う条件」は原典の記述。技術登壇で使わないものにも代替を書いてあるので、**どの型でも取り出せる**。

### 1. 要素間の関係が存在するパターン（21）

| # | 原典 | 使う条件（原典） | このテーマでの作り方 |
|---|---|---|---|
| 1 | 並列・横並び（丸アイコン） | テキスト量が少ない | `.cols.cols-3 > .card.center-text` + `.icon`（丸）。枠なしなら `.item` |
| 2 | 並列・横並び（四角） | 同上。非常に綺麗 | `.cols.cols-3 > .card` + `.icon`（角丸の面にするなら `.icon` を `.card.soft` 内に） |
| 3 | 並列・横並び（オブジェクト無し） | 箱を敷かない | `.cols.cols-3 > .item` |
| 4 | 並列・横並び（2 つ） | 要素が 2 つ | `.cols.cols-2 > .card`。対比の意味があるなら A4 `.compare` |
| 5 | 並列・縦並び（箱あり） | テキスト量が多い | `.rows > .row.boxed` |
| 6 | 並列・縦並び（箱なし） | 同上 | `.rows > .row` |
| 7 | 複数羅列 | 4 個以上 | `.cols.cols-4`（見出し + 1 行）。6 個までは `.cols.cols-3` を 2 つ。7 個以上は 2 枚 |
| 8 | 比較・規模比較 | 市場や数字の大きさの違い | `.stats`（数値の大小）。面積で見せたいときは `.venn` の円を大小にせず、数値で言う |
| 9 | 比較・項目比較 | 対応領域やフロー項目の違い | `.compare`（2 案）／`.layers` を 2 列にするなら `.two` に `.layers` を 2 つ |
| 10 | 比較・表での比較 | 比較項目が多い | Markdown テーブル。採用行を太字 |
| 11 | フロー・横型（アイコン） | 情報量が少ない | `.flow > .step.plain` + `.icon` |
| 12 | フロー・横型（箱） | 情報量が多い | `.flow > .step`（見出し + 説明） |
| 13 | フロー・縦型 | 項目が多く横に収まらない | `.flow.vertical > .step` |
| 14 | フロー・箱型 | 縦型でさらに情報が多い | `.rows > .row.wide`（左：段の名前、右：説明）。矢印は番号で代替 |
| 15 | サイクル・円 | 2〜3 個 | `.cycle.n3 > .node` + `.center` |
| 16 | サイクル・四角 | 4 個以上／テキスト多い | `.cycle.n4 > .node` |
| 17 | ピラミッド型 | 上位ほど規模が小さい | `.pyramid > .tier`（最初の tier が頂点） |
| 18 | じょうろ型（逆ピラミッド） | 下位ほど規模が小さい | `.pyramid.inverted > .tier` |
| 19 | マトリクス | 4 象限でポジショニング | `.matrix`（軸ラベル付き 2×2） |
| 20 | ベン図 | 要素が重なる | `.venn > .a .b .ab` |
| 21 | ツリー図 | 構成要素の関係全体 | 専用 class なし。Mermaid で SVG 化して `![w:900](fig.svg)`。3 段以内なら `.nest` で入れ子表現 |
| 22 | 数式 | 数字や定義の算出方法 | `.formula > .term .op`（`=` を含む） |
| 23 | 掛け算 | 相乗効果 | `.formula`（`.op` を `×`）。アイコンで見せるなら `.term` に `.icon.lg` |
| 24 | 足し算 | 組み合わせ | `.formula`（`.op` を `+`） |
| 25 | 領域 | 対応している範囲を示す | `.layers`（対象の層だけ `emph`）、または `.matrix` の該当セルを `emph` |
| 26 | 段階（階段） | プロセスの段階 | `.flow > .step`（最終段だけ `emph`）。高さの階段は `.pyramid.inverted` を横に読み替えず、`.timeline` か `.flow` で |
| 27 | 重複 | 同じ情報を繰り返さない | `.compare`（共通部分を上に `.callout`、差分だけ左右に） |
| 28 | 包括 | ①が②に属する | `.nest > h3 + .inner > .card.soft` |
| 29 | 相互関係 | 双方に関係がある | `.compare`（中央 `.vs` を `⇄`）。3 者以上は `.cycle` |
| 30 | ビフォーアフター | 従来との違い | `.compare.arrow`（`.side.muted` → `.side.emph`、数値は `.big`） |

（原典の番号付けは一覧表の並びに合わせた。21 と 22〜30 は原典で「その他の関係図」として並ぶ）

### 2. 要素間の関係が存在しないパターン（15）

| # | 原典 | 使う条件（原典） | このテーマでの作り方 |
|---|---|---|---|
| 31 | グラフ・縦棒 | 伸び率・増減 | 数値が 3 つ以内なら `.stats`。それ以上は自作グラフ画像（強調色 1 色 + グレー）を `figure` で |
| 32 | グラフ・横棒 | 項目の大小 | `.ranking > .rank`（CSS だけで横棒。`--v` で長さ） |
| 33 | グラフ・円 | 占める割合 | 円グラフは作らない。`.stats` で主要な割合を数値で、または `.ranking` |
| 34 | グラフ・折れ線 | 推移 | 自作グラフ画像。1 系列だけ強調色 |
| 35 | グラフ・その他（積み上げ等） | 組み合わせ | 自作グラフ画像。凡例を消し系列名を直接添える |
| 36 | キャプチャ・羅列 | 画面を並べる | `.gallery.cols-2/3 > figure > img.shot + figcaption` |
| 37 | キャプチャ・拡大 | 対応箇所・遷移 | `.two.wide-right` に `.annotate`（`.pin` / `.box` で注目箇所） |
| 38 | キャプチャ・フロー | 画面遷移 | `.gallery.cols-3` の figcaption に `1 → 2 → 3` の番号。矢印が要るなら `.flow > .step.plain` に `img` |
| 39 | 料金体系・表 | 項目が多い | Markdown テーブル（技術登壇ではクラウド料金比較などに） |
| 40 | 料金体系・その他 | 項目が少ない | `.stats.boxed`（金額を `.value`、条件を `.label`） |
| 41 | 表 | アイコン不要でテキストが多い | Markdown テーブル、密なら `<table class="compact">` |
| 42 | 拠点 | 位置関係 | 地図画像を `figure` で。技術登壇ではリージョン構成などに |
| 43 | スケジュール | 導入までの流れ | `.timeline`（3〜5 点）、細かければテーブル |
| 44 | ランキング | 立ち位置・順位 | `.ranking > .rank`（自分を `emph`） |
| 45 | 事例 | 導入事例 | `.two`（左：概要の箇条書き、右：`figure` の画面）。技術登壇では「他社の採用例」「ユーザーの声」 |
| 46 | テキストのみ | 補足説明 | `.callout`（1 つ）か `.rows`。長文は書かない |
| 47 | Q&A | よくある質問 | 質問を `#`、答えをリード文に。1 枚 1 問 |
| 48 | 名言 | 偉人の言葉 + 写真 | `<!-- _class: quote -->` + `>` + `<cite>`。人物写真は権利が確認できるときだけ `.profile` |
| 49 | ピクトグラム | 話し言葉を質素にしない | `.cols.cols-3 > .item.center-text` + `.icon.lg`（1 語 + アイコン） |

（原典はグラフ 5・キャプチャ 3・料金体系 2・その他 9 の 19 項目を「15 パターン」として数えている）

### 3. ページ項目に応じて決まっているパターン（8 項目）

| 原典 | 使う条件（原典） | このテーマでの作り方 |
|---|---|---|
| 表紙（テキスト少） | 資料名のみ | `<!-- _class: title -->`、`#` + サブタイトル + `.meta` |
| 表紙（テキスト多） | 記載事項が多い | 同上。`.meta` に名前・所属・イベント・日付。副題は 1 行まで |
| 目次（通常） | 項目が少ない | `.rows > .row` + `.num`（3〜5 項目）。20 分未満なら目次を作らない |
| 目次（見出し付き） | 項目が多い | `.cols.cols-2` に `.rows` を 2 つ（章ごと） |
| 目次（円／点） | ウェビナー・採用ピッチ | 使わない。章扉（`section`）で代替 |
| 会社概要 | ロゴ・項目 | 技術登壇では不要。所属の説明が要るなら `.profile` の箇条書きに 1 行 |
| メンバー紹介（1〜4 人以上） | 代表・ボード | 自己紹介：`.profile`（写真 + 箇条書き 4 項目）。複数人は `.cols.cols-3 > .card.center-text` + `.avatar` |
| MVV 提示 | 理念 | `<!-- _class: message -->`（大きな一文）。技術登壇では「チームの方針」などに |
| 背景静止画（中央／左揃え／2 枚／ウェビナー／その他） | インパクト・緩急 | `![bg](img)` + `<!-- _class: overlay -->`。1 デッキ 1 枚まで。技術の話では原則使わない |
| 会社沿革（時系列／グラフ／組み合わせ） | 節目 | `.timeline`。プロダクトの歴史・バージョン履歴に |
| 導入実績（ロゴ／数値／月桂冠） | 訴求 | `.brands`（採用しているツールのロゴ列）、`.stats`（利用数） |
| 組織図 | 体制 | `.layers`（層で表せる場合）か `.nest`。厳密な組織図は Mermaid |

**使い方**：構想フェーズで各枚に「型」を割り当てるとき、この表の右列の class を書く。原典の番号で参照されたら（「原典 26 の階段で」）、この表から引く。
