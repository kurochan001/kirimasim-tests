#!/usr/bin/env python3
"""Lists the tests and clauses whose expected results rest least on anything
but the reading of the standard, for a person to check against the standard.

Usage:
    python3 tools/review_candidates.py --results DIR --output DIR [--source-url URL]

DIR of --results holds latest/<simulator>.json of the results branch, which
the nightly workflow writes; only icarus, verilator, kirimasim, lyra and ghost
are read, and a file that does not exist leaves that simulator out. The
report, DIR/review-candidates.md in English, DIR/review-candidates.ja.md in
Japanese and DIR/review-candidates.json, gives the version, the time and the
suite commit of each result, and these candidates:

  spec_fail_all     a test whose :oracle: names neither iverilog@13.0 nor
                    verilator@5.052 (spec only), that passes on no simulator
                    and fails, not merely unsupported, on Ghost, kirimasim
                    and Lyra
  kirimasim_only    a spec-only test that passes on kirimasim alone, where
                    the test and kirimasim may share a misreading
  spec_no_pass      any other spec-only test that passes on no simulator
  oracle_ghost_lyra a test whose :oracle: names one of those releases and
                    that fails on both Ghost and Lyra, where the expectation
                    may follow Icarus Verilog or Verilator rather than the
                    standard
  spec_only_clauses a clause of chapters 3 to 40 in scope and without
                    subclauses (tools/clauses.txt) whose citing tests in :lrm:
                    are all spec only

Formal tests are left out. The order of the sections is the order for review.
A candidate is not a finding: the review against the standard decides, and
docs/review-candidates.md says how the reviews are recorded. The report
changes nothing in the tests.
"""

import argparse
import collections
import json
import sys
from pathlib import Path

import suite_catalog
import suite_results

ROOT = Path(__file__).resolve().parent.parent
SOURCE_URL = "https://github.com/kurochan001/kirimasim-tests/blob/main"
SIMULATORS = ("icarus", "verilator", "kirimasim", "lyra", "ghost")
NAMES = {"icarus": "Icarus Verilog", "verilator": "Verilator", "kirimasim": "kirimasim",
         "lyra": "Lyra", "ghost": "Ghost"}
RELEASES = {"iverilog@13.0", "verilator@5.052"}
CATEGORIES = ("spec_fail_all", "kirimasim_only", "spec_no_pass", "oracle_ghost_lyra")


def load(directory: Path) -> dict[str, dict]:
    runs = {}
    for sim in SIMULATORS:
        path = directory / f"{sim}.json"
        if path.is_file():
            data = json.loads(path.read_text(encoding="utf-8"))
            tests = {t: (r["status"] if isinstance(r, dict) else r)
                     for t, r in data.get("tests", {}).items()}
            runs[sim] = {"version": data.get("version", ""), "time": data.get("time")
                         or data.get("generated_at", ""), "suite_commit": data.get("suite_commit", ""),
                         "tests": tests}
    return runs


def tests_of(root: Path) -> list[dict]:
    entries = []
    for test in suite_results.find_tests(root):
        fields = suite_results.header(test)
        entries.append({"id": test.resolve().relative_to(root / "tests").with_suffix("").as_posix(),
                        "formal": fields.get("type", "").strip() == "formal",
                        "spec_only": not (RELEASES & set(fields.get("oracle", "").split())),
                        "clauses": sorted(set(fields.get("lrm", "").split()[1:]))})
    return entries


def classify(entries: list[dict], runs: dict[str, dict]) -> dict[str, list[str]]:
    status = lambda sim, test: runs.get(sim, {}).get("tests", {}).get(test)
    found = {c: [] for c in CATEGORIES}
    for e in entries:
        if e["formal"]:
            continue
        test = e["id"]
        seen = {sim: status(sim, test) for sim in runs}
        if not any(seen.values()):
            continue
        passing = {sim for sim, s in seen.items() if s == "pass"}
        if e["spec_only"]:
            if passing == {"kirimasim"}:
                found["kirimasim_only"].append(test)
            elif not passing:
                trio = ("ghost", "kirimasim", "lyra")
                key = ("spec_fail_all" if all(seen.get(s) == "fail" for s in trio)
                       else "spec_no_pass")
                found[key].append(test)
        elif seen.get("ghost") == "fail" and seen.get("lyra") == "fail":
            found["oracle_ghost_lyra"].append(test)
    return {c: sorted(v) for c, v in found.items()}


def spec_only_clauses(entries: list[dict], root: Path) -> list[dict]:
    coverage = suite_catalog.clause_coverage(
        [{"clauses": e["clauses"]} for e in entries])
    leaves = [c for chapter, row in coverage["chapters"].items() if 3 <= chapter <= 40
              for c in row["cited"] + row["parent"] + row["missing"]]
    citing = collections.defaultdict(list)
    for e in entries:
        for clause in e["clauses"]:
            citing[clause].append(e)
    rows = [{"clause": c, "tests": len(citing[c])} for c in leaves
            if citing[c] and all(e["spec_only"] for e in citing[c])]
    return sorted(rows, key=lambda r: (r["tests"], suite_catalog.clause_key(r["clause"])))


TEXT = {
    "en": {
        "title": "Review candidates",
        "other": "[日本語](review-candidates.ja.md)",
        "intro": ("Tests and clauses whose expected results rest least on anything but the "
                  "reading of the standard, from the latest results of each simulator. "
                  "A candidate is not a finding: a review against the standard decides. "
                  "[How the reviews are recorded]({docs}/docs/review-candidates.en.md)."),
        "inputs": "Results read", "sim": "Simulator", "version": "Version", "time": "Time",
        "commit": "Suite commit", "stale": " (older suite commit)", "absent": "not available",
        "counts": "Counts", "category": "Candidate", "number": "Number",
        "spec_fail_all": "Spec only, failing on Ghost, kirimasim and Lyra",
        "kirimasim_only": "Spec only, passing on kirimasim alone",
        "spec_no_pass": "Other spec-only tests passing nowhere",
        "oracle_ghost_lyra": "Release oracle, failing on both Ghost and Lyra",
        "spec_only_clauses": "Clauses whose citing tests are all spec only",
        "test": "Test", "results": "Results", "clause": "Clause", "tests": "Citing tests",
        "none": "None.",
        "legend": "Results: I Icarus Verilog, V Verilator, K kirimasim, L Lyra, G Ghost; "
                  "p pass, f fail, u unsupported, k known, - not run.",
    },
    "ja": {
        "title": "レビュー候補",
        "other": "[English](review-candidates.md)",
        "intro": ("期待値の根拠が規格の読み方にしかないテストと条項を、各シミュレータの最新の結果から挙げます。"
                  "候補は誤りの指摘ではなく、規格と照らした見直しで判断します。"
                  "[見直しの記録の仕方]({docs}/docs/review-candidates.md)。"),
        "inputs": "読んだ結果", "sim": "シミュレータ", "version": "版", "time": "時刻",
        "commit": "スイートのコミット", "stale": "（古いコミット）", "absent": "なし",
        "counts": "件数", "category": "候補", "number": "件数",
        "spec_fail_all": "specのみで、Ghost・kirimasim・Lyraのすべてでfail",
        "kirimasim_only": "specのみで、kirimasimだけがpass",
        "spec_no_pass": "specのみで、どこでもpassしないその他のテスト",
        "oracle_ghost_lyra": "固定版のoracleがあり、GhostとLyraの両方でfail",
        "spec_only_clauses": "引用するテストがすべてspecのみの条項",
        "test": "テスト", "results": "結果", "clause": "条項", "tests": "引用するテスト",
        "none": "なし。",
        "legend": "結果: I Icarus Verilog、V Verilator、K kirimasim、L Lyra、G Ghost。"
                  "p pass、f fail、u unsupported、k known、- 未実行。",
    },
}
MARK = {"pass": "p", "fail": "f", "unsupported": "u", "known": "k"}
LETTER = {"icarus": "I", "verilator": "V", "kirimasim": "K", "lyra": "L", "ghost": "G"}


def render(language: str, runs: dict, found: dict, clauses: list[dict], source_url: str) -> str:
    t = TEXT[language]
    docs = source_url.rstrip("/")
    newest = max((r["time"] for r in runs.values()), default="")
    current = next((r["suite_commit"] for r in runs.values() if r["time"] == newest), "")
    lines = [f"# {t['title']}", "", t["other"], "", t["intro"].format(docs=docs), "",
             f"## {t['inputs']}", "", f"| {t['sim']} | {t['version']} | {t['time']} | {t['commit']} |",
             "| --- | --- | --- | --- |"]
    for sim in SIMULATORS:
        run = runs.get(sim)
        if run is None:
            lines.append(f"| {NAMES[sim]} | {t['absent']} | | |")
            continue
        stale = t["stale"] if run["suite_commit"] != current else ""
        lines.append(f"| {NAMES[sim]} | `{run['version']}` | {run['time']} | "
                     f"`{run['suite_commit'][:8]}`{stale} |")
    lines += ["", f"## {t['counts']}", "", f"| {t['category']} | {t['number']} |", "| --- | ---: |"]
    lines += [f"| {t[c]} | {len(found[c])} |" for c in CATEGORIES]
    lines += [f"| {t['spec_only_clauses']} | {len(clauses)} |", "", t["legend"]]
    for c in CATEGORIES:
        lines += ["", f"## {t[c]}", ""]
        if not found[c]:
            lines.append(t["none"])
            continue
        lines += [f"| {t['test']} | {t['results']} |", "| --- | --- |"]
        for test in found[c]:
            marks = " ".join(f"{LETTER[s]}{MARK.get(runs[s]['tests'].get(test), '-')}"
                             for s in SIMULATORS if s in runs)
            lines.append(f"| [`{test}`]({docs}/tests/{test}.sv) | `{marks}` |")
    lines += ["", f"## {t['spec_only_clauses']}", ""]
    if clauses:
        lines += [f"| {t['clause']} | {t['tests']} |", "| --- | ---: |"]
        lines += [f"| {r['clause']} | {r['tests']} |" for r in clauses]
    else:
        lines.append(t["none"])
    return "\n".join(lines) + "\n"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--results", type=Path, required=True, help="directory of latest/<simulator>.json")
    ap.add_argument("--output", type=Path, required=True, help="directory of the report")
    ap.add_argument("--source-url", default=SOURCE_URL, help="repository blob URL for the links")
    ap.add_argument("--root", type=Path, default=ROOT, help=argparse.SUPPRESS)
    args = ap.parse_args()
    runs = load(args.results)
    if not runs:
        print("review_candidates: no results to read", file=sys.stderr)
        return 1
    entries = tests_of(args.root)
    found = classify(entries, runs)
    clauses = spec_only_clauses(entries, args.root)
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / "review-candidates.md").write_text(
        render("en", runs, found, clauses, args.source_url), encoding="utf-8")
    (args.output / "review-candidates.ja.md").write_text(
        render("ja", runs, found, clauses, args.source_url), encoding="utf-8")
    inputs = {s: {k: v for k, v in r.items() if k != "tests"} for s, r in runs.items()}
    (args.output / "review-candidates.json").write_text(json.dumps(
        {"inputs": inputs, "candidates": found, "spec_only_clauses": clauses},
        ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    counts = ", ".join(f"{c} {len(v)}" for c, v in found.items())
    print(f"review candidates: {counts}, spec_only_clauses {len(clauses)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
