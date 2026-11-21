#!/usr/bin/env python3
"""Draws a stratified random sample of tests for a person to check against the
standard, records the person's verdicts and bounds the error rate per stratum.

Usage:
    python3 tools/review_sample.py sample --results DIR --output DIR --seed N
        [--count STRATUM=N ...] [--default-count N] [--chapter N ...]
        [--language ja|en] [--source-url URL]
    python3 tools/review_sample.py record SHEET.json
    python3 tools/review_sample.py report [--chapter N ...] [--json FILE]
    python3 tools/review_sample.py check

DIR of --results holds latest/<simulator>.json of the results branch, the
files tools/review_candidates.py reads; icarus, verilator, kirimasim, lyra and
ghost are read and a missing file leaves that simulator out. A status counts
only when the run recorded the same input digest as the test has now, so a
test changed after the run is classified by the runs that saw it as it is.

Formal tests and tests without a current result are left out. A test has a
fixed-release oracle when :oracle: names iverilog@13.0, verilator@5.052 or
verilator@5.054. The other tests fall into these strata:

  pass_nowhere      passes on no simulator
  ghost_only        passes on Ghost and on no other simulator
  kirimasim_ghost   passes on kirimasim and Ghost and on no other simulator
  reference_pass    passes on Icarus Verilog, Verilator or Lyra (any of them)

A test outside them (one that passes on kirimasim alone, for example) is
counted but not drawn. Each stratum is drawn with its own random generator
seeded from the seed and the stratum name, over the sorted test names, so the
same seed and inputs give the same sample.

sample writes review-sample.json and review-sample.md to DIR: one entry per
test with its path, cited clauses, description, expectation, results and
input digest, and the empty fields verdict, basis_clauses, reviewer and date.
record reads such a JSON file after a person has filled it in and adds the
filled entries to coverage/human-review.json; it refuses an entry whose test
changed since the sample was drawn, an unknown verdict, a missing reviewer,
date or basis, and a reviewer marked as an AI. report counts, per stratum and
per sampling frame (the chapters a sample was drawn from), the tests n with a
current review and the tests k found wrong (expectation_wrong or test_defect
by any reviewer); a test only found contested is left out of n. It gives a
one-sided 95% upper bound on the error rate: 3/n when k is 0 (the rule of
three) and the Clopper-Pearson bound otherwise, never below 3/n. A review
whose test changed or was removed since it was recorded is stale and is left
out of n. check validates the ledger. Nothing here changes a test or its
:spec_check: field.

A run that stores bare statuses (latest/<simulator>.json) places a test only
when git shows no change to the test's input files since the run's
suite_commit.
"""

import argparse
import datetime
import json
import math
import random
import re
import subprocess
import sys
from pathlib import Path

import suite_results
import suite_stats

ROOT = Path(__file__).resolve().parent.parent
LEDGER = ROOT / "coverage" / "human-review.json"
SOURCE_URL = "https://github.com/kurochan001/kirimasim-tests/blob/main"
SIMULATORS = ("icarus", "verilator", "kirimasim", "lyra", "ghost")
REFERENCES = {"icarus", "verilator", "lyra"}
RELEASES = {"iverilog@13.0", *suite_stats.VERILATOR_ORACLES}
STRATA = ("pass_nowhere", "ghost_only", "kirimasim_ghost", "reference_pass")
VERDICTS = ("correct", "expectation_wrong", "test_defect", "contested")
ERRORS = {"expectation_wrong", "test_defect"}
CONFIDENCE = 0.95
LEDGER_NOTE = ("Verdicts of a person who checked tests drawn by tools/review_sample.py "
               "against IEEE 1800-2023. An entry is current while the test keeps the "
               "recorded input digest. This ledger does not change :spec_check:.")

TEXT = {
    "ja": {
        "title": "レビュー用シート", "intro": (
            "`tools/review_sample.py`が層別に無作為に選んだテストです。期待出力を規格から導き直し、"
            "判定・根拠条項・レビュー者・日付を記入してください。判定は`correct`（正しい）、"
            "`expectation_wrong`（期待値が誤り）、`test_defect`（テストに欠陥）、"
            "`contested`（読み方が割れる）のどれかです。記入したJSONを"
            "`python3 tools/review_sample.py record`で台帳に取り込みます。"),
        "inputs": "入力", "seed": "シード", "population": "層ごとの本数と抽出数",
        "stratum": "層", "size": "母集団", "drawn": "抽出", "test": "テスト", "clauses": "引用条項",
        "description": "説明", "expected": "期待出力", "illegal": "規格違反として拒否されること",
        "reason": "理由", "place": "エラーの位置", "exit": "終了コード", "args": "引数",
        "results": "結果", "digest": "入力の指紋", "verdict": "判定", "basis": "根拠条項",
        "reviewer": "レビュー者", "date": "日付", "notes": "メモ", "none": "（期待出力なし）",
        "per_sim": "シミュレータ別の期待出力",
    },
    "en": {
        "title": "Review sheet", "intro": (
            "Tests drawn at random per stratum by `tools/review_sample.py`. Derive the expected "
            "output again from the standard and fill in the verdict, the basis clauses, the "
            "reviewer and the date. The verdict is `correct`, `expectation_wrong`, `test_defect` "
            "or `contested` (the standard can be read both ways). Record the filled JSON file "
            "with `python3 tools/review_sample.py record`."),
        "inputs": "Inputs", "seed": "Seed", "population": "Strata and draws",
        "stratum": "Stratum", "size": "Population", "drawn": "Drawn", "test": "Test",
        "clauses": "Cited clauses", "description": "Description", "expected": "Expected output",
        "illegal": "Has to be rejected as illegal", "reason": "Reason", "place": "Place of the error",
        "exit": "Exit code", "args": "Arguments", "results": "Results", "digest": "Input digest",
        "verdict": "Verdict", "basis": "Basis clauses", "reviewer": "Reviewer", "date": "Date",
        "notes": "Notes", "none": "(no expected output)", "per_sim": "Expected output per simulator",
    },
}


def load_runs(directory: Path) -> dict[str, dict]:
    """latest/<simulator>.json: version, time, suite commit and, per test, the
    status and the input digest the run recorded."""
    runs = {}
    for sim in SIMULATORS:
        path = directory / f"{sim}.json"
        if not path.is_file():
            continue
        data = json.loads(path.read_text(encoding="utf-8"))
        tests = {}
        for name, record in data.get("tests", {}).items():
            if isinstance(record, dict):
                tests[name] = (record.get("status"), record.get("inputs_sha256"))
            else:
                tests[name] = (record, None)
        runs[sim] = {"version": data.get("version", ""),
                     "time": data.get("time") or data.get("generated_at", ""),
                     "suite_commit": data.get("suite_commit", ""), "tests": tests}
    return runs


def changed_since(root: Path, commit: str) -> set[str] | None:
    """Repository paths that differ between commit and the working tree, or
    None when git cannot tell (no commit given, or a shallow clone)."""
    if not commit:
        return None
    try:
        out = subprocess.run(["git", "-C", str(root), "diff", "--name-only", commit, "--"],
                             capture_output=True, text=True, check=True).stdout
    except (OSError, subprocess.CalledProcessError):
        return None
    return {line.strip() for line in out.splitlines() if line.strip()}


def chapter_of(test: str) -> str:
    match = re.search(r"(?:^|/)ch(\d+)/", test)
    return match.group(1) if match else ""


def classify(root: Path, runs: dict[str, dict], chapters: set[str] | None = None) -> dict:
    """The strata of the current tests and the counts of those left out."""
    found = {s: [] for s in STRATA}
    left = {"formal": 0, "fixed_release_oracle": 0, "no_current_result": 0, "other": 0}
    statuses = {}
    # A run that stores bare statuses (latest/<simulator>.json of the results
    # branch) has no input digest per test; its status counts only when no
    # input of the test changed after the suite commit of the run.
    changed = {sim: changed_since(root, run.get("suite_commit", "")) for sim, run in runs.items()}
    unchecked = sorted(sim for sim, paths in changed.items() if paths is None
                       and any(r is None for _, r in runs[sim]["tests"].values()))
    for sim in unchecked:
        print(f"review_sample: warning: cannot tell which tests changed after the run of {sim}; "
              "its statuses are used as they are", file=sys.stderr)
    for path in suite_results.find_tests(root):
        test = path.resolve().relative_to(root / "tests").with_suffix("").as_posix()
        if chapters and chapter_of(test) not in chapters:
            continue
        fields = suite_results.header(path)
        if fields.get("type", "").strip() == "formal":
            left["formal"] += 1
            continue
        if RELEASES & set(fields.get("oracle", "").split()):
            left["fixed_release_oracle"] += 1
            continue
        digest = suite_results.input_digest(path)
        inputs = None
        seen = {}
        for sim, run in runs.items():
            status, recorded = run["tests"].get(test, (None, None))
            if status is None:
                continue
            if recorded is None:
                if changed[sim] is not None:
                    if inputs is None:
                        inputs = {p.resolve().relative_to(root).as_posix()
                                  for p in suite_results.input_files(path)}
                    if inputs & changed[sim]:
                        continue
            elif recorded != digest:
                continue
            seen[sim] = status
        if not seen:
            left["no_current_result"] += 1
            continue
        statuses[test] = (seen, digest)
        passing = {sim for sim, status in seen.items() if status == "pass"}
        if passing & REFERENCES:
            found["reference_pass"].append(test)
        elif not passing:
            found["pass_nowhere"].append(test)
        elif passing == {"ghost"}:
            found["ghost_only"].append(test)
        elif passing == {"kirimasim", "ghost"}:
            found["kirimasim_ghost"].append(test)
        else:
            left["other"] += 1
    return {"strata": {s: sorted(v) for s, v in found.items()}, "left_out": left,
            "statuses": statuses}


def draw(strata: dict[str, list[str]], counts: dict[str, int], seed: int) -> dict[str, list[str]]:
    sample = {}
    for stratum in STRATA:
        population = sorted(strata.get(stratum, []))
        wanted = min(counts.get(stratum, 0), len(population))
        rng = random.Random(f"{seed}:{stratum}")
        sample[stratum] = sorted(rng.sample(population, wanted)) if wanted else []
    return sample


def entry(root: Path, test: str, stratum: str, seen: dict[str, str], digest: str) -> dict:
    path = root / "tests" / f"{test}.sv"
    if not path.is_file():
        path = path.with_suffix(".v")
    fields = suite_results.header(path)
    per_simulator = {}
    for sim in SIMULATORS:
        value = fields.get(f"expected_stdout_{sim}")
        if value is not None:
            per_simulator[sim] = suite_results.expected_output(path, sim)
    return {
        "test": test, "path": path.relative_to(root).as_posix(), "stratum": stratum,
        "clauses": fields.get("lrm", "").split()[1:], "description": fields.get("description", ""),
        "type": fields.get("type", ""), "oracle": fields.get("oracle", ""),
        "expected_stdout": suite_results.expected_output(path),
        "expected_stdout_per_simulator": per_simulator,
        "should_fail_because": fields.get("should_fail_because"),
        "expected_stderr_regex": fields.get("expected_stderr_regex"),
        "expected_exit": fields.get("expected_exit"), "args": fields.get("args"),
        "results": seen, "inputs_sha256": digest,
        "verdict": "", "basis_clauses": "", "reviewer": "", "date": "", "notes": "",
    }


def render(sheet: dict, language: str, source_url: str) -> str:
    t = TEXT[language]
    base = source_url.rstrip("/")
    lines = [f"# {t['title']}", "", t["intro"], "", f"## {t['inputs']}", "",
             f"- {t['seed']}: `{sheet['seed']}`"]
    for sim, run in sheet["results_read"].items():
        lines.append(f"- {sim}: `{run['version']}`, {run['time']}, `{run['suite_commit'][:8]}`")
    lines += ["", f"## {t['population']}", "", f"| {t['stratum']} | {t['size']} | {t['drawn']} |",
              "| --- | ---: | ---: |"]
    for stratum in STRATA:
        lines.append(f"| `{stratum}` | {sheet['population'][stratum]} | {sheet['drawn'][stratum]} |")
    for number, item in enumerate(sheet["tests"], 1):
        lines += ["", f"## {number}. `{item['test']}`", "",
                  f"- {t['stratum']}: `{item['stratum']}`",
                  f"- {t['test']}: [{item['path']}]({base}/{item['path']})",
                  f"- {t['clauses']}: {', '.join(item['clauses'])}",
                  f"- {t['description']}: {item['description']}",
                  f"- {t['results']}: " + ", ".join(f"{s} {v}" for s, v in sorted(item["results"].items())),
                  f"- {t['digest']}: `{item['inputs_sha256']}`"]
        if item["args"]:
            lines.append(f"- {t['args']}: `{item['args']}`")
        if item["expected_exit"]:
            lines.append(f"- {t['exit']}: `{item['expected_exit']}`")
        if item["should_fail_because"]:
            lines += [f"- {t['illegal']}", f"  - {t['reason']}: {item['should_fail_because']}",
                      f"  - {t['place']}: `{item['expected_stderr_regex']}`"]
        else:
            lines += ["", f"{t['expected']}:", "", "```text",
                      (item["expected_stdout"] or t["none"]).rstrip("\n"), "```"]
        for sim, text in item["expected_stdout_per_simulator"].items():
            lines += ["", f"{t['per_sim']} ({sim}):", "", "```text", (text or "").rstrip("\n"), "```"]
        lines += ["", f"- {t['verdict']}: ", f"- {t['basis']}: ", f"- {t['reviewer']}: ",
                  f"- {t['date']}: ", f"- {t['notes']}: "]
    return "\n".join(lines) + "\n"


def binomial_cdf(k: int, n: int, p: float) -> float:
    if p <= 0:
        return 1.0
    if p >= 1:
        return 0.0 if k < n else 1.0
    total = 0.0
    for i in range(k + 1):
        total += math.exp(math.lgamma(n + 1) - math.lgamma(i + 1) - math.lgamma(n - i + 1)
                          + i * math.log(p) + (n - i) * math.log1p(-p))
    return min(total, 1.0)


def upper_bound(k: int, n: int, confidence: float = CONFIDENCE) -> float | None:
    """One-sided upper bound on the error rate: the rule of three when no
    error was found, the Clopper-Pearson bound otherwise."""
    if n <= 0:
        return None
    rule_of_three = min(3.0 / n, 1.0)
    if k <= 0:
        return rule_of_three
    if k >= n:
        return 1.0
    alpha = 1.0 - confidence
    low, high = k / n, 1.0
    for _ in range(200):
        middle = (low + high) / 2
        if binomial_cdf(k, n, middle) > alpha:
            low = middle
        else:
            high = middle
    # For very small n the rule of three can exceed the exact bound with one
    # error; finding an error must never lower the bound.
    return max(high, rule_of_three)


def read_ledger(path: Path) -> dict:
    if not path.is_file():
        return {"schema": 1, "note": LEDGER_NOTE, "reviews": []}
    return json.loads(path.read_text(encoding="utf-8"))


def write_ledger(path: Path, ledger: dict) -> None:
    path.write_text(json.dumps(ledger, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def review_errors(review: dict, root: Path) -> list[str]:
    name = review.get("test", "?")
    errors = []
    if review.get("verdict") not in VERDICTS:
        errors.append(f"{name}: verdict must be one of {', '.join(VERDICTS)}")
    if review.get("stratum") not in STRATA:
        errors.append(f"{name}: unknown stratum {review.get('stratum')!r}")
    reviewer = str(review.get("reviewer", "")).strip()
    if not reviewer:
        errors.append(f"{name}: the reviewer is missing")
    elif re.search(r"\bAI\b", reviewer):
        errors.append(f"{name}: this ledger records reviews by a person, not by an AI")
    try:
        datetime.date.fromisoformat(str(review.get("date", "")))
    except ValueError:
        errors.append(f"{name}: the date must be YYYY-MM-DD")
    basis = review.get("basis_clauses")
    if not basis or not all(re.fullmatch(r"[0-9A-Z]+(\.[0-9]+)*", c) for c in basis):
        errors.append(f"{name}: basis_clauses must list clause numbers such as 13.4.4")
    if not re.fullmatch(r"[0-9a-f]{64}", str(review.get("inputs_sha256", ""))):
        errors.append(f"{name}: the input digest is missing")
    return errors


def record(sheet_path: Path, ledger_path: Path, root: Path) -> int:
    sheet = json.loads(sheet_path.read_text(encoding="utf-8"))
    ledger = read_ledger(ledger_path)
    reviews = ledger["reviews"]
    added = 0
    problems = []
    for item in sheet.get("tests", []):
        if not str(item.get("verdict", "")).strip():
            continue
        basis = item.get("basis_clauses", "")
        if isinstance(basis, str):
            basis = [c for c in re.split(r"[\s,、]+", basis) if c]
        review = {"test": item.get("test"), "path": item.get("path"),
                  "stratum": item.get("stratum"), "inputs_sha256": item.get("inputs_sha256"),
                  "verdict": str(item.get("verdict")).strip(), "basis_clauses": basis,
                  "reviewer": str(item.get("reviewer", "")).strip(),
                  "date": str(item.get("date", "")).strip(),
                  "notes": str(item.get("notes", "")).strip(),
                  "sample": {"seed": sheet.get("seed"), "generated_at": sheet.get("generated_at"),
                             "chapters": sorted(sheet.get("chapters") or [])}}
        errors = review_errors(review, root)
        path = root / str(review["path"])
        if not errors and not path.is_file():
            errors.append(f"{review['test']}: the test {review['path']} does not exist")
        if not errors and suite_results.input_digest(path) != review["inputs_sha256"]:
            errors.append(f"{review['test']}: the test changed after the sample was drawn; "
                          "draw it again")
        if errors:
            problems += errors
            continue
        reviews[:] = [r for r in reviews if not (r["test"] == review["test"]
                                                 and r["inputs_sha256"] == review["inputs_sha256"]
                                                 and r["reviewer"] == review["reviewer"])]
        reviews.append(review)
        added += 1
    for problem in problems:
        print(f"review_sample: {problem}", file=sys.stderr)
    if problems:
        print("review_sample: nothing was recorded", file=sys.stderr)
        return 1
    reviews.sort(key=lambda r: (r["test"], r["date"], r["reviewer"]))
    write_ledger(ledger_path, ledger)
    print(f"review_sample: recorded {added} reviews in {ledger_path.relative_to(root)}")
    return 0


def summarize(ledger: dict, root: Path, chapters: set[str] | None = None) -> dict:
    """Per stratum, the current reviews of the samples drawn over the given
    chapters (all chapters when None). A test counts once: it is an error when
    any current review of it says so, contested when none does but one says
    contested (left out of n), and correct otherwise."""
    frame = sorted(chapters) if chapters else []
    rows = {s: {"n": 0, "k": 0, "contested": 0, "stale": 0} for s in STRATA}
    verdicts = {}
    for review in ledger.get("reviews", []):
        if sorted(review.get("sample", {}).get("chapters") or []) != frame:
            continue
        path = root / review["path"]
        if not path.is_file() or suite_results.input_digest(path) != review["inputs_sha256"]:
            rows[review["stratum"]]["stale"] += 1
            continue
        verdicts.setdefault((review["stratum"], review["test"]), set()).add(review["verdict"])
    for (stratum, _), seen in verdicts.items():
        row = rows[stratum]
        if seen & ERRORS:
            row["n"] += 1
            row["k"] += 1
        elif "contested" in seen:
            row["contested"] += 1
        else:
            row["n"] += 1
    for row in rows.values():
        row["upper_bound"] = upper_bound(row["k"], row["n"])
    return rows


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    sub = ap.add_subparsers(dest="command", required=True)
    s = sub.add_parser("sample", help="draw a sample and write a review sheet")
    s.add_argument("--results", type=Path, required=True, help="directory of latest/<simulator>.json")
    s.add_argument("--output", type=Path, required=True, help="directory of the sheet")
    s.add_argument("--seed", type=int, required=True)
    s.add_argument("--count", action="append", default=[], metavar="STRATUM=N")
    s.add_argument("--default-count", type=int, default=0, help="draws of a stratum without --count")
    s.add_argument("--chapter", action="append", default=[], help="draw only from chapter N")
    s.add_argument("--language", choices=("ja", "en"), default="ja")
    s.add_argument("--source-url", default=SOURCE_URL)
    r = sub.add_parser("record", help="add the filled entries of a sheet to the ledger")
    r.add_argument("sheet", type=Path)
    p = sub.add_parser("report", help="error rate bounds per stratum")
    p.add_argument("--chapter", action="append", default=[])
    p.add_argument("--json", type=Path)
    sub.add_parser("check", help="validate the ledger")
    for parser in (s, r, p):
        parser.add_argument("--ledger", type=Path, default=LEDGER, help=argparse.SUPPRESS)
        parser.add_argument("--root", type=Path, default=ROOT, help=argparse.SUPPRESS)
    sub.choices["check"].add_argument("--ledger", type=Path, default=LEDGER, help=argparse.SUPPRESS)
    sub.choices["check"].add_argument("--root", type=Path, default=ROOT, help=argparse.SUPPRESS)
    args = ap.parse_args()
    root = args.root.resolve()

    if args.command == "sample":
        counts = {stratum: args.default_count for stratum in STRATA}
        for item in args.count:
            stratum, _, number = item.partition("=")
            if stratum not in STRATA or not number.isdigit():
                ap.error(f"--count takes STRATUM=N with STRATUM in {', '.join(STRATA)}")
            counts[stratum] = int(number)
        runs = load_runs(args.results)
        if not runs:
            print("review_sample: no results to read", file=sys.stderr)
            return 1
        chapters = set(args.chapter) or None
        found = classify(root, runs, chapters)
        sample = draw(found["strata"], counts, args.seed)
        tests = []
        for stratum in STRATA:
            for test in sample[stratum]:
                seen, digest = found["statuses"][test]
                tests.append(entry(root, test, stratum, seen, digest))
        sheet = {"schema": 1, "kind": "review-sample", "seed": args.seed,
                 "generated_at": datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds"),
                 "chapters": sorted(chapters) if chapters else [], "counts": counts,
                 "results_read": {sim: {k: v for k, v in run.items() if k != "tests"}
                                  for sim, run in runs.items()},
                 "population": {s: len(found["strata"][s]) for s in STRATA},
                 "left_out": found["left_out"], "drawn": {s: len(sample[s]) for s in STRATA},
                 "verdicts": list(VERDICTS), "tests": tests}
        args.output.mkdir(parents=True, exist_ok=True)
        (args.output / "review-sample.json").write_text(
            json.dumps(sheet, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
        (args.output / "review-sample.md").write_text(
            render(sheet, args.language, args.source_url), encoding="utf-8")
        drawn = ", ".join(f"{s} {sheet['drawn'][s]}/{sheet['population'][s]}" for s in STRATA)
        print(f"review_sample: drew {len(tests)} tests ({drawn})")
        return 0

    if args.command == "record":
        return record(args.sheet, args.ledger, root)

    ledger = read_ledger(args.ledger)
    if args.command == "check":
        errors = [] if ledger.get("schema") == 1 and isinstance(ledger.get("reviews"), list) \
            else ["the ledger needs schema 1 and a list of reviews"]
        keys = set()
        for review in ledger.get("reviews", []):
            errors += review_errors(review, root)
            key = (review.get("test"), review.get("inputs_sha256"), review.get("reviewer"))
            if key in keys:
                errors.append(f"{review.get('test')}: the same reviewer recorded it twice")
            keys.add(key)
        for error in errors:
            print(f"review_sample: {error}", file=sys.stderr)
        if errors:
            return 1
        rows = summarize(ledger, root)
        stale = sum(row["stale"] for row in rows.values())
        print(f"review_sample: {len(ledger['reviews'])} reviews are valid, {stale} of them stale")
        return 0

    rows = summarize(ledger, root, set(args.chapter) or None)
    print("stratum            n    k  contested  stale  95% upper bound")
    for stratum, row in rows.items():
        bound = "-" if row["upper_bound"] is None else f"{row['upper_bound']:.4f}"
        print(f"{stratum:16s} {row['n']:4d} {row['k']:4d} {row['contested']:10d} {row['stale']:6d}  {bound}")
    if args.json:
        args.json.write_text(json.dumps({"confidence": CONFIDENCE, "strata": rows},
                                        ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(main())
