#!/usr/bin/env python3
"""Validate reviewed gap-to-test bindings and per-run execution evidence.

--update/--check maintain a regression-adoption report, not a claim that the
implementation supports every case. Bindings never refresh their hashes
automatically: changed observations must be reviewed before changing them.
"""

import argparse
import hashlib
import json
from pathlib import Path

import interaction_coverage
import suite_results

ROOT = Path(__file__).resolve().parent.parent
REGISTRY = ROOT / "coverage/combination-gaps.json"
RESULTS = ROOT / "coverage/combination-results"
SUMMARY = ROOT / "coverage/combination-gap-summary.json"
REPORT = ROOT / "docs/p1-combination-regressions-20261030.md"
IDS = tuple([f"E{i:02d}" for i in range(1, 7)]
            + [f"N{i:02d}" for i in range(1, 5)]
            + [f"A{i:02d}" for i in range(1, 5)]
            + ["S01", "S02", "F01", "F02", "H01", "U01"])
STATES = ("pass", "fail", "known", "unsupported", "stale", "not_run")


def require(condition, message):
    if not condition:
        raise ValueError(message)


def validate(data: dict, root: Path = ROOT) -> dict[str, str]:
    require(data.get("schema") == 1, "unsupported registry schema")
    items = data.get("items", [])
    require(len(items) == len(IDS) and {i.get("id") for i in items} == set(IDS),
            "registry must contain each of the twenty candidate IDs exactly once")
    require(data.get("reviewer") and data.get("reviewed_on") and data.get("scope"),
            "registry requires reviewer, date and scope")
    digests = {}
    new_observations = set()
    for item in items:
        identifier = item["id"]
        require(item.get("title") and item.get("spec_review") and item.get("limitations") is not None,
                f"{identifier}: incomplete review")
        bindings = item.get("bindings", [])
        require(bindings and any(b.get("role") == "primary" for b in bindings),
                f"{identifier}: no primary observation")
        seen = set()
        for binding in bindings:
            name = binding.get("test", "")
            path = root / name
            require(name.startswith("tests/") and Path(name).as_posix() == name
                    and ".." not in Path(name).parts
                    and name not in seen and path.suffix == ".sv" and path.is_file()
                    and path.resolve().is_relative_to((root / "tests").resolve())
                    and path.resolve().relative_to(root.resolve()).as_posix() == name,
                    f"{identifier}: invalid or duplicate test {name}")
            seen.add(name)
            require(binding.get("role") in ("primary", "contrast")
                    and binding.get("basis") in ("new", "reused")
                    and binding.get("observations"), f"{identifier}: incomplete binding {name}")
            fields = suite_results.header(path)
            require(fields.get("spec_check") in ("ai", "human"), f"unreviewed test {name}")
            clauses = fields.get("lrm", "").split()[1:]
            require(binding.get("lrm") and set(binding["lrm"]) <= set(clauses),
                    f"{identifier}: citation not present in {name}")
            if binding["basis"] == "new":
                require(fields.get("combination_gap") == identifier,
                        f"{identifier}: generated metadata differs in {name}")
                require(binding["role"] == "primary",
                        f"{identifier}: new observation must be primary in {name}")
                new_observations.add((identifier, name))
            digest = suite_results.input_digest(path)
            require(binding.get("inputs_sha256") == digest,
                    f"{identifier}: stale binding {name}; review changed inputs")
            digests[name] = digest
    for path in sorted((root / "tests").rglob("*.sv")):
        identifier = suite_results.header(path).get("combination_gap")
        if identifier is None:
            continue
        name = path.relative_to(root).as_posix()
        require(identifier in IDS, f"unknown combination_gap {identifier} in {name}")
        require((identifier, name) in new_observations,
                f"{identifier}: unregistered new observation {name}")
    return digests


def snapshot(data: dict, run: dict, digests: dict[str, str]) -> dict:
    problem = interaction_coverage.run_problem(run)
    def status(name):
        record = run["tests"].get(suite_results.test_id(ROOT / name))
        if record is None:
            return "not_run"
        if (problem or not isinstance(record, dict) or record.get("inputs_changed")
                or record.get("inputs_sha256") != digests[name]):
            return "stale"
        return record.get("status") if record.get("status") in STATES[:4] else "stale"
    statuses = {name: status(name) for name in digests}
    groups = {}
    for item in data["items"]:
        names = [b["test"] for b in item["bindings"] if b["role"] == "primary"]
        groups[item["id"]] = {
            "statuses": {s: sum(statuses[n] == s for n in names) for s in STATES},
            "complete": all(statuses[n] == "pass" for n in names),
        }
    return {"simulator": run["simulator"], "version": run.get("version", "not confirmed"),
            "generated_at": run.get("generated_at", ""), "provenance_problem": problem,
            "statuses": {s: sum(v == s for v in statuses.values()) for s in STATES},
            "groups": groups}


def build() -> tuple[dict, dict]:
    data = json.loads(REGISTRY.read_text())
    digests = validate(data)
    runs = []
    for path in sorted(RESULTS.glob("*.json")):
        run = snapshot(data, json.loads(path.read_text()), digests)
        run["source"] = path.relative_to(ROOT).as_posix()
        runs.append(run)
    summary = {"schema": 1, "registry_sha256": hashlib.sha256(REGISTRY.read_bytes()).hexdigest(),
               "candidate_count": len(data["items"]), "test_count": len(digests),
               "new_tests": len({b["test"] for i in data["items"] for b in i["bindings"]
                                 if b["basis"] == "new"}), "runs": runs}
    return data, summary


def markdown(data: dict, summary: dict) -> str:
    lines = ["# Issue #21：組合せ境界の回帰取り込み", "",
             "[追跡Issue](https://github.com/kurochan001/kirimasim-tests/issues/21) / "
             "[元の観測記録](p1-combination-gaps-20261030.md) / "
             "[照合台帳](../coverage/combination-gaps.json)", "",
             data["scope"], "", f"- 確認者: {data['reviewer']}。確認日: {data['reviewed_on']}。",
             f"- 候補{summary['candidate_count']}項目、重複を除く対象{summary['test_count']}件。"
             f"新規{summary['new_tests']}件、残りは既存テストを再利用。",
             "- 登録・規格確認が済んだことと、実装が合格したことを分けます。"
             "unsupported・known・未実行は合格に含めません。",
             "- 各実行の入力・期待値・ランナー指紋を照合し、異なる実行の部分成功は合成しません。",
             "- 保留した解釈と範囲外のAPIは下記に残し、実装不足や成功へ読み替えません。", ""]
    lines += ["- 最新版確認時のコミットとビルド前後のバイナリ指紋は"
              "[ビルド証跡](../coverage/combination-qualification/issue21-build.json)に保存しています。"
              "これは実行開始時に確認した上流版であり、その後の更新への追従を自動保証しません。",
              "- VCD検査器は、正常・program欠落・moduleのみ・scope終端の過剰という"
              "[故障注入4条件](../coverage/combination-qualification/issue21-vcd-checker.json)でも"
              "判定を確認しています。", ""]
    for item in data["items"]:
        lines += [f"## {item['id']}：{item['title']}", "", item["spec_review"], ""]
        for binding in item["bindings"]:
            name = binding["test"]
            role = "主観測" if binding["role"] == "primary" else "対照"
            basis = "新規" if binding["basis"] == "new" else "既存再利用"
            lines += [f"- [{Path(name).stem}](../{name})（{role}・{basis}）。",
                      "  " + " / ".join(binding["observations"])
                      + "。条項: " + "、".join(binding["lrm"]) + "。"]
        lines += [""] + ["- 範囲・制限: " + note for note in item["limitations"]] + [""]
    lines += ["## 分離した解釈・API範囲", ""]
    for hold in data.get("classifications", []):
        lines += [f"- {hold['id']}：{hold['disposition']}。{hold['reason']}"]
    lines += ["", "## 現在の入力に対応する実行証跡", ""]
    for run in summary["runs"]:
        lines += [f"### {run['source']}", "", f"- 版: {run['version']}。",
                  f"- 実行日時: {run['generated_at']}。",
                  "- 対象全件: " + ", ".join(f"{s}={n}" for s, n in run["statuses"].items()) + "。"]
        if run["provenance_problem"]:
            lines.append("- 証跡の問題: " + run["provenance_problem"] + "。")
        for identifier, result in run["groups"].items():
            label = "主観測すべて合格" if result["complete"] else "主観測に未達あり"
            lines.append(f"- {identifier}: {label}。" + ", ".join(
                f"{s}={n}" for s, n in result["statuses"].items() if n) + "。")
        lines.append("")
    lines += ["## 再実行と更新", "",
              "台帳の指紋は自動で更新しません。刺激・観測・規格根拠を再確認してから変更してください。",
              "`--check`は台帳とレポートの整合性検査で、実装の全件合格を要求しません。", "",
              "```sh", "python3 tools/combination_gaps.py --list-tests",
              "python3 tools/combination_gaps.py --update",
              "python3 tools/combination_gaps.py --check", "```", "",
              "`--list-tests`の出力を既存ランナーのテスト引数へ渡し、`--json`で新しい結果を",
              "`coverage/combination-results/`へ保存してからレポートを更新します。",
              "kirimasimは実行直前の上流コミットを確認し、その版からビルドしてください。", ""]
    return "\n".join(lines)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    mode = ap.add_mutually_exclusive_group()
    mode.add_argument("--update", action="store_true")
    mode.add_argument("--check", action="store_true")
    mode.add_argument("--list-tests", action="store_true")
    args = ap.parse_args()
    try:
        if args.list_tests:
            data = json.loads(REGISTRY.read_text())
            for name in sorted(validate(data)):
                print(name)
            return 0
        data, summary = build()
        text = markdown(data, summary)
        encoded = json.dumps(summary, ensure_ascii=False, indent=2) + "\n"
        if args.update:
            SUMMARY.write_text(encoded)
            REPORT.write_text(text)
        elif args.check:
            require(SUMMARY.read_text() == encoded and REPORT.read_text() == text,
                    "combination gap reports are stale; run --update")
            print("Combination gap bindings and execution evidence are current.")
        else:
            print(text, end="")
        return 0
    except (ValueError, OSError, KeyError, TypeError) as error:
        print(f"combination gaps: {error}")
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
