#!/usr/bin/env python3
"""Reports, for each test that docs/simulator-differences.md names, its result
in the latest nightly run of the same simulator's development version.

Usage:
    python3 tools/differences_status.py --icarus FILE --verilator FILE \\
        --output DIR [--source-url URL]

The list records where the releases Icarus Verilog 13.0 and Verilator 5.052
differ from the standard. Each FILE is latest/<simulator>.json of the results
branch, which the nightly workflow writes from a run of the simulator's latest
master, or a runner's --json file (see tools/suite_results.py); a FILE that
does not exist leaves that simulator out. The report, DIR/differences-on-master.md
in English and DIR/differences-on-master.ja.md in Japanese, gives the version
and the time of each run and, for each test that the list names for that
simulator, whether the run matches the expected output now, still differs, or
did not run the test. It changes nothing in the list: whether an item is fixed
upstream is for a person to check.

A test counts for a simulator when the nearest heading above it that names a
simulator names only that one, or "both releases"; else when its line names
only one of them, by name or by the number of the release (13.0, 5.052, but
not iverilog@13.0); else when the test's :oracle: leaves out that
simulator's release. After a full name, a short form such as `_08` stands for the name with
as many of its last parts replaced. A name with * or {a,b} is a pattern,
reported as a group with the number of matching tests in each state; the text
of the item may narrow the group. The report also lists names that are not
tests, and tests named for a release that their :oracle: lists, whose item may
be out of date.
"""

import argparse
import fnmatch
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LIST = "docs/simulator-differences.md"
LIST_JA = "docs/simulator-differences.ja.md"
REPORT = "differences-on-master.md"
REPORT_JA = "differences-on-master.ja.md"
SOURCE_URL = "https://github.com/kurochan001/kirimasim-tests/blob/main"
# The simulators of the list: the words that name each in a heading or a line
# (the list also writes "the 5.052 release"), its name in the report, and the
# release that :oracle: names when the expected output is that release's.
SIMULATORS = {
    "icarus": (("Icarus", "13.0"), "Icarus Verilog", "iverilog@13.0"),
    "verilator": (("Verilator", "5.052"), "Verilator", "verilator@5.052"),
}
TOKEN = re.compile(r"\[[^\]\n]*\]\(([^)\s]+)\)|`([^`\n]+)`")
NAME = re.compile(r"(?<![\w/])((?:gen/|imported/)?ch\d+/test_[A-Za-z0-9_*{},]+)")
SHORT = re.compile(r"_[A-Za-z0-9_]+")
HEADING = re.compile(r"^(#{2,6}) +(.*?) *$")


def slugs(headings: list[str]) -> list[str]:
    """The anchors that GitHub gives the headings of a page, in order."""
    seen: dict[str, int] = {}
    anchors = []
    for text in headings:
        base = re.sub(r"[^\w\- ]", "", text.replace("`", "").lower()).replace(" ", "-")
        count = seen.get(base, 0)
        seen[base] = count + 1
        anchors.append(base if count == 0 else f"{base}-{count}")
    return anchors


def named(text: str) -> set[str]:
    """The simulators that a heading or a line names alone, or both."""
    found = {key for key, (words, _, _) in SIMULATORS.items()
             if any(re.search(rf"(?<![\w.@]){re.escape(w)}(?![\w.])", text) for w in words)}
    if not found and "both releases" in text.lower():
        return set(SIMULATORS)
    return found


def expand(pattern: str) -> list[str]:
    """The glob patterns of a name with {a,b} alternatives."""
    m = re.search(r"\{([^{}]*)\}", pattern)
    if not m:
        return [pattern]
    return [p for alt in m.group(1).split(",")
            for p in expand(pattern[:m.start()] + alt + pattern[m.end():])]


def references(line: str) -> list[str]:
    """The test names of a line, short forms written out."""
    names, last = [], None
    for target, code in TOKEN.findall(line):
        text = (target or code).strip()
        m = NAME.search(text.replace("../tests/", "").replace("tests/", ""))
        if m:
            last = m.group(1).removesuffix(".sv")
            names.append(last)
        elif last and SHORT.fullmatch(text):
            parts = last.split("_")
            names.append("_".join(parts[:-text.count("_")]) + text)
    return names


def oracle(root: Path, test: str) -> list[str] | None:
    """The releases that :oracle: of a test names, or None for no such test."""
    path = root / "tests" / f"{test}.sv"
    if not path.is_file():
        return None
    m = re.search(r"^:oracle:(.*)$", path.read_text(encoding="utf-8", errors="replace"), re.MULTILINE)
    return m.group(1).split() if m else []


def read_list(text: str) -> tuple[list[tuple[str, str]], list[tuple[int, str, set[str] | None]]]:
    """The headings of the list, each as its text and its label (the text after
    those of the headings above it, but the page's title), and each name with
    the index of its heading and the simulators that its heading or line names
    (None: neither)."""
    headings: list[tuple[str, str]] = []
    stack: list[tuple[int, set[str], str]] = []
    entries = []
    fenced = False
    for line in text.splitlines():
        if line.startswith("```"):
            fenced = not fenced
            continue
        m = None if fenced else HEADING.match(line)
        if m:
            level = len(m.group(1))
            stack = [s for s in stack if s[0] < level] + [(level, named(m.group(2)), m.group(2))]
            headings.append((m.group(2), " › ".join(s[2] for s in stack)))
            continue
        if fenced or not headings:
            continue
        by_heading = next((s for _, s, _ in reversed(stack) if s), set())
        by_line = named(line)
        simulators = by_heading or (by_line if len(by_line) == 1 else set()) or None
        for name in references(line):
            entries.append((len(headings) - 1, name, simulators))
    return headings, entries


def classify(root: Path, entries, results: dict[str, dict[str, str]]) -> dict:
    """For each simulator: the named tests by state, the patterns, the names
    that are not tests, and the tests whose :oracle: lists the release."""
    tests = sorted(p.relative_to(root / "tests").with_suffix("").as_posix()
                   for p in (root / "tests").rglob("test_*.sv"))
    out = {key: {"match": {}, "differ": {}, "missing": {}, "patterns": {}, "oracle": {}}
           for key in results}
    not_tests: dict[str, int] = {}
    for heading, name, simulators in entries:
        if any(c in name for c in "*{"):
            members = sorted({t for p in expand(name) for t in tests if fnmatch.fnmatchcase(t, p)})
            if not members:
                not_tests.setdefault(name, heading)
            for key in results:
                release = SIMULATORS[key][2]
                if simulators is None:
                    chosen = [t for t in members if release not in (oracle(root, t) or [])]
                else:
                    chosen = members if key in simulators else []
                if chosen and name not in out[key]["patterns"]:
                    out[key]["patterns"][name] = (heading, chosen)
            continue
        listed = oracle(root, name)
        if listed is None:
            not_tests.setdefault(name, heading)
            continue
        for key, statuses in results.items():
            release = SIMULATORS[key][2]
            if simulators is None:
                if release in listed:
                    continue
            elif key not in simulators:
                continue
            if release in listed:
                state = "oracle"
            elif name not in statuses:
                state = "missing"
            else:
                state = "match" if statuses[name] == "pass" else "differ"
            if not any(name in out[key][s] for s in ("match", "differ", "missing", "oracle")):
                out[key][state][name] = heading
    return {"simulators": out, "not_tests": not_tests}


def load(path: Path | None) -> tuple[dict, dict[str, str]] | None:
    if path is None or not path.is_file():
        return None
    data = json.loads(path.read_text(encoding="utf-8"))
    statuses = {t: r if isinstance(r, str) else r["status"] for t, r in data["tests"].items()}
    return data, statuses


def render(language: str, found: dict, runs: dict, headings: list[tuple[str, str]],
           headings_ja: list[tuple[str, str]],
           source_url: str) -> str:
    tr = (lambda en, ja: ja) if language == "ja" else (lambda en, ja: en)
    source_url = source_url.rstrip("/")
    repository = source_url.split("/blob/")[0]
    page = LIST_JA if language == "ja" else LIST
    titles = headings_ja if language == "ja" and len(headings_ja) == len(headings) else headings
    anchors = slugs([text for text, _ in titles])
    item = lambda h: f"[{titles[h][1].replace('`', '').replace('|', '/')}]({source_url}/{page}#{anchors[h]})"
    test = lambda t: f"[`{t}`]({source_url}/tests/{t}.sv)"
    lines = [
        tr("# Listed differences on the latest master", "# 差異一覧のテストの最新 master での結果"),
        "",
        "[English](differences-on-master.md) / [日本語](differences-on-master.ja.md)",
        "",
        tr(f"The [list of differences]({source_url}/{LIST}) records where the releases Icarus Verilog 13.0 "
           "and Verilator 5.052 differ from the standard, with the tests that show it. This page gives, for each "
           "test it names, the result of the latest nightly run of the same simulator, which the nightly workflow "
           "builds from its latest `master`. A test that matches there may have been fixed upstream: a person "
           "checks that before the item in the list changes. `tools/differences_status.py` writes this page and "
           "changes nothing in the list.",
           f"[差異一覧]({source_url}/{LIST_JA})は、Icarus Verilog 13.0 と Verilator 5.052 のリリースが規格と異なる箇所を、"
           "それを示すテストとともに記録しています。このページは、一覧が挙げる各テストについて、同じシミュレータの最新の"
           "夜間実行の結果を示します。夜間ワークフローは各シミュレータの最新の `master` をビルドして実行します。"
           "ここで一致したテストは上流で直った可能性がありますが、一覧の項目を変えるのは人が確かめてからです。"
           "このページは `tools/differences_status.py` が書き、一覧そのものは変えません。"),
        "",
        "| " + tr("Simulator | Version of the run | Run (UTC) | Suite | Named tests | Still differ | Now match | Not run",
                   "シミュレータ | 実行した版 | 実行（UTC） | スイート | 挙げられたテスト | まだ異なる | 一致した | 未実行") + " |",
        "| --- | --- | --- | --- | ---: | ---: | ---: | ---: |",
    ]
    for key, (_, name, _) in SIMULATORS.items():
        run = runs.get(key)
        if run is None:
            lines.append(f"| {name} | {tr('no results', '結果なし')} | | | | | | |")
            continue
        sim = found["simulators"][key]
        when = run["time"].replace("T", " ")[:16]
        suite = run.get("suite_commit", "")
        suite_link = f"[`{suite[:7]}`]({repository}/commit/{suite})" if suite else ""
        counts = [len(sim[s]) for s in ("match", "differ", "missing")]
        lines.append(f"| {name} | {run.get('version', '')} | {when} | {suite_link} | {sum(counts)} | "
                     f"{counts[1]} | {counts[0]} | {counts[2]} |")
    lines += ["", tr("Named tests counts each test once per simulator. Patterns and the items under "
                     "\"To check in the list\" are not in these counts.",
                     "挙げられたテストは、シミュレータごとに各テストを1回数えます。パターンと「一覧で確かめること」の項目は、"
                     "この数に含みません。")]
    for key, (_, name, _) in SIMULATORS.items():
        if key not in runs:
            continue
        sim = found["simulators"][key]
        lines += ["", f"## {name}", "",
                  f"### {tr('Now match', '一致した')} ({len(sim['match'])})", ""]
        if sim["match"]:
            lines += ["| " + tr("Test | Item of the list", "テスト | 一覧の項目") + " |", "| --- | --- |"]
            lines += [f"| {test(t)} | {item(h)} |" for t, h in sorted(sim["match"].items())]
        else:
            lines.append(tr("None.", "ありません。"))
        if sim["missing"]:
            lines += ["", f"### {tr('Not run', '未実行')} ({len(sim['missing'])})", "",
                      "| " + tr("Test | Item of the list", "テスト | 一覧の項目") + " |", "| --- | --- |"]
            lines += [f"| {test(t)} | {item(h)} |" for t, h in sorted(sim["missing"].items())]
        if sim["patterns"]:
            statuses = runs[key]["statuses"]
            lines += ["", f"### {tr('Patterns', 'パターン')} ({len(sim['patterns'])})", "",
                      tr("The tests whose names match the pattern; the item may narrow them.",
                         "名前がパターンに合うテストです。項目の文がさらに絞ることがあります。"), "",
                      "| " + tr("Pattern | Item of the list | Tests | Match | Differ | Not run",
                                 "パターン | 一覧の項目 | テスト | 一致 | 異なる | 未実行") + " |",
                      "| --- | --- | ---: | ---: | ---: | ---: |"]
            for pattern, (h, members) in sorted(sim["patterns"].items()):
                match = sum(statuses.get(t) == "pass" for t in members)
                missing = sum(t not in statuses for t in members)
                lines.append(f"| `{pattern}` | {item(h)} | {len(members)} | {match} | "
                             f"{len(members) - match - missing} | {missing} |")
        lines += ["", f"### {tr('Still differ', 'まだ異なる')} ({len(sim['differ'])})", ""]
        if sim["differ"]:
            lines += ["<details>", f"<summary>{tr('The tests', 'テストの一覧')}</summary>", "",
                      "| " + tr("Test | Item of the list", "テスト | 一覧の項目") + " |", "| --- | --- |"]
            lines += [f"| {test(t)} | {item(h)} |" for t, h in sorted(sim["differ"].items())]
            lines += ["", "</details>"]
        else:
            lines.append(tr("None.", "ありません。"))
    lines += ["", tr("## To check in the list", "## 一覧で確かめること"), "",
              f"### {tr('Names that are not tests', 'テストでない名前')} ({len(found['not_tests'])})", ""]
    if found["not_tests"]:
        lines += ["| " + tr("Name | Item of the list", "名前 | 一覧の項目") + " |", "| --- | --- |"]
        lines += [f"| `{n}` | {item(h)} |" for n, h in sorted(found["not_tests"].items())]
    else:
        lines.append(tr("None.", "ありません。"))
    oracle_rows = [(t, key, h) for key in runs for t, h in found["simulators"][key]["oracle"].items()]
    lines += ["", f"### {tr('Named for a release that the test’s :oracle: lists', 'テストの :oracle: が挙げる版について挙げたもの')}"
              f" ({len(oracle_rows)})", "",
              tr("The expected output of such a test is that release's, so the test does not show the "
                 "difference on that release: the item may be out of date, or the test may work around it.",
                 "このテストの期待出力はその版のものなので、テストはその版での差を示しません。"
                 "項目が古いか、テストが差を避けている可能性があります。"), ""]
    if oracle_rows:
        lines += ["| " + tr("Test | Simulator | Result of the run | Item of the list",
                            "テスト | シミュレータ | 実行の結果 | 一覧の項目") + " |", "| --- | --- | --- | --- |"]
        for t, key, h in sorted(oracle_rows):
            status = runs[key]["statuses"].get(t)
            result = (tr("match", "一致") if status == "pass" else tr("not run", "未実行") if status is None
                      else tr("differ", "異なる"))
            lines.append(f"| {test(t)} | {SIMULATORS[key][1]} | {result} | {item(h)} |")
    else:
        lines.append(tr("None.", "ありません。"))
    return "\n".join(lines) + "\n"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--icarus", type=Path, help="latest results of Icarus Verilog")
    ap.add_argument("--verilator", type=Path, help="latest results of Verilator")
    ap.add_argument("--output", type=Path, required=True, help="directory of the report")
    ap.add_argument("--source-url", default=SOURCE_URL, help="repository blob URL for the links")
    ap.add_argument("--root", type=Path, default=ROOT, help=argparse.SUPPRESS)
    args = ap.parse_args()

    runs = {}
    for key in SIMULATORS:
        loaded = load(getattr(args, key))
        if loaded:
            data, statuses = loaded
            runs[key] = {**{k: v for k, v in data.items() if k != "tests"}, "statuses": statuses}
    if not runs:
        print("differences_status: no results to report", file=sys.stderr)
        return 1
    headings, entries = read_list((args.root / LIST).read_text(encoding="utf-8"))
    headings_ja, _ = read_list((args.root / LIST_JA).read_text(encoding="utf-8"))
    found = classify(args.root, entries, {k: r["statuses"] for k, r in runs.items()})
    args.output.mkdir(parents=True, exist_ok=True)
    for language, report in (("en", REPORT), ("ja", REPORT_JA)):
        (args.output / report).write_text(
            render(language, found, runs, headings, headings_ja, args.source_url), encoding="utf-8")
    for key, run in runs.items():
        sim = found["simulators"][key]
        print(f"{SIMULATORS[key][1]} ({run.get('version', '')}): {len(sim['match'])} now match, "
              f"{len(sim['differ'])} still differ, {len(sim['missing'])} not run, "
              f"{len(sim['patterns'])} patterns, {len(sim['oracle'])} named for a release that :oracle: lists")
    print(f"{len(found['not_tests'])} names that are not tests")
    return 0


if __name__ == "__main__":
    sys.exit(main())
