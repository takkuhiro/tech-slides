#!/usr/bin/env node
// icon.mjs — アイコンを Markdown に貼れる1行の SVG として出力する
//
//   汎用アイコン（Lucide, ISC）
//     node scripts/icon.mjs server database cloud       → 名前ごとに1行の <svg …>（stroke は currentColor）
//     node scripts/icon.mjs --search cache             → 名前に cache を含むアイコンを一覧
//
//   ブランド・ツールのロゴ（simple-icons, CC0。各社の商標ガイドラインは別途尊重する）
//     node scripts/icon.mjs --brand github docker kubernetes   → ブランド色で塗った1行の <svg …>
//     node scripts/icon.mjs --brand --mono github              → currentColor（単色）で出力
//     node scripts/icon.mjs --brand --search google            → スラッグを検索
//
// 出力は <div class="icon">…</div>（汎用）や <div class="icon brand">…</div>（ロゴ）の中にそのまま貼る。
import { readFileSync, readdirSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const lucideDir = join(root, "node_modules", "lucide-static", "icons");
const brandDir = join(root, "node_modules", "simple-icons", "icons");

let args = process.argv.slice(2);
if (args.length === 0) {
  console.error("usage: icon.mjs <name>... | --search <word> | --brand [--mono] <slug>... | --brand --search <word>");
  process.exit(2);
}
const brand = args.includes("--brand");
const mono = args.includes("--mono");
args = args.filter((a) => a !== "--brand" && a !== "--mono");
const dir = brand ? brandDir : lucideDir;
if (!existsSync(dir)) {
  console.error(`${brand ? "simple-icons" : "lucide-static"} が見つかりません。次を実行: (cd "${root}" && npm install)`);
  process.exit(3);
}

const oneLine = (s) => s.replace(/<!--.*?-->\s*/gs, "").replace(/\s*\n\s*/g, " ").replace(/\s{2,}/g, " ").replace(/ >/g, ">").trim();

if (args[0] === "--search") {
  const q = (args[1] || "").toLowerCase();
  const names = readdirSync(dir).filter((f) => f.endsWith(".svg")).map((f) => f.slice(0, -4)).filter((n) => n.includes(q));
  console.log(names.join("\n"));
  process.exit(0);
}

for (const name of args) {
  const p = join(dir, `${name}.svg`);
  if (!existsSync(p)) {
    console.error(`not found: ${name}（--search で探せます${brand ? "。スラッグは小文字・記号なし。例: nextdotjs, amazonwebservices" : ""}）`);
    continue;
  }
  let svg = readFileSync(p, "utf8");
  if (brand) {
    // simple-icons: <svg role="img" viewBox="0 0 24 24"><title>X</title><path d="…"/></svg>
    let fill = "currentColor";
    if (!mono) {
      try {
        const mod = await import("simple-icons");
        const key = "si" + name.replace(/^(\d)/, (d) => ({ 1: "one", 2: "two", 3: "three", 4: "four", 5: "five", 6: "six", 7: "seven", 8: "eight", 9: "nine", 0: "zero" })[d]).replace(/dot/g, "dot");
        const found = Object.values(mod).find((v) => v && v.slug === name);
        if (found?.hex) fill = `#${found.hex}`;
      } catch {}
    }
    svg = svg.replace("<svg ", `<svg width="24" height="24" fill="${fill}" `).replace(/<title>.*?<\/title>/, "");
  } else {
    svg = svg.replace(/\s+class="[^"]*"/, "");
  }
  console.log(oneLine(svg));
}
