# 画像・素材の扱い

技術の話でも、画像が根拠になる場面は多い。**アプリの紹介にはその画面、ツールの紹介にはそのロゴ、記事や動画の紹介にはそのサムネイル。**
構想フェーズで「どの枚にどの画像が要るか」を決め、取れるものは自分で取り、取れないものはユーザーに具体的に依頼する。

## いつ画像を使うか

| 話題 | 置く画像 | 型 |
|---|---|---|
| 自作・自社アプリ、ダッシュボード、UI の話 | 実際の画面のスクリーンショット（注目箇所だけ切り出す） | `two` + `figure`、`gallery`、`annotate` |
| ツール・サービス・言語の紹介、技術スタック | ロゴ（simple-icons） | `icon brand`、`brands` |
| 参考にした記事・ドキュメント・発表 | OG 画像（サムネイル）+ タイトル + 出典 | `thumb`、`thumbs` |
| 参考にした YouTube 動画 | サムネイル + タイトル + URL | `thumb video` |
| 計測結果・グラフ | 自分で描いた図（強調色 1 色 + グレー） | `two`、`figure` |
| 自己紹介 | 顔写真かアバター | `profile` |
| 概念・比喩 | **写真は使わない**。図解パターンで描く | — |

- 1 枚に画像は 1 つが基本。比較・羅列で 2〜3 枚まで（`gallery`、`thumbs`）
- 画像はリード文の根拠として置く。飾りにしない。「この画面のどこを見てほしいか」をリード文か注記で言う
- スクリーンショットは注目箇所を切り出すか、`annotate` の `.pin` / `.box` で示す。全画面を小さく貼らない
- 画質：横 1000px 以上。拡大して粗い画像は貼らない

## 取得の手順（自分で取れるもの）

作業ディレクトリに `assets/` を作り、Markdown からは相対パス `assets/xxx.png` で参照する。

```bash
S=<skill root>
# ブランド・ツールのロゴ（simple-icons、3,400 種、CC0）→ 1 行 SVG。<div class="icon brand"> に貼る
node $S/scripts/icon.mjs --brand github docker kubernetes
node $S/scripts/icon.mjs --brand --search cloud            # スラッグを探す（例: googlecloud, amazonwebservices, nextdotjs）

# 記事・ページの OG 画像、YouTube サムネイル、直接の画像 URL → assets/ に保存
bash $S/scripts/fetch_asset.sh "https://zenn.dev/…/articles/…" article-marp
bash $S/scripts/fetch_asset.sh "https://www.youtube.com/watch?v=XXXX" talk-video
bash $S/scripts/fetch_asset.sh "https://example.com/diagram.png"

# 公開 Web ページのスクリーンショット（1280×800）
bash $S/scripts/screenshot.sh "https://marp.app" marp-site --size 1280x800
```

- simple-icons に無い企業（OpenAI・Microsoft・Amazon など。商標の都合で収録されない）は、公式サイトの favicon を `https://www.google.com/s2/favicons?domain=<domain>&sz=128` で取り、`.icon.brand` に `<img>` で入れる。16px しか返らない企業は `icons.duckduckgo.com/ip3/<domain>.ico`（48px）を試し、それでも粗ければ文字にする
- 取得した画像の出典（サイト名・URL・著者）を `figcaption` か `.note` に必ず書く。引用の範囲で使う
- ロゴは各社の商標ガイドラインの対象。改変（色変え・変形）せず、そのサービスを指す目的でだけ使う。`--mono` の単色化はガイドラインで許されているものだけ
- OG 画像が取れないページは `screenshot.sh` でページ全体を撮る。それも駄目ならユーザーに依頼

## ユーザーに依頼するもの（自分では取れない）

- ログインが要る画面、社内ツール、ローカルで動くアプリ、デスクトップアプリの画面
- 本人・チームの写真、社内資料の図、実測データのグラフ元データ
- 権利上の確認が要る画像（他社の資料、有料コンテンツ）

依頼は**構想フェーズの終わりに一覧で**出す。1 点ずつ小出しにしない。形式：

```
## 用意をお願いしたい素材
| # | 使う枚 | 何の画像か | 撮り方・条件 | 保存名 |
|---|---|---|---|---|
| 1 | p7 | 管理画面の一覧ページ | 1280px 幅以上、ダミーデータで、対象の行が見える状態 | assets/admin-list.png |
| 2 | p12 | Grafana のダッシュボード（6 月分） | stale hit のパネルが入る範囲 | assets/grafana-june.png |
```

- 「何を見せたいか」が伝わる条件を書く（どの画面、どの状態、どの範囲、機密の伏せ方）
- 届くまでは `<div class="card dashed">` のプレースホルダーで枚を組み、届いたら差し替える。プレースホルダーのまま納品しない

## Markdown での貼り方

```markdown
<!-- 1 枚を大きく（本文 + 図） -->
<div class="two wide-right">
  <div><ul><li>読み取り 1</li><li>読み取り 2</li></ul></div>
  <figure><img class="shot" src="assets/dashboard.png" alt="ダッシュボード"><figcaption>Grafana（2026-06）</figcaption></figure>
</div>

<!-- 注目箇所を示す -->
<div class="annotate"><img class="shot" src="assets/admin.png" alt="管理画面" width="900"><span class="pin" style="left:120px; top:80px">1</span><span class="box" style="left:100px; top:60px; width:300px; height:80px"></span></div>

<!-- 記事・動画の紹介 -->
<div class="thumb"><img src="assets/article-marp.png" alt=""><div><h3>参考にした記事のタイトル</h3><p>記事で扱っている内容の要約を 1 行</p><p class="src">example.com/articles/… — 2024</p></div></div>

<!-- ツールのロゴを並べる -->
<div class="brands">
  <div class="brand-item">SVG<span>GitHub Actions</span></div>
  <div class="brand-item">SVG<span>Docker</span></div>
</div>

<!-- 右 45% に画像を敷く（Marp の背景画像） -->
![bg right:45% fit](assets/screen.png)
```

- 全面に画像を敷いて文字を載せる（`![bg](…)` + `<!-- _class: overlay -->`）のは表紙か 1 枚だけ。文字の下に白の下敷きが付く
- 動画は PDF に埋め込めない。サムネイル + URL を貼り、発表時はブラウザで開く（`deck.html` からリンクで飛べる）
