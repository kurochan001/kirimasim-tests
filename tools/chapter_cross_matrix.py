#!/usr/bin/env python3
"""Export reviewed chapter pairs as Excel-readable CSVs without running simulators.

The mapping is an explicit review of each model's purpose, not a Cartesian
product of all chapter citations in a test header. --check detects stale exports.
"""

import argparse
from collections import Counter
import csv
import datetime
import io
import json
from pathlib import Path
import re
import sys

import interaction_coverage
import suite_results
from suite_stats import CHAPTERS_JA

ROOT = Path(__file__).resolve().parent.parent
REGISTRY = "coverage/chapter-interactions.json"
SUMMARY = "coverage/interaction-summary.json"
CHAPTERS = {1: "概要", 2: "引用規格", **CHAPTERS_JA, 41: "データ読出しAPI"}
OUTPUTS = ("coverage/chapter-cross-models.csv", "coverage/chapter-cross-passed-models.csv",
           "coverage/chapter-cross-details.csv")


def reviewed_pairs(summary: dict, registry: dict) -> list[dict]:
    """Validate a complete review and expand each model to distinct chapter pairs."""
    if registry.get("schema") != 1 or not registry.get("reviewer") or not registry.get("reviewed_on"):
        raise ValueError("chapter mapping needs schema 1 and review provenance")
    models = {m["id"]: m for m in summary["models"]}
    entries = registry["models"]
    ids = [e["id"] for e in entries]
    if len(ids) != len(set(ids)) or set(ids) != set(models):
        raise ValueError("chapter mapping must review every current model exactly once")
    rows = []
    for entry in entries:
        model = models[entry["id"]]
        primary = entry["primary_chapter"]
        if primary not in CHAPTERS:
            raise ValueError(f"invalid primary chapter: {entry['id']}")
        if any(p["chapters"][0] == p["chapters"][1] for p in entry["pairs"]):
            raise ValueError(f"diagonal is reserved for the primary chapter: {entry['id']}")
        pairs = [{"chapters": [primary, primary], "reason": "主題章のモデル", "when": {}},
                 *entry["pairs"]]
        seen = set()
        for pair in pairs:
            chapters = pair["chapters"]
            if (len(chapters) != 2 or any(c not in CHAPTERS for c in chapters)
                    or not pair.get("reason")):
                raise ValueError(f"invalid chapter pair: {entry['id']}")
            key = tuple(sorted(chapters))
            if key in seen:
                raise ValueError(f"duplicate chapter pair: {entry['id']} {key}")
            seen.add(key)
            conditions = pair.get("when", {})
            for factor, levels in conditions.items():
                if (factor not in model["factors"] or not isinstance(levels, list) or not levels
                        or not set(levels) <= set(model["factors"][factor])):
                    raise ValueError(f"invalid factor filter: {entry['id']} {factor}")
            matches = [s for s in model["selection"]
                       if all(s["values"][k] in v for k, v in conditions.items())]
            if not matches:
                raise ValueError(f"chapter pair has no selected witness: {entry['id']} {key}")
            rows.append({"chapters": key, "model": model, "reason": pair["reason"],
                         "when": conditions, "matches": matches})
    return rows


def validate_inputs(summary: dict, root: Path) -> None:
    for model in summary["models"]:
        if not model["selection"] or len(model["selection"]) != model["selected_cases"]:
            raise ValueError(f"selection count differs: {model['id']}")
        paths = set()
        for case in model["selection"]:
            path = case["test"]
            if path in paths:
                raise ValueError(f"duplicate selected input: {path}")
            paths.add(path)
            if suite_results.input_digest(root / path) != case["inputs_sha256"]:
                raise ValueError(f"stale selected input: {path}; refresh interaction evidence first")


def latest_run(summary: dict, root: Path) -> tuple[str, dict, dict]:
    """Use one stable, current-input kirimasim snapshot covering the whole selection.

    Unsupported/fail are valid observations. Missing/stale records disqualify a
    snapshot. Partial runs are never combined to manufacture a complete run.
    """
    candidates = []
    for saved in summary["runs"]:
        if saved["simulator"] != "kirimasim":
            continue
        run = json.loads((root / saved["source"]).read_text(encoding="utf-8"))
        if run.get("simulator") != "kirimasim" or interaction_coverage.run_problem(run):
            continue
        date = datetime.datetime.fromisoformat(run["generated_at"].replace("Z", "+00:00"))
        candidates.append((date, saved["source"], run))
    for _, source, run in sorted(candidates, key=lambda c: (c[0], c[1]), reverse=True):
        statuses = {}
        for model in summary["models"]:
            statuses[model["id"]] = {
                case["test"]: interaction_coverage.outcome(run, case["test"], case["inputs_sha256"], "")
                for case in model["selection"]}
        if all(s in ("pass", "fail", "known", "unsupported")
               for cases in statuses.values() for s in cases.values()):
            return source, run, statuses
    raise ValueError("no current, stable kirimasim snapshot contains the complete selection")


def matrix(rows: list[dict], passed: set[str] | None = None) -> list[list]:
    counts = Counter(row["chapters"] for row in rows
                     if passed is None or row["model"]["id"] in passed)
    return [["章番号", "章名", *CHAPTERS],
            *[[a, name, *[counts[tuple(sorted((a, b)))] for b in CHAPTERS]]
              for a, name in CHAPTERS.items()]]


def csv_bytes(rows: list[list]) -> bytes:
    stream = io.StringIO(newline="")
    csv.writer(stream, lineterminator="\n").writerows(rows)
    return stream.getvalue().encode("utf-8-sig")


def build(root: Path = ROOT) -> tuple[dict[str, bytes], dict]:
    summary = json.loads((root / SUMMARY).read_text(encoding="utf-8"))
    if summary["source_sha256"] != interaction_coverage.source_digest():
        raise ValueError("interaction summary is stale; run interaction_coverage.py --update first")
    registry = json.loads((root / REGISTRY).read_text(encoding="utf-8"))
    rows = reviewed_pairs(summary, registry)
    validate_inputs(summary, root)
    for row in rows:
        if row["chapters"][0] != row["chapters"][1]:
            continue
        for case in row["matches"]:
            lrm = suite_results.header(root / case["test"]).get("lrm", "")
            primary = re.match(r"1800-2023\s+(\d+)", lrm)
            if not primary or int(primary[1]) != row["chapters"][0]:
                raise ValueError(f"primary chapter differs: {case['test']}")
    source, run, statuses = latest_run(summary, root)
    passed = {m for m, cases in statuses.items() if all(s == "pass" for s in cases.values())}
    details = [["章A", "章A名", "章B", "章B名", "区分", "モデルID", "対応根拠", "該当条件",
                "該当選択ケース数", "該当pass", "該当fail", "該当known", "該当unsupported",
                "モデル選択ケース数", "モデル全選択ケースpass", "モデルの観測目的",
                "代表テスト", "代表テストの規格条項", "代表期待値", "実行結果JSON",
                "シミュレータ", "版", "実行日時", "対応付けレビュー日", "対応付けレビュー者"]]
    for row in sorted(rows, key=lambda r: (*r["chapters"], r["model"]["id"])):
        a, b = row["chapters"]
        model = row["model"]
        sample = root / row["matches"][0]["test"]
        fields = suite_results.header(sample)
        counts = Counter(statuses[model["id"]][c["test"]] for c in row["matches"])
        expectation = fields.get("expected_stdout", "")
        if expectation.startswith("@"):
            expectation = (sample.parent / expectation[1:]).relative_to(root).as_posix()
        details.append([a, CHAPTERS[a], b, CHAPTERS[b], "主題章" if a == b else "章間クロス",
                        model["id"], row["reason"],
                        json.dumps(row["when"], ensure_ascii=False, sort_keys=True),
                        len(row["matches"]), *[counts[s] for s in ("pass", "fail", "known", "unsupported")],
                        model["selected_cases"], int(model["id"] in passed), model["witness"],
                        sample.relative_to(root).as_posix(), fields.get("lrm", ""), expectation,
                        source, run["simulator"], run["version"], run["generated_at"],
                        registry["reviewed_on"], registry["reviewer"]])
    outputs = dict(zip(OUTPUTS, map(csv_bytes, (matrix(rows), matrix(rows, passed), details))))
    stats = {"models": len(summary["models"]), "selected_cases": sum(
        m["selected_cases"] for m in summary["models"]), "all_pass_models": len(passed),
        "chapter_pairs": len({r["chapters"] for r in rows if r["chapters"][0] != r["chapters"][1]}),
        "source": source, "statuses": dict(Counter(s for cases in statuses.values() for s in cases.values()))}
    return outputs, stats


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--update", action="store_true", help="rewrite the three committed CSV files")
    mode.add_argument("--check", action="store_true", help="reject missing or out-of-date CSV files")
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
            print("stale chapter CSVs: " + ", ".join(stale)
                  + "; run python3 tools/chapter_cross_matrix.py --update", file=sys.stderr)
            return 1
    except (ValueError, KeyError, OSError) as error:
        print(f"chapter matrix: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
