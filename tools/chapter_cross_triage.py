#!/usr/bin/env python3
"""Classify unregistered chapter pairs without turning citations into coverage.

--update exports a status matrix, a complete off-diagonal worklist and a guide.
--check checks reviewed witness fingerprints and the reproducible exports.
"""

import argparse
from collections import Counter, defaultdict
from itertools import combinations
import json
from pathlib import Path
import re
import sys

import chapter_cross_matrix as chapters
import suite_results

ROOT = chapters.ROOT
REGISTRY = "coverage/chapter-cross-triage.json"
OUTPUTS = ("coverage/chapter-cross-status.csv", "coverage/chapter-cross-triage.csv",
           "docs/chapter-cross-triage.md")
LABELS = {"M": "モデル登録済み", "E": "既存検証あり・章対未登録",
          "C": "追加検証候補", "N": "対象外", "R": "後回し・要精査"}


def cited_chapters(fields: dict) -> set[int]:
    lrm = fields.get("lrm", "").replace("1800-2023", "")
    return {int(n) for n in re.findall(r"(?<![\w.])(\d+)(?:\.\d+)*", lrm)} & set(chapters.CHAPTERS)


def discover(root: Path) -> dict[tuple[int, int], list[str]]:
    """Index positive simulation citations as leads, never verified interactions."""
    leads = defaultdict(list)
    for path in suite_results.find_tests(root):
        fields = suite_results.header(path)
        if fields.get("type") != "simulation" or fields.get("should_fail_because"):
            continue
        for pair in combinations(sorted(cited_chapters(fields)), 2):
            leads[pair].append(path.relative_to(root).as_posix())
    return leads


def validate_registry(data: dict, modeled: dict, root: Path) -> dict:
    if data.get("schema") != 1 or not data.get("reviewer") or not data.get("reviewed_on"):
        raise ValueError("triage registry needs schema 1 and review provenance")
    excluded = data["excluded_chapters"]
    if any(not str(c).isdigit() or int(c) not in chapters.CHAPTERS or not reason
           for c, reason in excluded.items()):
        raise ValueError("invalid exclusion policy")
    if any(str(c) in excluded for pair in modeled for c in pair):
        raise ValueError("exclusion policy conflicts with a registered model")
    entries = {}
    for entry in data["pairs"]:
        pair = entry["chapters"]
        if (len(pair) != 2 or any(c not in chapters.CHAPTERS for c in pair)
                or pair[0] >= pair[1]):
            raise ValueError("triage needs ordered, off-diagonal chapter pairs")
        pair = tuple(pair)
        if pair in entries:
            raise ValueError(f"duplicate triage pair: {pair}")
        if modeled.get(pair):
            raise ValueError(f"triaged zero pair now has a model; review and retire its entry: {pair}")
        if any(str(c) in excluded for c in pair):
            raise ValueError(f"triage conflicts with exclusion policy: {pair}")
        if (entry["category"] not in ("E", "C") or entry["priority"] not in ("P1", "P2", "P3")
                or any(not entry.get(k) for k in ("reason", "objective", "factors", "observation"))
                or not isinstance(entry["factors"], list)
                or any(not isinstance(f, str) or not f for f in entry["factors"])):
            raise ValueError(f"triage needs a reason and concrete verification design: {pair}")
        witnesses = entry["witnesses"]
        if (entry["category"] == "E") != bool(witnesses):
            raise ValueError(f"only E entries require reviewed existing witnesses: {pair}")
        seen = set()
        for witness in witnesses:
            path = root / witness["test"]
            if (not path.resolve().is_relative_to((root / "tests").resolve())
                    or path.suffix != ".sv" or witness["test"] in seen):
                raise ValueError(f"invalid or duplicate witness path: {path}")
            seen.add(witness["test"])
            fields = suite_results.header(path)
            if (fields.get("type") != "simulation" or fields.get("should_fail_because")
                    or not set(pair) <= cited_chapters(fields)):
                raise ValueError(f"witness must be a positive simulation citing both chapters: {path}")
            if suite_results.expected_output(path) is None:
                raise ValueError(f"witness has no expected observation: {path}")
            if suite_results.input_digest(path) != witness["inputs_sha256"]:
                raise ValueError(f"stale reviewed witness: {path}; review stimulus and expectation again")
        entries[pair] = entry
    return entries


def classify(modeled: dict, entries: dict, excluded: dict, leads: dict) -> list[dict]:
    """Return exactly one disposition per unordered pair; R explicitly stays unreviewed."""
    rows = []
    for a, b in combinations(chapters.CHAPTERS, 2):
        pair = (a, b)
        row = {"pair": pair, "models": modeled.get(pair, 0), "priority": "未評価",
               "reason": "章対だけでは検証目標を特定していない。個別の相互作用の精査を後回しにする。",
               "objective": "未精査", "factors": [], "observation": "未精査", "witnesses": [],
               "leads": leads.get(pair, [])}
        if row["models"]:
            row.update(category="M", priority="登録済み", reason="有限モデルの章対として登録済み。",
                       objective="登録モデルの刺激・観測を参照", observation="既存のクロス明細を参照")
        elif pair in entries:
            row.update(entries[pair])
        elif any(str(c) in excluded for c in pair):
            row.update(category="N", priority="対象外", reason=" / ".join(
                f"第{c}章: {excluded[str(c)]}" for c in pair if str(c) in excluded),
                objective="本計画の動作クロスの対象外", observation="該当なし")
        else:
            row["category"] = "R"
        rows.append(row)
    return rows


def status_matrix(rows: list[dict]) -> list[list]:
    codes = {r["pair"]: r["category"] + (r["priority"][1:] if r["category"] in ("E", "C") else "")
             for r in rows}
    return [["章番号", "章名", *chapters.CHAPTERS], *[
        [a, name, *["D" if a == b else codes[tuple(sorted((a, b)))] for b in chapters.CHAPTERS]]
        for a, name in chapters.CHAPTERS.items()]]


def guide(rows: list[dict], data: dict) -> str:
    counts = Counter(r["category"] for r in rows)
    existing = {w["test"] for r in rows for w in r["witnesses"]}
    lines = ["# 章間クロスの0セルの仕分け", "",
             "この資料は`tools/chapter_cross_triage.py`が生成します。",
             "[章間クロス検証マトリクス](chapter-cross-matrix.md)の非対角セルについて、",
             "モデルの登録がない理由と次の確認先を整理しています。", "",
             "- [仕分けマトリクスCSV](../coverage/chapter-cross-status.csv)：縦横41章。数字の代わりに下記の分類コードを表示します。",
             "- [全章対の作業一覧CSV](../coverage/chapter-cross-triage.csv)：各章対の根拠、優先度、因子候補、期待する観測、確認済みテストと探索候補。",
             "- [仕分け台帳](../coverage/chapter-cross-triage.json)：AIが刺激・観測と期待値を照合した記録、入力ハッシュ、追加設計の仮説。", "",
             "## 現在の内訳", "",
             f"上下対称の重複を除いた820章対のうち、モデル登録済みは{counts['M']}対、0セルは{820-counts['M']}対です。",
             f"0セルを、既存検証あり{counts['E']}対、追加検証候補{counts['C']}対、対象外{counts['N']}対、後回し・要精査{counts['R']}対に整理しました。",
             f"既存検証の根拠には、重複を除く{len(existing)}テストを登録しています。", "",
             "- `M`：有限モデルに章対を登録済み。登録数・合格数は元の数値マトリクスを参照。",
             "- `E1`／`E2`／`E3`：相互作用を検査する既存テストを確認済み。章対として有限モデル表に未登録。末尾はモデル化を検討する優先度。",
             "- `C1`／`C2`／`C3`：追加検証の設計案。共有状態や境界を特定した候補で、既存テストが存在しないとの断定ではありません。",
             "- `N`：現在の計画で動作クロスの対象外。章の性質または本スイートの対象範囲を理由に指定。",
             "- `R`：後回し・要精査。低リスクと確認したわけではなく、優先度も未評価。引用探索の候補から次回照合する余地があります。",
             "- `D`：対角線。本表の仕分け対象外です。元の表では主題章のモデル数を表示します。", "",
             "根拠のある対象外`N`と未精査の`R`を区別しています。",
             "未確認のセルを対象外や低リスクとみなして隠さないためです。", "",
             "## 次に検討する順番", "",
             "P1〜P3はこの検証計画内の優先度で、Issueの実装優先度とは独立です。",
             "P1はイベント領域や参照・格納先の境界など、複数機能の規則が同じ観測に効く項目、",
             "P2は他の型・階層・API境界、P3は基礎的な展開や拡張です。", ""]
    urgent = sorted((r for r in rows if r["priority"] == "P1"),
                    key=lambda r: (r.get("rank", 999), r["pair"]))
    for i, row in enumerate(urgent, 1):
        a, b = row["pair"]
        lines.extend([f"{i}. **第{a}章×第{b}章：{row['objective']}**（{row['category']}1）。",
                      f"   因子候補：{'、'.join(row['factors'])}。期待する観測：{row['observation']}"])
        if row["witnesses"]:
            path = row["witnesses"][0]["test"]
            lines.append(f"   再利用候補：[既存テスト](../{path})。")
    lines.extend(["", "## 判定の根拠と限界", "",
                  f"台帳の確認者は{data['reviewer']}、確認日は{data['reviewed_on']}です。",
                  "Eはソース中の刺激と観測、期待値を確認して登録します。入力ハッシュには期待値やC側の入力も含めます。",
                  "これは新しいシミュレータ実行の合格認定ではありません。今回テストや有限モデルは追加していません。",
                  "従来の登録モデル数、PASS表、要求カバレッジ、全テスト数は変えていません。", "",
                  "因子候補は次のモデル設計の案です。既存テストが挙げた全水準を検査済みという意味ではありません。", "",
                  "全正例シミュレーションの`:lrm:`を走査した同時引用件数と、最大3件の未レビュー探索候補も作業一覧に載せます。",
                  "同時引用は探索の手掛かりで、刺激・観測の照合をした件数ではありません。表示用の`$display`なども含み得ます。",
                  "同時引用0件でも、メタデータに第二の章が書かれていないテストが存在する可能性があります。",
                  "負例やformalはこの引用探索の対象外です。Eを章全体の網羅やt-way達成率には読み替えません。", "",
                  "Cはモデル化の仮説で、合法条件と規格の根拠、既存テストとの重複を照合してから実装します。",
                  "Eについても全件を因子モデル化する必要はなく、境界条件の回帰として維持する選択があります。", "",
                  "## 対象外の方針", ""])
    for chapter, reason in data["excluded_chapters"].items():
        lines.append(f"- 第{chapter}章：{reason}")
    lines.extend(["", "これは本計画の範囲指定で、規格として検証不要との判断ではありません。",
                  "対象範囲が変わるときは台帳の方針も再確認します。", "", "## 更新と検査", "",
                  "```sh", "python3 tools/chapter_cross_matrix.py --update",
                  "python3 tools/chapter_cross_triage.py --update",
                  "python3 tools/chapter_cross_triage.py --check",
                  "python3 -m unittest discover -s tools -p test_chapter_cross_triage.py", "```", "",
                  "Eへ昇格するには、両章の規則が同じ観測に効くことをソースと期待値で確認して、台帳に入力ハッシュを保存します。",
                  "既存の入力や期待値が変わった場合は検査が失敗します。照合せずにハッシュだけを更新しません。",
                  "Cには因子と水準の候補、観測したい違い、優先理由を残します。新しい有限モデルが章対をカバーしたときは、",
                  "該当するE/Cエントリを再確認して台帳から外します。履歴はgitに残ります。",
                  "Checkは仕分け台帳と生成物の整合性を確認します。シミュレータの実行・ビルドは行いません。", ""])
    return "\n".join(lines)


def build(root: Path = ROOT) -> tuple[dict[str, bytes], dict]:
    summary = json.loads((root / chapters.SUMMARY).read_text(encoding="utf-8"))
    if summary["source_sha256"] != chapters.interaction_coverage.source_digest():
        raise ValueError("interaction summary is stale; refresh the interaction reports first")
    mapping = json.loads((root / chapters.REGISTRY).read_text(encoding="utf-8"))
    model_rows = chapters.reviewed_pairs(summary, mapping)
    if (root / chapters.OUTPUTS[0]).read_bytes() != chapters.csv_bytes(chapters.matrix(model_rows)):
        raise ValueError("chapter model matrix is stale; run chapter_cross_matrix.py --update first")
    modeled = Counter(r["chapters"] for r in model_rows if r["chapters"][0] != r["chapters"][1])
    data = json.loads((root / REGISTRY).read_text(encoding="utf-8"))
    entries = validate_registry(data, modeled, root)
    rows = classify(modeled, entries, data["excluded_chapters"], discover(root))
    details = [["章A", "章A名", "章B", "章B名", "分類コード", "分類", "優先度", "登録モデル数",
                "判断理由", "検証目標", "因子候補", "期待する観測", "確認済みテスト数", "確認済みテスト",
                "同時引用件数（探索用）", "未レビュー探索候補（最大3件）", "次の作業",
                "レビュー日", "レビュー者"]]
    actions = {"M": "既存モデルの計画・実行証跡を維持する", "E": "既存テストを再利用し、因子モデル化の要否と不足条件を確認する",
               "C": "規格・既存テストを照合して因子と観測を設計する", "N": "対象範囲が変わるときに方針を再確認する",
               "R": "引用探索の候補とソースを確認して、E/C/Nへの分類を検討する"}
    for row in rows:
        a, b = row["pair"]
        category = row["category"]
        witnesses = [w["test"] for w in row["witnesses"]]
        candidates = [p for p in row["leads"] if p not in witnesses][:3]
        reviewed = category in ("E", "C", "N")
        details.append([a, chapters.CHAPTERS[a], b, chapters.CHAPTERS[b],
                        category + (row["priority"][1:] if category in ("E", "C") else ""),
                        LABELS[category], row["priority"], row["models"], row["reason"], row["objective"],
                        " / ".join(row["factors"]), row["observation"], len(witnesses), "\n".join(witnesses),
                        len(row["leads"]), "\n".join(candidates), actions[category],
                        data["reviewed_on"] if reviewed else "", data["reviewer"] if reviewed else ""])
    outputs = dict(zip(OUTPUTS, (chapters.csv_bytes(status_matrix(rows)), chapters.csv_bytes(details),
                                 guide(rows, data).encode("utf-8"))))
    stats = {"chapter_pairs": len(rows), "categories": dict(Counter(r["category"] for r in rows)),
             "reviewed_tests": len({w["test"] for r in rows for w in r["witnesses"]}),
             "p1_pairs": sum(r["priority"] == "P1" for r in rows)}
    return outputs, stats


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--update", action="store_true")
    mode.add_argument("--check", action="store_true")
    args = parser.parse_args()
    try:
        outputs, stats = build()
        stale = []
        for name, content in outputs.items():
            path = ROOT / name
            if args.update:
                path.write_bytes(content)
            elif args.check and (not path.is_file() or path.read_bytes() != content):
                stale.append(name)
        print(json.dumps(stats, ensure_ascii=False))
        if stale:
            raise ValueError("stale triage exports: " + ", ".join(stale)
                             + "; run python3 tools/chapter_cross_triage.py --update")
    except (ValueError, KeyError, OSError) as error:
        print(f"chapter triage: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
