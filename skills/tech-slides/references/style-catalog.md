# スタイルカタログ（テーマの選び方）

同じ Markdown を、frontmatter の `theme:` を変えるだけで別の雰囲気に描ける。
class 名・図解パターン・lint の規則は全テーマ共通。**内容を書き直さずに見た目だけ差し替えられる**のが前提。
見本は `examples/styles/<theme>/`（`examples/showcase.md` を各テーマで描いたもの）。並べた比較は `examples/styles/compare.png`。

## 5 つのテーマ

| テーマ | 一言 | 地 / 強調色 / 書体 | 向く発表 |
|---|---|---|---|
| `tech-light`（既定） | 明るく整った技術資料 | アイボリー or 白 / teal / Noto Sans JP | カンファレンス登壇、社内勉強会の標準。迷ったらこれ |
| `tech-dark` | 暗いステージ、コードが主役 | 墨に近い紺 / ミント / Noto Sans JP | ライブコーディング、ターミナル・ログを多く見せる発表、夜のセッション、暗い会場 |
| `editorial` | 雑誌の誌面。箱を使わず罫で組む | 生成りの紙 / 墨と藍 / 明朝（Shippori Mincho B1 + Noto Serif JP） | 設計思想・ふりかえり・キャリア談など「考え方」を語る発表。図より言葉が多い回 |
| `swiss` | 非対称グリッド、黒の太い罫と活字、角丸なし | 白 / 黒 + 赤 / Inter + IBM Plex Sans JP | プロダクト発表、キーノート、数字を大きく見せたい回。要素が少ないほど映える |
| `pop` | 丸ゴシック、大きな角丸、5 色のパステル | クリーム / 桃・ミント・ラベンダー・レモン・空 + 珊瑚 / Zen Maru Gothic | コミュニティ LT、初学者向け入門、ハンズオン。親しみやすさを出したい回 |

強調色はどのテーマでも `accent-indigo / coral / slate / plum` で差し替えられる（`class:` 行に足す）。
「1 デッキ 1 色」の原則は tech-light / tech-dark / editorial / swiss のもの。**pop だけは多色が前提**で、並列要素（カード・工程・数値・タイムライン…）に 5 色が順番に当たり、`emph` だけが強調色になる。

各テーマが tech-light と違えている点（Markdown は同じでも、ここが変わる）：

| テーマ | 骨格の違い |
|---|---|
| `tech-dark` | 色だけ。レイアウトは tech-light と同じ |
| `editorial` | 見出しの上に二重罫の柱。箱・色面を使わず、並列要素は上罫 1 本で区切る。表紙は発行情報が上、題が左下、副題が右端に縦組み。章扉は紙の色のまま 260px の数字。数値は明朝の細字 |
| `swiss` | 題は全幅で下に太罫、リード文は右 2/3 の列に寄せる非対称グリッド。並列要素は 5px の黒い上罫だけ。章扉は赤の全面。数値 124px。ピラミッドは黒地に白 |
| `pop` | 5 色が並列要素に順に当たる。枠線なし、面と丸で塊を作る。表紙・章扉・締めに大きな色の丸 |

## 「〜みたいな」と言われたときの対応表

ユーザーは固有名や雰囲気の言葉で頼んでくる。次の表で最も近いテーマを選び、**選んだ理由を一文で添えて確認する**。
固有名は「その雰囲気に近い」の意味で、当該ブランドの再現ではない。

| ユーザーの言葉（例） | 選ぶテーマ | 補足 |
|---|---|---|
| 普通にきれいな技術スライド、GitHub のドキュメントみたいな、Zenn の記事みたいな、Google の技術資料っぽい | `tech-light` | 既定 |
| ダークで、ターミナルっぽく、ハッカーっぽく、VS Code のダークテーマみたいな、GitHub Universe / Next.js Conf / Vercel の発表みたいな、開発者カンファレンスの夜の感じ | `tech-dark` | 暗い会場・配信画面でも映える |
| Apple の基調講演みたいな（黒背景） | `tech-dark` + `accent-slate` | 文字は少なく、`message` 型を多めに |
| Apple の基調講演みたいな（白背景）、ミニマル、タイポグラフィで見せたい、Helvetica、バウハウス、Figma Config みたいな、数字をドンと | `swiss` | 1 枚の要素を 3 つ以下に絞ると本領を発揮する |
| 雑誌みたいな、書籍っぽい、明朝で落ち着いた、大人っぽい、文芸っぽい、Stripe Press みたいな、ほぼ日みたいな | `editorial` | 色面を使わないので、写真・スクリーンショットの多い回とも相性がよい |
| かわいく、やわらかく、ポップに、親しみやすく、Notion / Canva のテンプレみたいな、初心者向け勉強会っぽく | `pop` | 強調色を `accent-indigo` にすると珊瑚色が抜けて青系の柔らかさになる |
| Google I/O みたいなカラフル | `pop` + `accent-indigo` | 多色は使わない方針なので、丸みと明るさで寄せる |
| 会社のブランドカラーで | 最も近いテーマ + 新しい accent class | 「新しいスタイルを足す」を参照。色は 1 色だけ受け取る |
| 前回のスライドと同じ | 前回のデッキの frontmatter を見る | `theme:` と `class:` をそのまま使う |

どれにも当てはまらないときは、**tech-light を提案しつつ、参考画像や URL を 1 つもらう**。もらった参考の「地の明暗・書体の系統（ゴシック / 明朝 / 丸ゴ）・角丸の有無・色数」の 4 点でこの表に当てはめる。

## 選んだあとにやること

1. frontmatter に `theme: <name>` を書く。`class: ivory` は tech-light 用の指定で、他テーマでは無視される（残っていても害はない）
2. 強調色を変えるなら `class:` に `accent-*` を足す
3. `python3 scripts/lint_slides.py <slug>.md` が frontmatter の `theme:` を見て class を検査する（無いテーマ名は E05）
4. `bash scripts/build.sh <slug>.md --png` で描画する。見比べたいときは `--theme <name> --out <dir>` で Markdown を変えずに別テーマを描ける

```bash
# 3 テーマを並べて見せる
for t in tech-light editorial swiss; do
  bash scripts/build.sh talk.md --theme $t --out preview-$t
done
```

## テーマごとの注意

- **tech-dark**：白背景のスクリーンショットは浮く。`.gallery` か `figure` で `--surface` の枠に入れる。ロゴ（simple-icons）はブランド色のままなので暗い色のロゴ（GitHub など）は見えにくい。`.icon.brand` の面が下敷きになる
- **editorial**：明朝は小さいと細くなる。カード内本文 24px より小さくしない。箱が無いので、並列要素の本文は 2〜3 行に揃えると罫が段になって美しい。コードは等幅ゴシックのままなので、コード中心の回には向かない。表紙の副題（縦組み）は 30 字以内
- **swiss**：リード文が右 2/3 に寄るので、リード文は 2 行以内に。要素が多いと窮屈に見える。並列は 3 つまで、箇条書きは 4 行まで。マトリクス・サイクルは高さを 400px に詰めている
- **pop**：色は要素の「順番」で決まり意味を持たない（1 番目は常に桃）。色で意味を伝えたい場面には向かない。並列要素は 5 つまで（6 つ目で桃に戻る）。表紙・章扉・締めに色の丸が入る

## 新しいスタイルを足す

1. `themes/<name>.css` を作り、先頭を次の形にする。tech-light の全 class を継承するので、**トークン（色・書体・角丸）と表紙・章扉だけ**書けば成立する

```css
/* @theme <name> */
/* @auto-scaling true */
@import url('https://fonts.googleapis.com/css2?family=...&display=swap');  /* 使うなら */
@import 'tech-light';
section { --bg: …; --ink: …; --accent: …; --accent-soft: …; --accent-ink: …; --radius: …; --font-sans: …; }
section.ivory { /* tech-light 用の class を無害化するため、上と同じ地の値を書く */ }
```

2. `bash scripts/build.sh examples/showcase.md --theme <name> --out examples/styles/<name> --png` で 31 枚を描き、`sheet-*.png` を全部見る。ベン図・タイムライン・ターミナル・ギャラリーは地の色に引きずられやすい
3. このファイルの表 2 つに 1 行ずつ足す
4. `README.md` の一覧に足す

暗色テーマを作るときは `tech-dark.css` を、色面を使わない紙のようなテーマは `editorial.css` を写す。
