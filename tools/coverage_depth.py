#!/usr/bin/env python3
"""Writes docs/coverage-depth.md: how many tests each clause has, which
clauses have only one test, which clauses are checked only against the
standard, and which clauses are cited with an out-of-scope tag.

Usage:
    python3 tools/coverage_depth.py            print the file it would write
    python3 tools/coverage_depth.py --update   rewrite docs/coverage-depth.md
    python3 tools/coverage_depth.py --check    exit with 1 if it is out of date
    python3 tools/coverage_depth.py --check --minimum-tests 2
                                             also enforce direct test depth

The report counts a clause as covered by a test when the test cites the
clause in :lrm:. A clause can be cited by several tests, and a test can
cite several clauses, so a count is a citation count, not a measure of
how deeply a behavior is exercised. The report is a guide to the next
tests: the priority queue lists clauses that one test covers and that
one test has only a :oracle: spec expectation.
"""

import argparse
import collections
import sys
from pathlib import Path

import suite_catalog
import suite_results
import suite_stats

ROOT = Path(__file__).resolve().parent.parent
CATALOG = ROOT / "docs" / "tests"
DEPTH = ROOT / "docs" / "coverage-depth.md"
ORACLE_LABELS = {
    "both": "both releases",
    "icarus": "Icarus Verilog 13.0 only",
    "verilator": "Verilator 5.052 only",
    "spec": "standard only",
}


def oracle_kind(fields: dict[str, str]) -> str:
    oracles = set(fields.get("oracle", "").split())
    if "iverilog@13.0" in oracles and "verilator@5.052" in oracles:
        return "both"
    if "iverilog@13.0" in oracles:
        return "icarus"
    if "verilator@5.052" in oracles:
        return "verilator"
    return "spec"


def collect() -> dict:
    tests = suite_results.find_tests()
    entries = []
    for test in tests:
        fields = suite_results.header(test)
        entries.append({
            "path": test.relative_to(ROOT).as_posix(),
            "chapter": int(test.parent.name.removeprefix("ch")),
            "clauses": fields.get("lrm", "").split()[1:],
            "oracle": oracle_kind(fields),
        })
    coverage = suite_catalog.clause_coverage(
        [suite_catalog.entry(Path(t)) for t in tests])
    by_clause = collections.defaultdict(list)
    for e in entries:
        for clause in set(e["clauses"]):
            by_clause[clause].append(e)
    return {"tests": entries, "coverage": coverage, "by_clause": by_clause}


def clause_list(items: list[str]) -> str:
    return ", ".join(sorted(items, key=suite_catalog.clause_key))


def shallow_clauses(data: dict, minimum: int) -> list[str]:
    """In-scope leaf clauses without enough directly citing tests.

    A parent citation does not count as a direct test of its children.
    Include missing clauses instead of measuring only the cited ones.
    """
    return sorted((c for row in data["coverage"]["chapters"].values()
                   for kind in ("cited", "parent", "missing") for c in row[kind]
                   if len(data["by_clause"].get(c, [])) < minimum),
                  key=suite_catalog.clause_key)


def report(data: dict) -> str:
    coverage = data["coverage"]
    by_clause = data["by_clause"]
    tests = data["tests"]
    rows = coverage["chapters"]
    cited = [c for r in rows.values() for c in r["cited"]]
    single = [c for c in cited if len(by_clause[c]) == 1]
    single_spec = [c for c in single
                   if all(e["oracle"] == "spec" for e in by_clause[c])]
    spec_only = [c for c in cited
                 if all(e["oracle"] == "spec" for e in by_clause[c])]
    in_scope = len(cited) + sum(len(r["parent"]) + len(r["missing"])
                                for r in rows.values())
    out_scope = sum(len(r["out"]) for r in rows.values())
    oracle_counts = collections.Counter(e["oracle"] for e in tests)
    tagged = [c for c in cited if coverage["tags"].get(c)]

    lines = [
        "# Coverage depth",
        "",
        "[All chapters](tests/README.md). This page is written by "
        "`tools/coverage_depth.py` from the metadata of the tests; edit the "
        "tests, not this page. It counts how many tests cite each clause in "
        "`:lrm:` and which releases produce their expected outputs. A citation "
        "is not a measure of how deeply a behavior is exercised: one test can "
        "cite several clauses, and several tests can cite one clause.",
        "",
        "## Summary",
        "",
        "| Measure | Value |",
        "| --- | ---: |",
        f"| Tests | {len(tests)} |",
        f"| Clauses in scope | {in_scope} |",
        f"| Clauses out of scope | {out_scope} |",
        f"| Clauses with a direct test | {in_scope - len(shallow_clauses(data, 1))}/{in_scope} |",
        f"| Clauses with at least two direct tests | "
        f"{in_scope - len(shallow_clauses(data, 2))}/{in_scope} |",
        f"| Clauses with one test | {len(single)} |",
        f"| Clauses with two tests or fewer | "
        f"{sum(1 for c in cited if len(by_clause[c]) <= 2)} |",
        f"| Clauses with only standard-only tests | {len(spec_only)} |",
        f"| Clauses with one test and only a standard-only test | "
        f"{len(single_spec)} |",
        "",
        "| Oracle | Tests |",
        "| --- | ---: |",
    ]
    for kind in ("both", "icarus", "verilator", "spec"):
        lines.append(f"| {ORACLE_LABELS[kind]} | {oracle_counts[kind]} |")

    lines += ["", "## By chapter", "",
              "| Chapter | Title | Tests | In scope | Tests/clause | One test | "
              "Standard only |",
              "| ---: | --- | ---: | ---: | ---: | ---: | ---: |"]
    for chapter, row in rows.items():
        n = len(row["cited"]) + len(row["parent"]) + len(row["missing"])
        if not n:
            continue
        chapter_tests = [e for e in tests if e["chapter"] == chapter]
        one = sum(1 for c in row["cited"] if len(by_clause[c]) == 1)
        spec = sum(1 for e in chapter_tests if e["oracle"] == "spec")
        lines.append(f"| {chapter} | {suite_stats.CHAPTERS[chapter]} | "
                     f"{len(chapter_tests)} | {n} | {len(chapter_tests)/n:.1f} | "
                     f"{one} | {spec} |")

    lines += ["", "## Priority queue: one test, standard only", "",
              "These clauses have exactly one citing test, and that test has "
              "`:oracle: spec` alone. They are the first candidates for a "
              "second test or an independent oracle.", ""]
    if single_spec:
        for clause in sorted(single_spec, key=suite_catalog.clause_key):
            test = by_clause[clause][0]["path"]
            lines.append(f"- `{clause}`: `{test}`")
    else:
        lines.append("None.")

    lines += ["", "## One-test clauses by chapter", ""]
    by_chapter = collections.Counter(c.split(".")[0] for c in single)
    lines.append("| Chapter | Clauses |")
    lines.append("| ---: | ---: |")
    for chapter in sorted(by_chapter, key=int):
        lines.append(f"| {chapter} | {by_chapter[chapter]} |")

    lines += ["", "## Clauses with only standard-only tests", "",
              "These clauses are cited, but no release produces the expected "
              "output of any of their tests.", ""]
    if spec_only:
        lines.append(clause_list(spec_only))
    else:
        lines.append("None.")

    lines += ["", "## Cited clauses with an out-of-scope tag", "",
              "These clauses are cited by tests but carry a tag in "
              "`tools/clauses.txt` that says they are out of scope. Either "
              "the tag or the citation needs a review.", ""]
    if tagged:
        for clause in sorted(tagged, key=suite_catalog.clause_key):
            lines.append(f"- `{clause}`: tag `{coverage['tags'][clause]}`")
    else:
        lines.append("None.")

    if coverage["unknown"]:
        lines += ["", "## Cited clauses missing from tools/clauses.txt", "",
                  clause_list(coverage["unknown"])]

    return "\n".join(lines) + "\n"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--update", action="store_true", help="write docs/coverage-depth.md")
    ap.add_argument("--check", action="store_true",
                    help="exit with 1 if docs/coverage-depth.md is out of date")
    ap.add_argument("--minimum-tests", type=int,
                    help="require this many directly citing tests per in-scope leaf clause")
    args = ap.parse_args()
    if args.minimum_tests is not None and args.minimum_tests < 1:
        ap.error("--minimum-tests must be positive")
    data = collect()
    text = report(data)
    shallow = shallow_clauses(data, args.minimum_tests) if args.minimum_tests else []
    if shallow:
        print(f"{len(shallow)} clauses have fewer than {args.minimum_tests} direct tests: "
              + clause_list(shallow), file=sys.stderr)
    if args.check:
        return 0 if not shallow and DEPTH.is_file() and DEPTH.read_text() == text else 1
    if args.update:
        DEPTH.write_text(text)
        print(f"wrote {DEPTH.relative_to(ROOT)}")
    else:
        print(text, end="")
    return 1 if shallow else 0


if __name__ == "__main__":
    sys.exit(main())
