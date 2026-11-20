#!/usr/bin/env python3
"""Keeps the ledger of tests whose expectation follows one of two readings of
IEEE 1800-2023, and the report generated from it.

Usage:
    python3 tools/interpretation_splits.py --update
    python3 tools/interpretation_splits.py --check

coverage/interpretation-splits.json holds one entry per test: its kind
(contested: the text allows two readings; standard_gap: the test relies on
something the standard leaves undefined), the clauses, the two readings in
Japanese and English (a is the reading the current expected output follows,
b the other), which reading the expectation follows (a, b or both, when the
test prints only values that are the same under both), the review document
and anchor where the split was recorded, the handling proposed there, and the
status: unresolved, or resolved with the commit that made the split stop
deciding the expectation.

--update writes docs/interpretation-splits.md (Japanese) and
docs/interpretation-splits.en.md (English). --check validates the ledger
(the tests, the documents and their anchors in both languages exist) and that
the reports are current. Neither changes a test. tools/review_candidates.py
lists the results of these tests apart, without changing any count.
"""

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LEDGER = Path("coverage/interpretation-splits.json")
REPORTS = {"ja": Path("docs/interpretation-splits.md"), "en": Path("docs/interpretation-splits.en.md")}
SOURCE_URL = "https://github.com/kurochan001/kirimasim-tests/blob/main"
KINDS = ("contested", "standard_gap")
STATUSES = ("unresolved", "resolved")
FOLLOWS = ("a", "b", "both")

TEXT = {
    "ja": {
        "title": "読み方が割れるテスト",
        "other": "[English](interpretation-splits.en.md) / [日本語](interpretation-splits.md)",
        "intro": ("規格の文が二つの読み方を許し、期待値がその一方に従っているテストと、規格が定めていないことに"
                  "頼っているテストの台帳です。過去の見直しの記録から集めました。台帳は"
                  "`coverage/interpretation-splits.json`で、この資料は`tools/interpretation_splits.py --update`が"
                  "作ります。テストと期待値は変えていません。扱い（一致率の分母から外すか、両方の読み方の期待値を"
                  "持たせるか）は所有者が決めます。Nightlyの[レビュー候補](review-candidates.md)は、これらの"
                  "テストの結果を別枠で出します。"),
        "counts": "本数", "kind": "区分", "status": "状態", "tests": "本数",
        "contested": "読み方が割れる", "standard_gap": "規格の不備に依存",
        "unresolved": "未解決", "resolved": "解決済み",
        "test": "テスト", "clauses": "条項", "a": "読み方a（期待値が従う）", "b": "読み方b",
        "follows": "期待値", "source": "出典", "proposal": "扱いの案", "resolution": "解決",
        "follow_a": "aに従う", "follow_b": "bに従う", "follow_both": "どちらでも同じ",
        "none": "なし。", "commit": "コミット",
    },
    "en": {
        "title": "Tests with contested readings",
        "other": "[English](interpretation-splits.en.md) / [日本語](interpretation-splits.md)",
        "intro": ("The tests whose expectation follows one of two readings that the text of the standard "
                  "allows, and the tests that rely on something the standard leaves undefined, collected "
                  "from the earlier review documents. The ledger is `coverage/interpretation-splits.json`; "
                  "`tools/interpretation_splits.py --update` writes this report. No test or expectation was "
                  "changed. How they are handled (left out of the denominator of the match rate, or given "
                  "expectations for both readings) is for the owner to decide. The Nightly "
                  "[review candidates](review-candidates.en.md) list the results of these tests apart."),
        "counts": "Counts", "kind": "Kind", "status": "Status", "tests": "Tests",
        "contested": "Contested reading", "standard_gap": "Relies on a gap in the standard",
        "unresolved": "Unresolved", "resolved": "Resolved",
        "test": "Test", "clauses": "Clauses", "a": "Reading a (followed)", "b": "Reading b",
        "follows": "Expectation", "source": "Source", "proposal": "Proposed handling",
        "resolution": "Resolution", "follow_a": "follows a", "follow_b": "follows b",
        "follow_both": "same under both", "none": "None.", "commit": "Commit",
    },
}


def load(root: Path = ROOT) -> dict:
    return json.loads((root / LEDGER).read_text(encoding="utf-8"))


def english(path: str) -> str:
    return path[:-3] + ".en.md"


def validate(ledger: dict, root: Path = ROOT) -> list[str]:
    errors = []
    if ledger.get("schema") != 1 or not isinstance(ledger.get("entries"), list):
        return ["the ledger needs schema 1 and a list of entries"]
    seen = set()
    for entry in ledger["entries"]:
        test = entry.get("test", "?")
        if test in seen:
            errors.append(f"{test}: listed twice")
        seen.add(test)
        if not any((root / "tests" / f"{test}{suffix}").is_file() for suffix in (".sv", ".v")):
            errors.append(f"{test}: the test does not exist")
        if entry.get("kind") not in KINDS:
            errors.append(f"{test}: kind must be one of {', '.join(KINDS)}")
        if entry.get("status") not in STATUSES:
            errors.append(f"{test}: status must be one of {', '.join(STATUSES)}")
        if entry.get("expectation_follows") not in FOLLOWS:
            errors.append(f"{test}: expectation_follows must be one of {', '.join(FOLLOWS)}")
        clauses = entry.get("clauses")
        if not clauses or not all(re.fullmatch(r"[0-9A-Z]+(\.[0-9]+)*", str(c)) for c in clauses):
            errors.append(f"{test}: clauses must list clause numbers")
        readings = entry.get("readings", {})
        for language in ("ja", "en"):
            for side in ("a", "b"):
                if not str(readings.get(language, {}).get(side, "")).strip():
                    errors.append(f"{test}: reading {side} is missing in {language}")
        proposal = entry.get("proposal")
        if proposal is not None and not all(str(proposal.get(l, "")).strip() for l in ("ja", "en")):
            errors.append(f"{test}: a proposal needs both languages")
        source = entry.get("source", {})
        document, anchor = str(source.get("document", "")), str(source.get("anchor", ""))
        for path in (document, english(document)):
            if not path.startswith("docs/") or not (root / path).is_file():
                errors.append(f"{test}: the source document {path} does not exist")
            elif f'<a id="{anchor}"></a>' not in (root / path).read_text(encoding="utf-8"):
                errors.append(f"{test}: {path} has no anchor {anchor!r}")
        resolution = entry.get("resolution")
        if entry.get("status") == "resolved":
            if not resolution or not re.fullmatch(r"[0-9a-f]{7,40}", str(resolution.get("commit", ""))) \
                    or not re.fullmatch(r"\d{4}-\d{2}-\d{2}", str(resolution.get("date", ""))) \
                    or not all(str(resolution.get(l, "")).strip() for l in ("ja", "en")):
                errors.append(f"{test}: a resolved entry needs the commit, date and both languages")
        elif resolution:
            errors.append(f"{test}: an unresolved entry has a resolution")
    return errors


def cell(text: str) -> str:
    return str(text).replace("|", "\\|").replace("\n", " ")


def render(ledger: dict, language: str, source_url: str = SOURCE_URL) -> str:
    t = TEXT[language]
    base = source_url.rstrip("/")
    entries = sorted(ledger["entries"], key=lambda e: e["test"])
    lines = [f"# {t['title']}", "", t["other"], "", t["intro"], "", f"## {t['counts']}", "",
             f"| {t['kind']} | {t['unresolved']} | {t['resolved']} | {t['tests']} |",
             "| --- | ---: | ---: | ---: |"]
    for kind in KINDS:
        rows = [e for e in entries if e["kind"] == kind]
        lines.append(f"| {t[kind]} | {sum(e['status'] == 'unresolved' for e in rows)} | "
                     f"{sum(e['status'] == 'resolved' for e in rows)} | {len(rows)} |")
    lines.append(f"| | {sum(e['status'] == 'unresolved' for e in entries)} | "
                 f"{sum(e['status'] == 'resolved' for e in entries)} | {len(entries)} |")
    for kind in KINDS:
        for status in STATUSES:
            rows = [e for e in entries if e["kind"] == kind and e["status"] == status]
            lines += ["", f"## {t[kind]}：{t[status]}" if language == "ja" else
                      f"## {t[kind]}: {t[status]}", ""]
            if not rows:
                lines.append(t["none"])
                continue
            header = [t["test"], t["clauses"], t["a"], t["b"], t["follows"], t["source"]]
            header.append(t["resolution"] if status == "resolved" else t["proposal"])
            lines += ["| " + " | ".join(header) + " |", "|" + " --- |" * len(header)]
            for e in rows:
                document = e["source"]["document"]
                if language == "en":
                    document = english(document)
                name = Path(document).name
                link = f"[{Path(name).stem}]({name}#{e['source']['anchor']})"
                extra = ""
                if status == "resolved":
                    r = e["resolution"]
                    extra = f"{cell(r[language])} (`{r['commit'][:8]}`, {r['date']})"
                elif e.get("proposal"):
                    extra = cell(e["proposal"][language])
                lines.append("| " + " | ".join([
                    f"[`{e['test']}`]({base}/tests/{e['test']}.sv)", ", ".join(e["clauses"]),
                    cell(e["readings"][language]["a"]), cell(e["readings"][language]["b"]),
                    t["follow_" + e["expectation_follows"]], link, extra]) + " |")
    return "\n".join(lines) + "\n"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    mode = ap.add_mutually_exclusive_group(required=True)
    mode.add_argument("--update", action="store_true")
    mode.add_argument("--check", action="store_true")
    ap.add_argument("--root", type=Path, default=ROOT, help=argparse.SUPPRESS)
    args = ap.parse_args()
    root = args.root.resolve()
    ledger = load(root)
    errors = validate(ledger, root)
    reports = {language: render(ledger, language) for language in REPORTS} if not errors else {}
    if args.update and not errors:
        for language, text in reports.items():
            (root / REPORTS[language]).write_text(text, encoding="utf-8")
    if args.check and not errors:
        for language, text in reports.items():
            path = root / REPORTS[language]
            if not path.is_file() or path.read_text(encoding="utf-8") != text:
                errors.append(f"{REPORTS[language]} is out of date: run --update")
    for error in errors:
        print(f"interpretation_splits: {error}", file=sys.stderr)
    if errors:
        return 1
    entries = ledger["entries"]
    open_count = sum(e["status"] == "unresolved" for e in entries)
    print(f"interpretation_splits: {len(entries)} tests, {open_count} unresolved")
    return 0


if __name__ == "__main__":
    sys.exit(main())
