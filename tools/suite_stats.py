#!/usr/bin/env python3
"""Counts the tests of the suite by chapter and by where their expected
output comes from, and keeps the tables in both README languages up to date.

Usage:
    python3 tools/suite_stats.py            print the tables as Markdown
    python3 tools/suite_stats.py --update   rewrite both README language versions
    python3 tools/suite_stats.py --check    exit with 1 if either README is out of date

The tables in README.md and README.ja.md are the lines between the markers
"<!-- suite-stats:begin -->" and "<!-- suite-stats:end -->".
"""

import argparse
import re
import sys
from pathlib import Path

import suite_results

ROOT = Path(__file__).resolve().parent.parent
README = ROOT / "README.md"
READMES = ((README, "en"), (ROOT / "README.ja.md", "ja"))
BEGIN = "<!-- suite-stats:begin -->"
END = "<!-- suite-stats:end -->"

# The clauses of IEEE 1800-2023 that tests can belong to. Clauses 1 and 2
# (overview, normative references) set out no behavior to test.
CHAPTERS = {
    3: "Design and verification building blocks",
    4: "Scheduling semantics",
    5: "Lexical conventions",
    6: "Data types",
    7: "Aggregate data types",
    8: "Classes",
    9: "Processes",
    10: "Assignment statements",
    11: "Operators and expressions",
    12: "Procedural programming statements",
    13: "Tasks and functions (subroutines)",
    14: "Clocking blocks",
    15: "Interprocess synchronization and communication",
    16: "Assertions",
    17: "Checkers",
    18: "Constrained random value generation",
    19: "Functional coverage",
    20: "Utility system tasks and system functions",
    21: "Input/output system tasks and system functions",
    22: "Compiler directives",
    23: "Modules and hierarchy",
    24: "Programs",
    25: "Interfaces",
    26: "Packages",
    27: "Generate constructs",
    28: "Gate-level and switch-level modeling",
    29: "User-defined primitives",
    30: "Specify blocks",
    31: "Timing checks",
    32: "Backannotation using the standard delay format",
    33: "Configuring the contents of a design",
    34: "Protected envelopes",
    35: "Direct programming interface",
    36: "Programming language interface (PLI/VPI) overview",
    37: "VPI object model diagrams",
    38: "VPI routine definitions",
    39: "Assertion API",
    40: "Code coverage control and API",
}

CHAPTERS_JA = {
    3: "設計と検証の構成要素", 4: "スケジューリングの意味論", 5: "字句規則",
    6: "データ型", 7: "集合データ型", 8: "クラス", 9: "プロセス",
    10: "代入文", 11: "演算子と式", 12: "手続き型プログラミング文",
    13: "タスクと関数（サブルーチン）", 14: "クロッキングブロック",
    15: "プロセス間の同期と通信", 16: "アサーション", 17: "チェッカー",
    18: "制約付き乱数値の生成", 19: "機能カバレッジ",
    20: "ユーティリティ用システムタスク・関数", 21: "入出力用システムタスク・関数",
    22: "コンパイラ指令", 23: "モジュールと階層", 24: "プログラム",
    25: "インターフェース", 26: "パッケージ", 27: "generate構文",
    28: "ゲートレベル・スイッチレベルのモデリング", 29: "ユーザー定義プリミティブ",
    30: "specifyブロック", 31: "タイミング検査", 32: "標準遅延形式によるバックアノテーション",
    33: "設計内容の構成指定", 34: "保護エンベロープ", 35: "直接プログラミングインターフェース（DPI）",
    36: "プログラミング言語インターフェース（PLI/VPI）の概要", 37: "VPIオブジェクトモデル図",
    38: "VPIルーチンの定義", 39: "アサーションAPI", 40: "コードカバレッジの制御とAPI",
}


def header(test: Path) -> dict[str, str]:
    m = re.search(r"/\*(.*?)\*/", test.read_text(encoding="utf-8"), re.DOTALL)
    if not m:
        return {}
    return {k: v.strip() for k, v in re.findall(r"^:(\w+):\s*(.*)$", m.group(1), re.MULTILINE)}


def oracle_kind(fields: dict[str, str]) -> str:
    """icarus, verilator or spec: the simulator the expected output was
    recorded with, Icarus Verilog first, or spec when neither produces it."""
    oracles = fields.get("oracle", "").split()
    if "iverilog@13.0" in oracles:
        return "icarus"
    if "verilator@5.052" in oracles:
        return "verilator"
    return "spec"


def collect(root: Path = ROOT) -> dict:
    by_chapter: dict[int, dict[str, int]] = {}
    totals = {"tests": 0, "icarus": 0, "verilator": 0, "spec": 0, "human": 0,
              "fourstate": 0, "dpi_c": 0, "vpi_c": 0, "illegal": 0, "exit": 0, "files": 0,
              "args": 0, "defines": 0, "incdirs": 0, "top_module": 0, "generated": {}}
    for test in suite_results.find_tests(root):
        fields = header(test)
        chapter = int(test.parent.name.removeprefix("ch"))
        row = by_chapter.setdefault(chapter, {"tests": 0, "icarus": 0, "verilator": 0, "spec": 0})
        kind = oracle_kind(fields)
        row["tests"] += 1
        row[kind] += 1
        totals["tests"] += 1
        totals[kind] += 1
        totals["human"] += fields.get("spec_check") == "human"
        totals["fourstate"] += fields.get("fourstate") == "yes"
        totals["dpi_c"] += "dpi_c" in fields
        totals["vpi_c"] += "vpi_c" in fields
        totals["illegal"] += "should_fail_because" in fields
        totals["exit"] += "expected_exit" in fields
        totals["files"] += "files" in fields
        totals["args"] += "args" in fields
        totals["defines"] += "defines" in fields
        totals["incdirs"] += "incdirs" in fields
        totals["top_module"] += "top_module" in fields
        if "generator" in fields:
            g = fields["generator"].split("@")[0]
            totals["generated"][g] = totals["generated"].get(g, 0) + 1
    return {"totals": totals, "chapters": by_chapter}


def run_setup(t: dict) -> str:
    """The sentence that counts the tests whose metadata sets up the run, such
    as "6 tests have more than one source file (`:files:`), and 5 pass
    arguments to the simulation (`:args:`). ", or "" if there are none."""
    parts = [f"{n} {one if n == 1 else more}" for n, one, more in (
        (t["files"], "has more than one source file", "have more than one source file"),
        (t["defines"], "defines macros", "define macros"),
        (t["incdirs"], "names include directories", "name include directories"),
        (t["top_module"], "names the top-level module or configuration",
         "name the top-level module or configuration"),
        (t["args"], "passes arguments to the simulation", "pass arguments to the simulation"))
        if n]
    fields = [f for n, f in ((t["files"], "files"), (t["defines"], "defines"),
                             (t["incdirs"], "incdirs"), (t["top_module"], "top_module"),
                             (t["args"], "args")) if n]
    parts = [f"{p} (`:{f}:`)" for p, f in zip(parts, fields)]
    if not parts:
        return ""
    number, rest = parts[0].split(" ", 1)
    parts[0] = f"{number} {'test' if number == '1' else 'tests'} {rest}"
    if len(parts) > 1:
        parts[-1] = "and " + parts[-1]
    return ", ".join(parts) + ". "


def markdown(stats: dict, language: str = "en") -> str:
    if language == "ja":
        return markdown_ja(stats)
    if language != "en":
        raise ValueError(f"unsupported README language: {language}")
    t = stats["totals"]
    lines = [
        f"The suite has **{t['tests']} tests** in {len(stats['chapters'])} chapters."
        + (f" {sum(t['generated'].values())} of them are generated (`tests/gen/`, see "
           "\"Generated tests\"): "
           + ", ".join(f"{n} by `{g}`" for g, n in sorted(t["generated"].items())) + "."
           if t["generated"] else ""),
        "",
        "| Expected result recorded with | Tests |",
        "| --- | ---: |",
        f"| Icarus Verilog 13.0 (`iverilog@13.0` in `:oracle:`) | {t['icarus']} |",
        f"| Verilator 5.052, with no Icarus Verilog 13.0 oracle recorded | {t['verilator']} |",
        f"| The standard only, with no fixed-release simulator oracle recorded | {t['spec']} |",
        "",
        f"{t['fourstate']} tests depend on x or z values (`:fourstate: yes`). "
        f"{t['dpi_c'] + t['vpi_c']} tests come with C code: {t['dpi_c']} DPI tests (`:dpi_c:`) "
        f"and {t['vpi_c']} VPI tests (`:vpi_c:`). "
        + (f"{t['illegal']} tests are illegal designs, which a simulator has to reject "
           "(`:should_fail_because:`). " if t["illegal"] else "")
        + (f"{t['exit']} tests check the exit code of the simulation (`:expected_exit:`). "
           if t["exit"] else "")
        + run_setup(t)
        + (f"{t['human']} tests have been checked against the standard by a person "
           "(`:spec_check: human`); the others were checked by an AI model."
           if t["human"] else
           "Every test has been checked against the standard by an AI model "
           "(`:spec_check: ai`); none has been checked by a person yet."),
        "",
        "| Clause | Title | Tests | Icarus | Verilator | Standard only |",
        "| ---: | --- | ---: | ---: | ---: | ---: |",
    ]
    for chapter, title in CHAPTERS.items():
        row = stats["chapters"].get(chapter)
        if row is None:
            lines.append(f"| {chapter} | {title} | — | | | |")
            continue
        lines.append(f"| {chapter} | {title} | {row['tests']} | {row['icarus'] or ''} | "
                     f"{row['verilator'] or ''} | {row['spec'] or ''} |")
    return "\n".join(lines) + "\n"


def markdown_ja(stats: dict) -> str:
    t = stats["totals"]
    setup = "、".join(f"{label}{t[field]}本（`:{field}:`）" for field, label in (
        ("files", "複数ソースファイル"), ("defines", "マクロ定義"),
        ("incdirs", "インクルードディレクトリ指定"),
        ("top_module", "トップレベルのモジュールまたは構成指定"),
        ("args", "実行時引数")) if t[field])
    lines = [
        f"スイートには{len(stats['chapters'])}章にわたり**{t['tests']}本のテスト**があります。",
    ]
    if t["generated"]:
        lines[0] += (f" うち{sum(t['generated'].values())}本は自動生成です"
                     "（`tests/gen/`。「自動生成テスト」を参照）："
                     + "、".join(f"`{g}`が{n}本" for g, n in sorted(t["generated"].items())) + "。")
    lines += ["", "| 期待結果の確認元 | テスト数 |", "| --- | ---: |",
              f"| Icarus Verilog 13.0（`:oracle:`に`iverilog@13.0`） | {t['icarus']} |",
              f"| Verilator 5.052（Icarus Verilog 13.0のoracle登録なし） | {t['verilator']} |",
              f"| 規格のみ（固定リリースのシミュレータのoracle登録なし） | {t['spec']} |", "",
              f"{t['fourstate']}本はx/z値に依存します（`:fourstate: yes`）。"
              f"{t['dpi_c'] + t['vpi_c']}本にはCコードがあり、内訳はDPIが{t['dpi_c']}本（`:dpi_c:`）、"
              f"VPIが{t['vpi_c']}本（`:vpi_c:`）です。"
              + (f"{t['illegal']}本はシミュレータが拒否すべき不正な設計です（`:should_fail_because:`）。"
                 if t["illegal"] else "")
              + (f"{t['exit']}本はシミュレーションの終了コードを確認します（`:expected_exit:`）。"
                 if t["exit"] else "")
              + (f"実行条件の指定は、{setup}です。" if setup else "")
              + (f"{t['human']}本は人が規格と照合済みです（`:spec_check: human`）。残りはAIモデルが照合しました。"
                 if t["human"] else
                 "すべてのテストをAIモデルが規格と照合しました（`:spec_check: ai`）。人による照合はまだありません。"),
              "", "| 章 | 題名 | テスト数 | Icarus | Verilator | 規格のみ |",
              "| ---: | --- | ---: | ---: | ---: | ---: |"]
    for chapter in CHAPTERS:
        title = CHAPTERS_JA[chapter]
        row = stats["chapters"].get(chapter)
        if row is None:
            lines.append(f"| {chapter} | {title} | — | | | |")
        else:
            lines.append(f"| {chapter} | {title} | {row['tests']} | {row['icarus'] or ''} | "
                         f"{row['verilator'] or ''} | {row['spec'] or ''} |")
    return "\n".join(lines) + "\n"


def replace_section(text: str, section: str) -> str:
    start, end = text.index(BEGIN) + len(BEGIN), text.index(END)
    return text[:start] + "\n" + section + text[end:]


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    group = ap.add_mutually_exclusive_group()
    group.add_argument("--update", action="store_true", help="rewrite the tables in both READMEs")
    group.add_argument("--check", action="store_true",
                       help="exit with 1 if either README's tables are out of date")
    args = ap.parse_args()

    stats = collect()
    if not (args.update or args.check):
        sys.stdout.write(markdown(stats))
        return 0
    stale = False
    for path, language in READMES:
        text = path.read_text(encoding="utf-8")
        new = replace_section(text, markdown(stats, language))
        if args.check:
            if new != text:
                print(f"{path.name} is out of date: run python3 tools/suite_stats.py --update")
                stale = True
        else:
            path.write_text(new, encoding="utf-8")
    return int(stale)


if __name__ == "__main__":
    sys.exit(main())
