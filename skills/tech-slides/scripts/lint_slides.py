#!/usr/bin/env python3
"""lint_slides.py — Marp Markdown を「1スライド1メッセージ」の規律で機械チェックする

    python3 scripts/lint_slides.py deck.md [--theme themes/tech-light.css] [--json]

終了コード: 0 = 問題なし / 1 = error あり（warn だけなら 0）

チェック項目（E = error, W = warn, I = info）
  E01 見出し（#）が 1 枚に 2 つ以上ある            … 1スライド1メッセージに反する
  E02 header / footer / paginate:true の指定       … ヘッダー・フッターは入れない
  E03 テーマに無い class を使っている               … 描画されず崩れる
  E04 HTML ブロックの途中に空行がある               … Markdown が HTML を分断し、生タグが表示される
  E05 frontmatter の theme: が themes/ に無い       … 描画時に既定テーマへ落ちて見た目が変わる
  W01 リード文が無い（# の直後に段落が無い）         … 章扉・表紙・メッセージ以外は必須
  W02 リード文が長い（60 字超）                    … 一文で言い切る
  W03 タイトルが長い（30 字超）                    … 2 行に折り返す
  W04 箇条書きが多い（最上位 6 項目以上）／ネスト 3 段以上
  W05 コードが長い（16 行以上）／1 行が 64 字超      … 8 行以内が理想
  W06 並列要素（card/step/stat/row/cell 等）が 7 個以上
  W07 文字量が多い（本文 220 字超。コード・HTML タグ除く）
  W08 <p class="lead"> や見出しの直後の段落が 2 文以上（。が 2 つ以上）
  I01 スライド枚数と、話す時間の目安（1 枚 1〜2 分）
  I02 画像に alt が無い
"""
import sys, re, json, argparse, os

ERR, WARN, INFO = "error", "warn", "info"

SPECIAL_CLASSES = {"title", "section", "message", "end", "demo", "quote"}  # リード文不要のスライド型
PARALLEL_CLASSES = ("card", "item", "step", "stat", "row", "cell", "tier", "layer", "term", "node", "event", "side", "rank", "thumb", "brand-item")


def split_slides(md: str):
    """frontmatter を除き、コードフェンス外の '---' 行で分割する。各要素は (開始行番号, 本文)"""
    lines = md.split("\n")
    i = 0
    fm = {}
    if lines and lines[0].strip() == "---":
        j = 1
        while j < len(lines) and lines[j].strip() != "---":
            m = re.match(r"^([\w-]+):\s*(.*)$", lines[j])
            if m:
                fm[m.group(1)] = m.group(2).strip()
            j += 1
        i = j + 1
    slides, cur, start = [], [], i + 1
    in_fence = False
    for k in range(i, len(lines)):
        ln = lines[k]
        if re.match(r"^\s*(```|~~~)", ln):
            in_fence = not in_fence
        if not in_fence and re.match(r"^\s*---\s*$", ln):
            slides.append((start, "\n".join(cur)))
            cur, start = [], k + 2
            continue
        cur.append(ln)
    slides.append((start, "\n".join(cur)))
    return fm, slides


THEME_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "themes")


def resolve_theme(md, theme_arg):
    """--theme が無ければ frontmatter の theme: から themes/<name>.css を引く。既定は tech-light"""
    if theme_arg:
        if os.path.exists(theme_arg):
            return theme_arg
        return os.path.join(THEME_DIR, theme_arg + ".css")
    m = re.search(r"^theme:\s*([\w-]+)\s*$", md.split("\n---", 1)[0] if md.startswith("---") else "", flags=re.M)
    name = m.group(1) if m else "tech-light"
    return os.path.join(THEME_DIR, name + ".css")


def theme_classes(path, _seen=None):
    """テーマ CSS の class 名を集める。`@import 'name'` で継承しているテーマも辿る"""
    if not path or not os.path.exists(path):
        return None
    _seen = _seen or set()
    if path in _seen:
        return set()
    _seen.add(path)
    css = open(path, encoding="utf-8").read()
    css = re.sub(r"/\*.*?\*/", "", css, flags=re.S)
    classes = set(re.findall(r"\.([A-Za-z][\w-]*)", css))
    for name in re.findall(r"""@import\s+['"]([\w-]+)['"]""", css):
        sub = theme_classes(os.path.join(os.path.dirname(path), name + ".css"), _seen)
        classes |= sub or set()
    return classes


def strip_code(text):
    return re.sub(r"```.*?```", "", text, flags=re.S)


def visible_text(text):
    t = strip_code(text)
    t = re.sub(r"<!--.*?-->", "", t, flags=re.S)
    t = re.sub(r"<[^>]+>", "", t)
    t = re.sub(r"!\[[^\]]*\]\([^)]*\)", "", t)
    t = re.sub(r"^\s*#+\s.*$", "", t, flags=re.M)
    return re.sub(r"\s+", "", t)


def lint(md, theme_css=None):
    fm, slides = split_slides(md)
    issues = []
    known = theme_classes(theme_css)

    def add(level, code, slide, msg, line=None):
        issues.append({"level": level, "code": code, "slide": slide, "line": line, "message": msg})

    # frontmatter / global directives
    for key in ("header", "footer"):
        if key in fm and fm[key]:
            add(ERR, "E02", 0, f"frontmatter に {key} があります。ヘッダー・フッターは入れません")
    if fm.get("paginate", "false").lower() == "true":
        add(ERR, "E02", 0, "paginate: true になっています。ページ番号は描きません")

    for idx, (start, body) in enumerate(slides, 1):
        classes = set()
        for m in re.finditer(r"<!--\s*_?class:\s*([^-]*?)\s*-->", body):
            classes.update(m.group(1).split())
        for m in re.finditer(r"<!--\s*_?(header|footer|paginate):\s*(\S+)", body):
            if m.group(1) != "paginate" or m.group(2).lower() == "true":
                add(ERR, "E02", idx, f"ディレクティブ {m.group(1)} が使われています")

        nocode = strip_code(body)
        nocomment = re.sub(r"<!--.*?-->", "", nocode, flags=re.S)
        h1s = re.findall(r"^#\s+(.+)$", nocomment, flags=re.M)
        if len(h1s) >= 2:
            add(ERR, "E01", idx, f"見出し（#）が {len(h1s)} 個あります。1 枚には 1 つの主張だけ置きます")
        if h1s and len(h1s[0]) > 30:
            add(WARN, "W03", idx, f"タイトルが {len(h1s[0])} 字です。30 字以内に")

        # リード文
        is_special = bool(classes & SPECIAL_CLASSES)
        m = re.search(r"^#\s+.+\n+(?!<(?:div|p|pre|figure|table|ul|ol|img|blockquote|span|h[1-6])\b|<!--|```|[-*]\s|\d+\.\s|\|)(.+)$", nocomment, flags=re.M)
        lead = None
        if m:
            lead = m.group(1).strip()
        pm = re.search(r'<p class="lead">(.*?)</p>', nocomment, flags=re.S)
        if pm:
            lead = re.sub(r"<[^>]+>", "", pm.group(1)).strip()
        if h1s and not is_special and not lead:
            add(WARN, "W01", idx, "リード文がありません。# の直後に、この 1 枚で一番伝えたい一文を置きます")
        if lead:
            if len(lead) > 60:
                add(WARN, "W02", idx, f"リード文が {len(lead)} 字です。60 字以内の一文に")
            if lead.count("。") >= 2:
                add(WARN, "W08", idx, "リード文が 2 文以上です。一文で言い切ります")

        # 箇条書き
        top = re.findall(r"^(?:[-*]|\d+\.)\s", nocomment, flags=re.M)
        nested3 = re.findall(r"^(?: {4,}|\t{2,})(?:[-*]|\d+\.)\s", nocomment, flags=re.M)
        if len(top) >= 6:
            add(WARN, "W04", idx, f"最上位の箇条書きが {len(top)} 項目あります。5 項目以内か、図解パターンに")
        if nested3:
            add(WARN, "W04", idx, "箇条書きが 3 段ネストしています。2 段までに")
        li = len(re.findall(r"<li\b", nocomment))
        if li >= 9 and not top:
            add(WARN, "W04", idx, f"HTML の <li> が {li} 個あります。カードあたり 3 項目・全体 8 項目を目安に")

        # コード
        for fence in re.finditer(r"```[^\n]*\n(.*?)```", body, flags=re.S):
            code_lines = fence.group(1).rstrip("\n").split("\n")
            n = len(code_lines)
            longest = max((len(l) for l in code_lines), default=0)
            if n >= 16:
                add(WARN, "W05", idx, f"コードが {n} 行あります。8 行以内が理想、15 行が上限。分割するか要点だけ抜きます")
            if longest > 64:
                add(WARN, "W05", idx, f"コードの 1 行が {longest} 字あります。64 字以内で折り返します（横に溢れます）")
        for pre in re.finditer(r"<pre[^>]*>(.*?)</pre>", body, flags=re.S):
            n = pre.group(1).count("\n") + 1
            if n >= 16:
                add(WARN, "W05", idx, f"<pre> のコードが {n} 行あります。15 行以内に")

        # 並列要素数
        cnt = 0
        for c in PARALLEL_CLASSES:
            cnt += len(re.findall(r'class="(?:[^"]*\s)?%s(?:\s[^"]*)?"' % c, nocomment))
        if cnt >= 7:
            add(WARN, "W06", idx, f"並列の要素が {cnt} 個あります。6 個以下に絞るか、2 枚に分けます")

        # 文字量
        vt = visible_text(body)
        if len(vt) > 220:
            add(WARN, "W07", idx, f"本文が約 {len(vt)} 字あります（コード・タグ除く）。220 字を超えると読ませる資料になります")

        # HTML ブロックの分断（<div で始まる行の後、閉じる前に空行）
        depth = 0
        for ln_no, ln in enumerate(body.split("\n")):
            opens = len(re.findall(r"<div\b", ln)); closes = len(re.findall(r"</div>", ln))
            if depth > 0 and ln.strip() == "":
                add(ERR, "E04", idx, "HTML ブロック（<div>）の途中に空行があります。Markdown が HTML を分断し、タグがそのまま表示されます", start + ln_no)
                depth = 0
            depth += opens - closes
            if depth < 0:
                depth = 0

        # class の実在
        if known is not None:
            used = set()
            for m in re.finditer(r'class="([^"]*)"', nocomment):
                used.update(m.group(1).split())
            used.update(classes)
            unknown = sorted(c for c in used if c not in known)
            if unknown:
                add(ERR, "E03", idx, f"テーマに無い class: {', '.join(unknown)}")

        # 画像 alt
        for m in re.finditer(r"!\[([^\]]*)\]\(", nocomment):
            if not m.group(1).strip():
                add(INFO, "I02", idx, "画像に alt がありません（bg 指定でなければ内容を書きます）")

    n = len(slides)
    add(INFO, "I01", 0, f"{n} 枚。話す時間の目安 {n}〜{n*2} 分（1 枚 1〜2 分。LT は 30〜45 秒/枚）")
    return issues


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("md")
    ap.add_argument("--theme", default=None, help="テーマ名か CSS のパス。省略時は frontmatter の theme:（既定 tech-light）")
    ap.add_argument("--json", action="store_true")
    a = ap.parse_args()
    md = open(a.md, encoding="utf-8").read()
    theme = resolve_theme(md, a.theme)
    if not os.path.exists(theme):
        print(f"[ERROR] E05 deck  テーマが見つからない: {theme}（themes/ にあるのは " + ", ".join(sorted(f[:-4] for f in os.listdir(THEME_DIR) if f.endswith(".css"))) + "）")
        sys.exit(1)
    issues = lint(md, theme)
    if a.json:
        print(json.dumps(issues, ensure_ascii=False, indent=1))
    else:
        order = {ERR: 0, WARN: 1, INFO: 2}
        for it in sorted(issues, key=lambda x: (order[x["level"]], x["slide"])):
            where = f"p{it['slide']}" if it["slide"] else "deck"
            print(f"[{it['level']:5}] {it['code']} {where:5} {it['message']}")
        ne = sum(1 for i in issues if i["level"] == ERR)
        nw = sum(1 for i in issues if i["level"] == WARN)
        print(f"-- {ne} error(s), {nw} warning(s)")
    sys.exit(1 if any(i["level"] == ERR for i in issues) else 0)


if __name__ == "__main__":
    main()
