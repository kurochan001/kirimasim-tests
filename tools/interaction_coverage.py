#!/usr/bin/env python3
"""Check constrained interaction plans and fingerprinted execution evidence.

--update / --check maintain the committed JSON and Markdown reports.
--list-tests emits the focused selection, leaving the full suite unchanged.
--results RUN.json ... evaluates each run separately; --require-pass gates
every supplied run on the selected models, including mandatory witnesses.
"""

import argparse
from collections import Counter
import datetime
import hashlib
import json
from pathlib import Path
import sys

import suite_results

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "generators"))
import common  # noqa: E402
import interaction_models  # noqa: E402

DATA = ROOT / "coverage" / "interaction-summary.json"
REPORT = ROOT / "docs" / "interaction-coverage.md"
RESULTS = ROOT / "coverage" / "interaction-results"
SIMULATORS = {"icarus", "verilator", "kirimasim", "lyra", "ghost"}
STATES = ("pass", "fail", "known", "unsupported", "stale", "not_run")


def source_digest() -> str:
    digest = hashlib.sha256()
    names = {"generators/interaction_cover.py", "generators/interaction_models.py",
             "generators/common.py", "tools/interaction_coverage.py"}
    names.update(Path(g.__file__).resolve().relative_to(ROOT).as_posix()
                 for g in interaction_models.GENERATORS)
    for name in sorted(names):
        digest.update(name.encode() + b"\0")
        digest.update((ROOT / name).read_bytes())
    return digest.hexdigest()


def validate_files() -> None:
    for path, expected in common.outputs(interaction_models.GENERATORS).items():
        if not path.is_file() or path.read_text() != expected:
            raise ValueError(f"generated witness is stale: {path.relative_to(ROOT)}")


def run_problem(run: dict) -> str:
    if not isinstance(run, dict):
        raise ValueError("execution snapshot must be an object")
    sim = run.get("simulator")
    if sim not in SIMULATORS or not isinstance(run.get("tests"), dict):
        raise ValueError("execution snapshot needs a supported simulator and tests object")
    if not isinstance(run.get("version"), str) or not run["version"]:
        return "missing simulator version"
    try:
        date = datetime.datetime.fromisoformat(run.get("generated_at", "").replace("Z", "+00:00"))
        if date.tzinfo is None:
            return "execution time has no timezone"
    except (ValueError, TypeError, AttributeError):
        return "missing or invalid execution time"
    if run.get("runner_changed") is not False:
        return "runner stability was not confirmed"
    if run.get("runner_sha256") != suite_results.runner_digest(sim):
        return "runner fingerprint differs"
    return ""


def outcome(run: dict, path: str, digest: str, problem: str) -> str:
    record = run["tests"].get(suite_results.test_id(ROOT / path))
    if record is None:
        return "not_run"
    if (problem or not isinstance(record, dict) or record.get("inputs_changed")
            or record.get("inputs_sha256") != digest):
        return "stale"
    status = record.get("status")
    return status if status in STATES[:4] else "stale"


def evaluate(plan, run: dict, digests: dict[str, str]) -> dict:
    problem = run_problem(run)
    states = {row: outcome(run, plan.path(row), digests[plan.path(row)], problem)
              for row in plan.available}
    passed = {t for row, status in states.items() if status == "pass"
              for t in plan.model.targets(row)}
    universe = plan.model.universe()
    strengths = {}
    for strength in sorted({len(t) for t in universe}):
        targets = {t for t in universe if len(t) == strength}
        strengths[str(strength)] = {"passed": len(targets & passed), "total": len(targets),
                                   "missing": len(targets - passed)}
    anchors = {plan.path(row): states.get(row, "not_run") for row in plan.model.anchors}
    counts = {s: 0 for s in STATES}
    counts.update(Counter(states.values()))
    return {"case_statuses": counts, "coverage": strengths,
            "mandatory_witnesses": anchors, "provenance_problem": problem,
            "complete": universe <= passed and all(s == "pass" for s in anchors.values())}


def build(plans, paths: list[Path]) -> dict:
    validate_files()
    models = []
    digests = {plan.path(row): suite_results.input_digest(ROOT / plan.path(row))
               for plan in plans for row in plan.available}
    for plan in plans:
        model = plan.model
        selected = model.select()
        targets = model.universe()
        planned = {t for row in selected for t in model.targets(row)}
        if planned != targets or not set(model.anchors) <= set(selected):
            raise ValueError("selection lost a required interaction or witness")
        models.append({"id": model.name, "version": model.version,
                       "factors": {n: list(v) for n, v in model.factors},
                       "constraints": list(model.constraints),
                       "higher_strength_groups": [list(g) for g in model.groups],
                       "witness": plan.witness, "legal_rows": len(model.rows()),
                       "available_cases": len(plan.available), "selected_cases": len(selected),
                       "targets_by_strength": dict(sorted(Counter(str(len(t)) for t in targets).items())),
                       "mandatory_witnesses": [plan.path(r) for r in model.anchors],
                       "selection": [{"test": plan.path(row), "values": model.values(row),
                                      "inputs_sha256": digests[plan.path(row)]}
                                     for row in selected]})
    runs = []
    for path in sorted(paths):
        run = json.loads(path.read_text())
        run_problem(run)  # Validate the envelope before reading its metadata.
        source = path.resolve().relative_to(ROOT).as_posix() if path.resolve().is_relative_to(ROOT) \
            else path.name
        runs.append({"source": source, "simulator": run.get("simulator"),
                     "version": run.get("version"), "generated_at": run.get("generated_at"),
                     "models": {plan.model.name: evaluate(plan, run, digests) for plan in plans}})
    return {"schema": 1, "source_sha256": source_digest(), "models": models, "runs": runs}


def markdown(data: dict, source_url: str | None = None) -> str:
    guide = source_url.rstrip("/") + "/docs/interaction-verification.md" if source_url \
        else "interaction-verification.md"
    lines = ["# 機能間クロスの計画と実行確認", "",
             "このレポートは登録した有限モデルだけを対象にします。要求カバレッジや全言語の",
             "組合せ網羅率ではありません。計画上の網羅と、実行結果に基づく合格確認を分けます。",
             "既存テストは削減していません。選択数の削減率は実行時間の削減率ではありません。", "",
             f"生成元・利用手順・適用限界は[導入手順]({guide})を参照してください。", ""]
    for model in data["models"]:
        lines += [f"## {model['id']} / model {model['version']}", "",
                  f"- 制約を満たす組合せ数: {model['legal_rows']}。",
                  f"- 利用できる既存・新規テスト: {model['available_cases']}。",
                  f"- 短時間実行の選択: {model['selected_cases']}。",
                  f"- 個別に保持する必須ケース: {len(model['mandatory_witnesses'])}。"]
        for strength, total in model["targets_by_strength"].items():
            lines.append(f"- {strength}因子の計画上の網羅: {total}/{total}。")
        lines += ["", model["witness"], ""]
        for name, values in model["factors"].items():
            lines.append(f"- {name}: {', '.join(values)}。")
        lines += ["", "制約: " + "; ".join(model["constraints"]), ""]
    lines += ["## 入力指紋が一致した実行の確認", "",
              "各スナップショットを独立に評価します。複数の版・実行の部分成功を合成しません。",
              "passだけを合格の証跡とし、known・unsupported・staleを合格へ含めません。",
              "この集計は期待値との一致を確認した組合せの割合です。失敗実行からの生の到達率は未計測です。", ""]
    if not data["runs"]:
        lines += ["実行証跡は未登録です。計画上の100%を実行確認と読み替えません。", ""]
    for run in data["runs"]:
        lines += [f"### {run['source']}", "", f"- 環境: {run['version']}。",
                  f"- 実行日時: {run['generated_at']}。", ""]
        for name, result in run["models"].items():
            lines.append(f"- {name}:")
            for strength, c in result["coverage"].items():
                lines.append(f"  - {strength}因子の合格確認済み組合せ: {c['passed']}/{c['total']}。")
            a = result["mandatory_witnesses"]
            lines.append(f"  - 必須ケース: {sum(s == 'pass' for s in a.values())}/{len(a)}。"
                         if a else "  - 個別の必須ケース: 対象なし。")
            lines.append("  - ケース状態: " + ", ".join(f"{s}={n}" for s, n in
                                                        result["case_statuses"].items()) + "。")
            if result["provenance_problem"]:
                lines.append("  - 証跡の問題: " + result["provenance_problem"] + "。")
        lines.append("")
    return "\n".join(lines)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    mode = ap.add_mutually_exclusive_group()
    mode.add_argument("--update", action="store_true")
    mode.add_argument("--check", action="store_true")
    mode.add_argument("--list-tests", action="store_true")
    ap.add_argument("--model", action="append", choices=[p.model.name for p in interaction_models.registered()])
    ap.add_argument("--results", nargs="+", type=Path)
    ap.add_argument("--output", type=Path, help="Markdown output for an explicit execution report")
    ap.add_argument("--json", type=Path, help="JSON output for an explicit execution report")
    ap.add_argument("--source-url", help="repository blob URL for an exported guide link")
    ap.add_argument("--require-pass", action="store_true")
    args = ap.parse_args()
    plans = tuple(p for p in interaction_models.registered()
                  if not args.model or p.model.name in args.model)
    if args.list_tests:
        if args.results or args.require_pass or args.output or args.json or args.source_url:
            ap.error("--list-tests only selects paths; it does not evaluate executions")
        for path in sorted({p.path(row) for p in plans for row in p.model.select()}):
            print(path)
        return 0
    if (args.check or args.update) and (args.results or args.model or args.output or args.json
                                      or args.source_url):
        ap.error("committed reports always use all models and coverage/interaction-results")
    try:
        paths = args.results if args.results is not None else sorted(RESULTS.glob("*.json"))
        data = build(plans, paths)
        rendered = markdown(data, args.source_url)
        encoded = json.dumps(data, ensure_ascii=False, indent=2) + "\n"
        if args.check:
            if not DATA.is_file() or DATA.read_text() != encoded or not REPORT.is_file() \
                    or REPORT.read_text() != rendered:
                raise ValueError("interaction reports are stale; run --update")
            print("Interaction models, selected witnesses and execution reports are current.")
        elif args.update:
            DATA.write_text(encoded)
            REPORT.write_text(rendered)
        else:
            if args.output:
                args.output.parent.mkdir(parents=True, exist_ok=True)
                args.output.write_text(rendered)
            else:
                print(rendered, end="")
            if args.json:
                args.json.parent.mkdir(parents=True, exist_ok=True)
                args.json.write_text(encoded)
        if args.require_pass and (not data["runs"] or
                any(not m["complete"] for r in data["runs"] for m in r["models"].values())):
            return 1
        return 0
    except (ValueError, KeyError, TypeError, OSError) as exc:
        print(f"interaction coverage: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
