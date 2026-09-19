# コードの見せ方

技術登壇の核はコード。ただし「スライドはコンパイルされない」。読ませたい 1 点だけ残す。

## 量の規則

| 項目 | 値 |
|---|---|
| 行数 | 8 行以内が理想、15 行が上限（lint W05） |
| 1 行の長さ | 64 字以内。超えると右に溢れる（`overflow: hidden` で切れる） |
| 1 枚のコードブロック数 | 1 つ。比較は `.two` か ` ```diff ` |
| フォントサイズ | 24px（18pt）。Marp の自動縮小に頼らない（小さくなりすぎる） |

## ノイズを削る

- import、型注釈の一部、エラーハンドリング、ログ出力、ボイラープレートは省く。省いた箇所は `// ...` で示す
- 変数名は本物より短く分かりやすく（`userRepository` → `repo`）
- コメントは行末に 1 つだけ、「ここだけ」「← 追加」のように視線を導く目的で
- 完全なコードは GitHub 等のリンクを締めのスライドに置き、「スライドのコードは抜粋」と口頭で言う

## 焦点を移す

### 1. 段階表示（同じコードを 2〜3 枚で育てる）
1 枚目に骨格だけ、2 枚目で本体、3 枚目で例外処理。各枚のリード文はその枚で足した部分の主張にする。

### 2. 焦点行の強調 — `pre.focus` + `<mark>`
```html
<pre class="focus"><code>class UserRepository {
  async update(user: User) {
    await this.db.users.update(user);
<mark>    await this.cache.invalidate(`user:${user.id}`);</mark>
  }
}</code></pre>
```
- 他の行は薄いグレーになる。HTML なので `<` → `&lt;`、`>` → `&gt;`、`&` → `&amp;` にエスケープ
- シンタックスハイライトは付かない（意図的。焦点行以外に色があると視線が散る）

### 3. 差分 — ` ```diff `
変更が 3 行以内なら最も速い。`-` と `+` の行だけ色が付く。前後 1〜2 行の文脈を残す。

### 4. Before / After — `.compare.arrow` に `<pre>` を入れる
```html
<div class="compare arrow">
  <div class="side muted"><h3>Before</h3><pre><code>…</code></pre></div>
  <div class="vs">→</div>
  <div class="side emph"><h3>After</h3><pre><code>…</code></pre></div>
</div>
```
- 左右それぞれ 6 行以内、1 行 30 字以内

## ターミナル

`<!-- _class: terminal -->` を付けたスライドはコードブロックが黒背景になる。コマンドと出力を見せるときだけ。

```bash
$ curl -s localhost:9090/metrics | grep stale
cache_stale_hit_total{repo="user"} 2
```

- プロンプト `$` を付け、出力は 3〜5 行に絞る
- 長いログは「…」で省き、注目行の後ろに `# ← ここ` を付ける

## 言語別の注意

- **TypeScript / JavaScript**：型注釈は主張に関係する箇所だけ残す
- **Go**：エラーハンドリングの `if err != nil` は 1 箇所だけ残して他は省く
- **Python**：デコレータ・型ヒントは見せたいときだけ。インデントの崩れに注意
- **SQL**：予約語は大文字、1 句 1 行
- **YAML / JSON**：ネストは 3 段まで。深いものは該当部分だけ抜く
- **Shell**：`\` の行継続で 1 行 64 字以内に折る

## 図とコードの使い分け

- 「どこに置くか」「何が何を呼ぶか」は図（`layers` / `flow` / `nest`）で、「どう書くか」はコードで
- コードの前に全体像の図を 1 枚置くと、コードの行数を減らせる
- アーキテクチャ図に実際のクラス名・テーブル名・トピック名を書く。抽象語（Platform、Layer）だけの箱を作らない
