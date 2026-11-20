#!/usr/bin/env python3
"""Keeps the ledger of features added to SystemVerilog by IEEE 1800-2023 and
the tests that exercise them, and the report generated from it.

Usage:
    python3 tools/sv2023_features.py --update
    python3 tools/sv2023_features.py --check

coverage/sv2023-features.json lists each feature with its title, the clauses
that define it, the requirement rows of coverage/behaviors.json about it, the
illegal forms the standard defines for it, and the tests whose code was read
and found to exercise it, each marked illegal when its intended violation is
about the feature. Regular expressions only proposed candidates; the ledger
lists checked tests.

--update writes docs/sv2023-features.md (Japanese) and
docs/sv2023-features.en.md (English): per feature the numbers of tests (legal
uses and illegal designs), how many have a fixed-release oracle (iverilog@13.0,
verilator@5.052 or verilator@5.054) and how many rest on the standard only, the
tests that pass in a saved result of each simulator (coverage/results/*.json
whose runner digest is current and whose input digest matches the test), and
the mapped requirement rows. --check validates the ledger (tests, requirement
rows and illegal marks) and that the report is current.
"""

import argparse
import json
import re
import sys
from pathlib import Path

import suite_results
import suite_stats

ROOT = Path(__file__).resolve().parent.parent
LEDGER = Path("coverage/sv2023-features.json")
REPORTS = {"ja": Path("docs/sv2023-features.md"), "en": Path("docs/sv2023-features.en.md")}
SOURCE_URL = "https://github.com/kurochan001/kirimasim-tests/blob/main"
SIMULATORS = ("icarus", "verilator", "kirimasim", "lyra", "ghost")
LETTER = {"icarus": "I", "verilator": "V", "kirimasim": "K", "lyra": "L", "ghost": "G"}
RELEASES = {"iverilog@13.0", *suite_stats.VERILATOR_ORACLES}
SOURCES = ("dvcon", "instruction")

TEXT = {
    "ja": {
        "title": "IEEE 1800-2023で加わった機能のテスト",
        "other": "[English](sv2023-features.en.md) / [日本語](sv2023-features.md)",
        "intro": ("1800-2023で加わった機能ごとに、その機能を実際に使うテストの本数と裏付けをまとめます。"
                  "台帳は`coverage/sv2023-features.json`で、この資料は`tools/sv2023_features.py --update`が作ります。"
                  "台帳のテストは、正規表現で出した候補を一本ずつ読んで確かめたものです。"
                  "機能の一覧はDVConのチュートリアル「A Subjective Review on IEEE Std 1800-2023」の18項目に、"
                  "`ref static`・実数のカバーポイント・型パラメータの制限を加えたものです。規格には改訂で加わった機能の"
                  "一覧がなく、この3つが2023で加わったものかは規格の本文だけでは確かめられません。"),
        "summary": "一覧", "feature": "機能", "clauses": "条項", "tests": "テスト", "legal": "正常系",
        "illegal": "規格違反", "reference": "固定版の裏付け", "spec": "規格のみ",
        "pass": "保存済みの結果でpass", "requirements": "要求（対応済み／行数）",
        "illegal_forms": "規格が定める不正な形", "none": "なし。", "test": "テスト", "kind": "種類",
        "oracle": "`:oracle:`", "results": "保存済みの結果",
        "legend": ("保存済みの結果：I Icarus Verilog 13.0、V Verilator、K kirimasim、L Lyra、G Ghost。"
                   "テストの今の入力と同じ入力で保存された結果のどれかがpassならp、なければ-。"
                   "規格違反のテストでは、未対応の構文による拒否もpassに見えることがあります。"),
        "source_dvcon": "DVConの18項目", "source_instruction": "追加の3項目", "listed": "一覧の出典",
        "kind_legal": "正常系", "kind_illegal": "規格違反",
    },
    "en": {
        "title": "Tests of the features added by IEEE 1800-2023",
        "other": "[English](sv2023-features.en.md) / [日本語](sv2023-features.md)",
        "intro": ("For each feature added by 1800-2023, the number of tests that exercise it and what backs "
                  "their expectations. The ledger is `coverage/sv2023-features.json`; "
                  "`tools/sv2023_features.py --update` writes this report. The tests of the ledger were read "
                  "one by one from candidates found by regular expressions. The features are the 18 items of "
                  "the DVCon tutorial \"A Subjective Review on IEEE Std 1800-2023\" and `ref static`, real "
                  "coverpoints and type parameter restrictions. The standard has no list of the features its "
                  "revision added, so whether these last three are new in 2023 cannot be confirmed from its "
                  "text alone."),
        "summary": "Summary", "feature": "Feature", "clauses": "Clauses", "tests": "Tests",
        "legal": "Legal", "illegal": "Illegal", "reference": "Fixed-release oracle",
        "spec": "Standard only", "pass": "Pass in a saved result",
        "requirements": "Requirements (mapped / rows)", "illegal_forms": "Illegal forms the standard defines",
        "none": "None.", "test": "Test", "kind": "Kind", "oracle": "`:oracle:`", "results": "Saved results",
        "legend": ("Saved results: I Icarus Verilog 13.0, V Verilator, K kirimasim, L Lyra, G Ghost. p when a "
                   "result saved for the current input of the test passes, - otherwise. For an illegal design "
                   "a rejection caused by unsupported syntax can also look like a pass."),
        "source_dvcon": "the 18 DVCon items", "source_instruction": "the three added items",
        "listed": "Listed in", "kind_legal": "legal", "kind_illegal": "illegal",
    },
}


def load(root: Path = ROOT) -> dict:
    return json.loads((root / LEDGER).read_text(encoding="utf-8"))


def test_path(root: Path, test: str) -> Path | None:
    for suffix in (".sv", ".v"):
        path = root / "tests" / f"{test}{suffix}"
        if path.is_file():
            return path
    return None


def validate(ledger: dict, root: Path = ROOT) -> list[str]:
    if ledger.get("schema") != 1 or not isinstance(ledger.get("features"), list):
        return ["the ledger needs schema 1 and a list of features"]
    rows = {r["id"] for r in json.loads((root / "coverage" / "behaviors.json")
                                        .read_text(encoding="utf-8"))["requirements"]}
    errors, keys = [], set()
    for feature in ledger["features"]:
        key = feature.get("key", "?")
        if key in keys:
            errors.append(f"{key}: listed twice")
        keys.add(key)
        if not all(str(feature.get("title", {}).get(l, "")).strip() for l in ("ja", "en")):
            errors.append(f"{key}: the title needs both languages")
        if feature.get("listed_in") not in SOURCES:
            errors.append(f"{key}: listed_in must be one of {', '.join(SOURCES)}")
        if not feature.get("clauses") or not all(
                re.fullmatch(r"[0-9A-Z]+(\.[0-9]+)*", str(c)) for c in feature["clauses"]):
            errors.append(f"{key}: clauses must list clause numbers")
        for rid in feature.get("requirements", []):
            if rid not in rows:
                errors.append(f"{key}: unknown requirement {rid}")
        for form in feature.get("illegal_forms", []):
            if not re.fullmatch(r"[0-9A-Z]+(\.[0-9]+)*", str(form.get("clause", ""))) or \
                    not all(str(form.get(l, "")).strip() for l in ("ja", "en")):
                errors.append(f"{key}: an illegal form needs a clause and both languages")
        seen = set()
        for item in feature.get("tests", []):
            test = item.get("test", "?")
            if test in seen:
                errors.append(f"{key}: {test} listed twice")
            seen.add(test)
            path = test_path(root, test)
            if path is None:
                errors.append(f"{key}: the test {test} does not exist")
                continue
            if item.get("illegal") and "should_fail_because" not in suite_results.header(path):
                errors.append(f"{key}: {test} is marked illegal but has no :should_fail_because:")
    return errors


def saved_passes(root: Path, tests: set[str]) -> dict[str, set[str]]:
    """For each simulator, the tests with a pass in a saved result whose runner
    digest is current and whose input digest matches the test now."""
    digests = {t: suite_results.input_digest(test_path(root, t)) for t in tests if test_path(root, t)}
    passes = {sim: set() for sim in SIMULATORS}
    for path in sorted((root / "coverage" / "results").glob("*.json")):
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, ValueError):
            continue
        sim = data.get("simulator")
        if sim not in passes or data.get("runner_changed") or \
                data.get("runner_sha256") != suite_results.runner_digest(sim):
            continue
        for test in digests:
            record = data.get("tests", {}).get(test)
            if isinstance(record, dict) and record.get("status") == "pass" \
                    and record.get("inputs_sha256") == digests[test]:
                passes[sim].add(test)
    return passes


def render(ledger: dict, language: str, passes: dict, mapped: set[str], root: Path = ROOT,
           source_url: str = SOURCE_URL) -> str:
    t = TEXT[language]
    base = source_url.rstrip("/")
    sims = [s for s in SIMULATORS if passes.get(s)] or list(SIMULATORS[:3])
    lines = [f"# {t['title']}", "", t["other"], "", t["intro"], "", f"## {t['summary']}", "",
             f"| {t['feature']} | {t['clauses']} | {t['tests']} | {t['legal']} | {t['illegal']} | "
             f"{t['reference']} | {t['spec']} | " + " | ".join(LETTER[s] for s in sims) +
             f" | {t['requirements']} | {t['listed']} |",
             "| --- | --- |" + " ---: |" * (5 + len(sims)) + " ---: | --- |"]
    for f in ledger["features"]:
        tests = f["tests"]
        ref = [x for x in tests if RELEASES & set(suite_results.header(
            test_path(root, x["test"])).get("oracle", "").split())]
        reqs = f.get("requirements", [])
        lines.append(f"| [{f['title'][language]}](#{f['key'].replace('_', '-')}) | "
                     f"{', '.join(f['clauses'])} | {len(tests)} | "
                     f"{sum(not x['illegal'] for x in tests)} | {sum(bool(x['illegal']) for x in tests)} | "
                     f"{len(ref)} | {len(tests) - len(ref)} | " +
                     " | ".join(str(sum(x['test'] in passes.get(s, set()) for x in tests)) for s in sims) +
                     f" | {sum(r in mapped for r in reqs)}/{len(reqs)} | {t['source_' + f['listed_in']]} |")
    lines += ["", t["legend"]]
    for f in ledger["features"]:
        lines += ["", f'<a id="{f["key"].replace("_", "-")}"></a>', "", f"## {f['title'][language]}", "",
                  f"- {t['clauses']}: {', '.join(f['clauses'])}",
                  f"- {t['illegal_forms']}: " + ("; ".join(f"{x[language]} ({x['clause']})"
                                                        for x in f.get("illegal_forms", [])) or t["none"]),
                  f"- {t['requirements']}: " + (", ".join(
                      f"`{r}`" + ("" if r in mapped else " (-)") for r in f.get("requirements", [])) or t["none"]),
                  ""]
        if not f["tests"]:
            lines.append(t["none"])
            continue
        lines += [f"| {t['test']} | {t['kind']} | {t['oracle']} | {t['results']} |", "| --- | --- | --- | --- |"]
        for x in sorted(f["tests"], key=lambda x: (x["illegal"], x["test"])):
            oracle = suite_results.header(test_path(root, x["test"])).get("oracle", "")
            marks = " ".join(f"{LETTER[s]}{'p' if x['test'] in passes.get(s, set()) else '-'}" for s in sims)
            lines.append(f"| [`{x['test']}`]({base}/tests/{x['test']}.sv) | "
                         f"{t['kind_illegal'] if x['illegal'] else t['kind_legal']} | `{oracle}` | `{marks}` |")
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
    if not errors:
        tests = {x["test"] for f in ledger["features"] for x in f["tests"]}
        passes = saved_passes(root, tests)
        mapped = {r["id"] for r in json.loads((root / "coverage" / "behaviors.json")
                                              .read_text(encoding="utf-8"))["requirements"] if r.get("checks")}
        reports = {language: render(ledger, language, passes, mapped, root) for language in REPORTS}
        for language, text in reports.items():
            path = root / REPORTS[language]
            if args.update:
                path.write_text(text, encoding="utf-8")
            elif not path.is_file() or path.read_text(encoding="utf-8") != text:
                errors.append(f"{REPORTS[language]} is out of date: run --update")
    for error in errors:
        print(f"sv2023_features: {error}", file=sys.stderr)
    if errors:
        return 1
    count = sum(len(f["tests"]) for f in ledger["features"])
    print(f"sv2023_features: {len(ledger['features'])} features, {count} test entries")
    return 0


if __name__ == "__main__":
    sys.exit(main())
