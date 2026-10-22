#!/usr/bin/env python3
"""Measure reviewed IEEE 1800-2023 behavior obligations, separately from citations.

    python3 tools/behavior_coverage.py --update
    python3 tools/behavior_coverage.py --check
    python3 tools/behavior_coverage.py --results results/*.json --output /tmp/behavior.md
    python3 tools/behavior_coverage.py --require-complete

The whole-standard percentage is unknown until every normative section's own
text (including parent introductions and annexes) has been decomposed/reviewed.
Registered obligations and current execution evidence have separate denominators.
No requirement is inferred from :lrm:, a test name, :oracle: or a simulator pass.
"""

import argparse
import datetime
import hashlib
import json
import re
import sys
from pathlib import Path

import suite_results

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "coverage"
REPORT = ROOT / "docs" / "behavior-coverage.md"
REVIEWS = {"unreviewed", "in_progress", "complete", "no_behavior"}
KINDS = {"normal", "boundary", "error"}
SIMULATORS = {"icarus", "verilator", "kirimasim", "sukimasim"}


class InvalidCoverage(ValueError):
    pass


def require(condition: bool, message: str) -> None:
    if not condition:
        raise InvalidCoverage(message)


def section_key(number: str) -> tuple:
    parts = number.split(".")
    first = int(parts[0]) if parts[0].isdigit() else 100 + ord(parts[0])
    return first, *(int(p) for p in parts[1:])


def local_file(name: str) -> Path:
    require(isinstance(name, str) and name, "empty file reference")
    path = (ROOT / name).resolve()
    require(not Path(name).is_absolute() and path.is_relative_to(ROOT),
            f"file outside repository: {name}")
    require(path.is_file(), f"missing file: {name}")
    return path


def validate(inventory: dict, registry: dict) -> tuple[dict, list]:
    """Reject malformed/stale links; an intentionally unmapped obligation is valid."""
    require(inventory.get("schema") == registry.get("schema") == 1, "unknown schema")
    denominator = registry.get("denominator_review", {"state": "pending"})
    require(denominator.get("state") in ("pending", "approved"), "invalid denominator review")
    if denominator["state"] == "approved":
        require(all(denominator.get(k) for k in ("reviewer", "reviewed_on", "scope_note")),
                "approved denominator needs review metadata")
    sections = {}
    for s in inventory["sections"]:
        number = s["id"]
        require(re.fullmatch(r"(?:[1-9]|[1-3][0-9]|4[01]|[A-Q])(?:\.[1-9][0-9]*)*",
                             number), f"invalid section {number}")
        require(number not in sections, f"duplicate section {number}")
        require(s.get("title") and isinstance(s.get("pdf_page"), int)
                and 1 <= s["pdf_page"] <= inventory["source"]["pdf_pages"],
                f"invalid source location {number}")
        require(s.get("kind") in ("normative", "informative"), f"invalid kind {number}")
        require(s.get("review") in REVIEWS, f"invalid review {number}")
        if s["review"] in ("complete", "no_behavior"):
            require(s.get("review_note") and s.get("reviewed_on"),
                    f"completed audit needs a rationale/date: {number}")
        sections[number] = s
    roots = {str(n) for n in range(1, 42)} | set("ABCDEFGHIJKLMNOPQ")
    require(roots <= sections.keys(), "inventory must include clauses 1–41 and annexes A–Q")
    for number in sections:
        if "." in number:
            require(number.rsplit(".", 1)[0] in sections, f"missing parent of {number}")
    # The baseline locks the imported section set as well as registered IDs.
    rows, ids = [], set()
    digest_cache = {}
    for r in registry["requirements"]:
        rid = r["id"]
        require(re.fullmatch(r"SV2023-[A-Z0-9.-]+", rid), f"invalid behavior ID {rid}")
        require(rid not in ids, f"duplicate behavior ID {rid}")
        ids.add(rid)
        require(r.get("clause") in sections, f"unknown clause: {rid}")
        require(sections[r["clause"]]["kind"] == "normative", f"informative behavior: {rid}")
        require(sections[r["clause"]]["review"] != "no_behavior",
                f"no_behavior section has a requirement: {rid}")
        require(r.get("kind") in KINDS, f"invalid case kind: {rid}")
        require(all(isinstance(r.get(k), str) and r[k].strip()
                    for k in ("behavior", "acceptance", "source_note")),
                f"behavior, acceptance and source_note required: {rid}")
        checks, seen = [], set()
        for c in r["checks"]:
            test = local_file(c["test"])
            require(test in suite_test_paths(), f"not a suite test: {c['test']}")
            require(c["test"] not in seen, f"duplicate test mapping: {rid}")
            seen.add(c["test"])
            fields = suite_results.header(test)
            require(r["clause"] in fields.get("lrm", "").split()[1:],
                    f"test must cite mapped clause {r['clause']}: {c['test']}")
            require(bool(fields.get("should_fail_because")) == (r["kind"] == "error"),
                    f"negative/positive case mismatch: {rid}")
            require(re.fullmatch(r"\d{4}-\d{2}-\d{2}", c.get("reviewed_on", ""))
                    and c.get("reviewer") and c.get("observation"),
                    f"mapping needs review date, reviewer and observation: {rid}")
            if test not in digest_cache:
                digest_cache[test] = suite_results.input_digest(test)
            require(c.get("inputs_sha256") == digest_cache[test],
                    f"stale reviewed mapping: {rid} -> {c['test']}; review changed inputs")
            inputs = set(suite_results.input_files(test))
            anchors = c.get("evidence", [])
            require(anchors and any(a["file"] == c["test"] for a in anchors),
                    f"mapping must identify a stimulus in the test: {rid}")
            expected = fields.get("expected_stdout", "")
            expected_path = (test.parent / expected[1:]).resolve() if expected.startswith("@") else test
            require(any(local_file(a["file"]) == expected_path for a in anchors)
                    if r["kind"] != "error" else
                    any("expected_stderr_regex" in a["contains"] for a in anchors),
                    f"mapping must identify the checked output/diagnostic: {rid}")
            for a in anchors:
                path = local_file(a["file"])
                require(path in inputs, f"evidence not among test inputs: {a['file']}")
                require(a.get("contains") and a["contains"] in path.read_text(encoding="utf-8"),
                        f"missing observation anchor: {rid} in {a['file']}")
            checks.append(c)
        rows.append({**r, "mapped": bool(checks)})
    for number, s in sections.items():
        if s["review"] == "complete":
            require(any(r["clause"] == number for r in rows),
                    f"complete section has no decomposed obligations: {number}")
    return sections, rows


_test_paths = None


def suite_test_paths() -> set:
    global _test_paths
    if _test_paths is None:
        _test_paths = set(suite_results.find_tests())
    return _test_paths


def baseline(sections: dict, rows: list, source: dict | None = None) -> dict:
    structure = [{k: s[k] for k in ("id", "title", "pdf_page", "kind")}
                 for _, s in sorted(sections.items(), key=lambda item: section_key(item[0]))]
    return {"schema": 1,
            "inventory_sha256": hashlib.sha256(json.dumps(
                [source, structure], sort_keys=True).encode()).hexdigest(),
            "sections": sorted(sections, key=section_key),
            "normative_sections": sorted((n for n, s in sections.items()
                                           if s["kind"] == "normative"), key=section_key),
            "requirements": sorted(r["id"] for r in rows),
            "contracts": {r["id"]: hashlib.sha256(json.dumps(
                {k: r[k] for k in ("clause", "kind", "behavior", "acceptance", "source_note")},
                sort_keys=True).encode()).hexdigest() for r in rows},
            "mapped": sorted(r["id"] for r in rows if r["mapped"]),
            "audited_sections": sorted((n for n, s in sections.items()
                                        if s["review"] in ("complete", "no_behavior")),
                                       key=section_key)}


def check_baseline(before: dict, after: dict) -> None:
    require(before.get("schema") == 1, "unknown baseline schema")
    require(before["inventory_sha256"] == after["inventory_sha256"],
            "standard inventory/source changed; review and explain a baseline update")
    if "source_index_sha256" in before:
        require(before["source_index_sha256"] == after.get("source_index_sha256"),
                "source-block inventory changed; reconcile the PDF/text and explain a baseline update")
    if "source_reviewed_sections" in before:
        require(set(before["source_reviewed_sections"]) <= set(after.get("source_reviewed_sections", [])),
                "source review regression: previously classified sections are missing")
    for key in ("sections", "normative_sections", "requirements", "mapped", "audited_sections"):
        lost = set(before[key]) - set(after[key])
        require(not lost, f"coverage regression ({key}): {', '.join(sorted(lost))}")
    for rid, digest in before["contracts"].items():
        require(after["contracts"].get(rid) == digest,
                f"behavior contract changed: {rid}; review and explain a baseline update")


def execution(rows: list, result_paths: list[Path]) -> tuple[dict, list]:
    """Only fresh pass results count. Files are separate snapshots, never merged
    across versions/runs to make a single simulator appear to cover more cases.
    """
    snapshots, ignored = [], []
    digests = {}
    for path in sorted(result_paths):
        data = json.loads(path.read_text(encoding="utf-8"))
        simulator = data.get("simulator")
        if (simulator not in SIMULATORS or not data.get("version")
                or not data.get("generated_at") or data.get("runner_changed")
                or data.get("runner_sha256") != suite_results.runner_digest(simulator)):
            ignored.append(f"{path.name}: legacy, unknown, or stale runner provenance")
            continue
        executed, stale = set(), 0
        for r in rows:
            if not r["mapped"]:
                continue
            for c in r["checks"]:
                test = ROOT / c["test"]
                result = data.get("tests", {}).get(suite_results.test_id(test), {})
                if not result:
                    continue
                if c["test"] not in digests:
                    digests[c["test"]] = suite_results.input_digest(test)
                if (result.get("inputs_changed")
                        or result.get("inputs_sha256") != digests[c["test"]]):
                    stale += 1
                    continue
                if result.get("status") != "pass":
                    continue
                # Unsupported syntax can accidentally satisfy an illegal-test
                # line regexp. Only a reviewed, pinned negative oracle counts.
                if r["kind"] == "error":
                    oracle = {"icarus": ("iverilog@13.0", r"version 13\.0(?:\s|$)"),
                              "verilator": ("verilator@5.052", r"Verilator 5\.052(?:\s|$)")}
                    token, version = oracle.get(simulator, ("", r"(?!)"))
                    if (token not in suite_results.header(test).get("oracle", "").split()
                            or not re.search(version, data["version"])):
                        continue
                executed.add(r["id"])
                break
        snapshots.append({"file": path.name, "simulator": simulator,
                          "version": data["version"], "generated_at": data["generated_at"],
                          "executed": sorted(executed), "stale_links": stale})
    return {"snapshots": snapshots,
            "executed": sorted({rid for s in snapshots for rid in s["executed"]})}, ignored


def summarize(sections: dict, rows: list, runs: dict, denominator_reviewed: bool = False) -> dict:
    normative = {n: s for n, s in sections.items() if s["kind"] == "normative"}
    audited = sum(s["review"] in ("complete", "no_behavior") for s in normative.values())
    mapped = sum(r["mapped"] for r in rows)
    total_known = denominator_reviewed and audited == len(normative) and bool(rows)
    return {"sections": len(sections), "normative_sections": len(normative),
            "audited_sections": audited, "registered": len(rows), "mapped": mapped,
            "denominator_reviewed": denominator_reviewed,
            "extraction_progress_percent": 100 * audited / len(normative) if normative else None,
            "unmapped": len(rows) - mapped, "executed": len(runs["executed"]),
            "whole_standard_percent": 100 * mapped / len(rows) if total_known else None,
            "whole_standard_executed_percent": 100 * len(runs["executed"]) / len(rows)
            if total_known else None,
            "registered_percent": 100 * mapped / len(rows) if rows else None}


def append_history(path: Path, entry: dict) -> None:
    """Keep the denominator identity beside counts so scope changes stay visible."""
    data = json.loads(path.read_text()) if path.is_file() else {"schema": 1, "runs": []}
    require(data.get("schema") == 1 and isinstance(data.get("runs"), list),
            "unknown behavior history format")
    data["runs"].append(entry)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")


def report(inventory: dict, sections: dict, rows: list, runs: dict, ignored: list,
           source_url: str | None = None, source_audit: dict | None = None,
           denominator_reviewed: bool = False) -> str:
    stats = summarize(sections, rows, runs, denominator_reviewed)
    total = stats["registered"]
    pct = lambda n: f"{n}/{total} ({100*n/total:.2f}%)" if total else "0/0 (undefined)"
    whole = stats["whole_standard_percent"]
    executed_whole = stats["whole_standard_executed_percent"]
    pending = ("未確定（資料確認済み。解釈保留と要求の重複整理が残る）"
               if source_audit and source_audit["source_review_complete"]
               else "未確定（要求の洗い出しが未完了）")
    link = lambda path: f"{source_url.rstrip('/')}/{path}" if source_url else f"../{path}"
    lines = ["# IEEE 1800-2023 動作カバレッジ", "",
             "`tools/behavior_coverage.py` が `coverage/` の台帳と実行証跡から生成します。",
             f"[全要求の抽出結果]({link('docs/requirement-extraction.md')}) / "
             f"[管理手順]({link('coverage/README.md')}) / "
             f"[節の引用数]({link('docs/coverage-depth.md')})", "",
             f"**規格全動作のテスト設計網羅率: {pending if whole is None else f'{whole:.2f}%'}。**",
             f"規格全動作の実行確認率: {'未確定' if executed_whole is None else f'{executed_whole:.2f}%'}。",
             "節の引用やテスト本数を、全動作の網羅率に換算しません。", "",
             f"- 規格棚卸し: 本文1–41章と附属書A–Q、計 {stats['sections']} 見出し。",
             f"- 規定部分の解釈保留なし: {stats['audited_sections']}/{stats['normative_sections']} 見出し "
             f"({stats['extraction_progress_percent']:.2f}%)。資料確認率・動作網羅率とは別です。",
             f"- 登録済み動作に対するテスト設計網羅率: {pct(stats['mapped'])}。",
             f"- 登録済み動作のうち、新鮮な実行成功証跡があるもの: {pct(stats['executed'])}。",
             f"- 登録済みだがテスト未対応: {stats['unmapped']} 動作。", "",
             "登録済み動作だけの割合は規格全体の割合ではありません。親節の導入本文も独立した",
             "調査対象です。図・表・構文・例外・エラー・他節参照を調べ、要求を分解して初めて",
             "その見出しを完了にできます。ツール依存・未実装は自動的な除外理由になりません。", "",
             f"[要求抽出の未解決事項]({link('docs/requirement-extraction-notes.md')})も管理します。",
             "登録単位には要求文の出現箇所、条件別の検証項目、初期登録の具体的な観測ケースを含みます。",
             "登録件数は、意味的に重複のない全規格要求数を確定した値ではありません。", "",
             "## 実行証跡", "",
             "成功は対応テストの全期待出力／診断の一致を意味します。`known`、`unsupported`、",
             "`fail`、来歴なし、入力／ランナー変更後の結果は成功に数えません。複数の結果の和集合は",
             "独立した検証環境での確認数であり、一つのシミュレータの適合率ではありません。", ""]
    if source_audit:
        position = lines.index(f"- 規格棚卸し: 本文1–41章と附属書A–Q、計 {stats['sections']} 見出し。") + 1
        lines[position:position] = [
            f"- 全資料の確認・要求抽出: {source_audit['audited']}/{source_audit['sections_total']} 節 "
            f"({source_audit['source_review_percent']:.2f}%)、"
            f"{source_audit['classified_blocks']}/{source_audit['blocks_total']} 出典ブロックを分類済み。",
            f"- 規定部分の資料確認: {source_audit['normative_reviewed']}/{stats['normative_sections']} 節 "
            f"({source_audit['normative_source_review_percent']:.2f}%)。",
            f"- 解釈保留: {source_audit['interpretation_issues']} 論点、"
            f"{len(source_audit['interpretation_sections'])} 節、"
            f"{source_audit['interpretation_issue_rows']} 登録行。保留を完了・テスト対応済みに数えません。",
        ]
    if not runs["snapshots"]:
        lines.append("採用可能な実行証跡なし。")
    for s in runs["snapshots"]:
        lines.append(f"- `{s['file']}`: {s['version']} / {s['generated_at']} / "
                     f"{len(s['executed'])}/{total} 動作確認、古い入力との対応 {s['stale_links']} 件。")
    for reason in ignored:
        lines.append(f"- 不採用: {reason}。")
    lines += ["", "## 章・附属書別の調査状態", "",
              "件数は見出しごとの本文の調査状態です。動作数とは異なります。", ""]
    for root in sorted((n for n in sections if "." not in n), key=section_key):
        group = [s for n, s in sections.items() if n == root or n.startswith(root + ".")]
        norm = [s for s in group if s["kind"] == "normative"]
        done = sum(s["review"] in ("complete", "no_behavior") for s in norm)
        rs = [r for r in rows if r["clause"].split(".")[0] == root]
        state = f"解釈保留なし {done}/{len(norm)}" if norm else "参考（規範要件の分母に含めない）"
        lines.append(f"- {root} {sections[root]['title']}: {state}、"
                     f"登録 {len(rs)}、テスト対応 {sum(r['mapped'] for r in rs)}。")
    lines += ["", "## 登録済み動作と観測点", "",
              "`coverage/behaviors.json` には条件・合格基準・根拠・入力ハッシュも記録します。",
              "以下の対応は内容を確認したものだけです。引用だけがあるテストは候補として扱います。", ""]
    lines += ["未対応は台帳上の対応未確認を意味し、既存テストが一切ないという判定ではありません。", ""]
    executed = set(runs["executed"])
    for r in sorted(rows, key=lambda r: (section_key(r["clause"]), r["id"])):
        state = "実行確認あり" if r["id"] in executed else "テスト対応あり・実行未確認" if r["mapped"] else "テスト未対応"
        lines += [f"### {r['id']}", "", f"{r['clause']} / {r['kind']} / {state}", "",
                  r["behavior"], "", f"合格基準: {r['acceptance']}", ""]
        if r.get("modality"):
            lines += [f"規定の性質: `{r['modality']}`。", ""]
        if r.get("interpretation_issue"):
            lines += [f"未解決の解釈: `{r['interpretation_issue']}`（対応承認・節完了を保留）。", ""]
        for c in r["checks"]:
            lines.append(f"- [{Path(c['test']).name}]({link(c['test'])}): {c['observation']}")
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    modes = ap.add_mutually_exclusive_group()
    modes.add_argument("--update", action="store_true")
    modes.add_argument("--check", action="store_true")
    ap.add_argument("--results", type=Path, nargs="+", help="replace the saved execution snapshots")
    ap.add_argument("--output", type=Path, default=REPORT)
    ap.add_argument("--source-url", help="repository blob URL for links in an exported report")
    ap.add_argument("--json", type=Path, help="also write a machine-readable summary")
    ap.add_argument("--history", type=Path, help="append counts and denominator identities to history")
    ap.add_argument("--require-complete", action="store_true",
                    help="require an audited whole-standard denominator and all behaviors mapped/executed")
    ap.add_argument("--require-source-reviewed", action="store_true",
                    help="require classified source blocks for every section; does not approve interpretations or tests")
    ap.add_argument("--verify-source", type=Path, help="verify supplied PDF and extracted-text SHA-256")
    ap.add_argument("--test-digest", type=Path, help="print a test fingerprint after manual review")
    ap.add_argument("--candidates", help="list exact-citation test candidates for a section")
    ap.add_argument("--write-baseline", action="store_true")
    ap.add_argument("--reason", help="reason for an intentional baseline change")
    args = ap.parse_args()
    if args.test_digest:
        print(suite_results.input_digest(args.test_digest))
        return 0
    try:
        inventory = json.loads((DATA / "standard-sections.json").read_text())
        registry = json.loads((DATA / "behaviors.json").read_text())
        sections, rows = validate(inventory, registry)
        import requirement_audit
        audit_stats = requirement_audit.load_and_validate(DATA, inventory, registry)
        if args.candidates:
            require(args.candidates in sections, f"unknown section {args.candidates}")
            candidates = [{"test": t.relative_to(ROOT).as_posix(),
                           "description": suite_results.header(t).get("description", "")}
                          for t in suite_results.find_tests()
                          if args.candidates in suite_results.header(t).get("lrm", "").split()[1:]]
            print(json.dumps(candidates, ensure_ascii=False, indent=2))
            return 0
        current = baseline(sections, rows, inventory["source"])
        current["source_index_sha256"] = audit_stats["source_index_sha256"]
        current["source_reviewed_sections"] = sorted(
            json.loads((DATA / "requirement-audit.json").read_text())["sections"], key=section_key)
        if args.write_baseline:
            require(bool(args.reason and args.reason.strip()), "--write-baseline requires --reason")
            current["reason"] = args.reason
            (DATA / "behavior-baseline.json").write_text(
                json.dumps(current, ensure_ascii=False, indent=2) + "\n")
        else:
            previous = json.loads((DATA / "behavior-baseline.json").read_text())
            check_baseline(previous, current)
            growth = any(previous.get(k) != value for k, value in current.items())
            if growth and args.update:
                (DATA / "behavior-baseline.json").write_text(json.dumps(
                    {**current, "reason": "Monotonic additions of requirements, mappings or "
                     "completed investigations, recorded by --update"},
                    ensure_ascii=False, indent=2) + "\n")
            if args.check:
                require(not growth, "baseline does not yet lock new coverage; run --update")
        if args.verify_source:
            source = inventory["source"]
            pdf = args.verify_source / source["pdf"]
            require(hashlib.sha256(pdf.read_bytes()).hexdigest() == source["pdf_sha256"],
                    "the PDF differs from the inventoried standard")
            source_index = json.loads((DATA / "requirement-source-index.json").read_text())
            layout = args.verify_source / "out/lrm_pdftotext_layout.txt"
            require(hashlib.sha256(layout.read_bytes()).hexdigest() == source_index["text_sha256"],
                    "the extracted text differs from the audited standard")
        runs, ignored = execution(rows, args.results if args.results is not None
                                  else list((DATA / "results").glob("*.json")))
        denominator_reviewed = registry.get("denominator_review", {}).get("state") == "approved"
        text = report(inventory, sections, rows, runs, ignored, args.source_url, audit_stats,
                      denominator_reviewed)
        stats = summarize(sections, rows, runs, denominator_reviewed)
        snapshot = {"schema": 1, "generated_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
                    "inventory_sha256": current["inventory_sha256"],
                    "registry_sha256": hashlib.sha256((DATA / "behaviors.json").read_bytes()).hexdigest(),
                    "source_url": args.source_url,
                    "source_audit": audit_stats,
                    **stats, "execution": runs, "ignored_results": ignored}
        if args.json:
            args.json.parent.mkdir(parents=True, exist_ok=True)
            args.json.write_text(json.dumps({**snapshot,
                                             "requirements": [{"id": r["id"],
                                                               "mapped": r["mapped"],
                                                               "executed": r["id"] in runs["executed"]}
                                                              for r in rows]},
                                            ensure_ascii=False, indent=2) + "\n")
        if args.check:
            require(args.output.is_file() and args.output.read_text() == text,
                    f"stale report: run python3 tools/behavior_coverage.py --update")
        elif args.update or args.output != REPORT:
            args.output.parent.mkdir(parents=True, exist_ok=True)
            args.output.write_text(text)
            print(f"wrote {args.output}")
        else:
            print(text, end="")
        if args.require_complete:
            require(stats["whole_standard_percent"] == stats["whole_standard_executed_percent"] == 100,
                    "whole-standard denominator is incomplete or behaviors lack tests/fresh passes")
        if args.require_source_reviewed:
            require(audit_stats["source_review_complete"],
                    "some sections lack a complete source-block classification")
        if args.history:
            append_history(args.history, snapshot)
    except (InvalidCoverage, KeyError, TypeError, OSError, ValueError) as exc:
        print(f"behavior coverage: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
