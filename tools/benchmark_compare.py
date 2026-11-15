#!/usr/bin/env python3
"""Paired, serial benchmark comparison using kirimasim's pinned bench adapter.

Requires a kirimasim checkout containing tools/bench.py and bench/*.sv.
It builds each design once, warms up at n=1, alternates tool and count order,
checks every output, and stores every sample before calculating medians.
No simulation result is used to rewrite an expected value.
"""

import argparse
from datetime import datetime, timezone
import hashlib
import importlib.util
import json
import math
from pathlib import Path
import re
import shutil
import statistics
import subprocess
import sys
import tempfile


TOOLS = ("kirimasim", "icarus")


def digest(path):
    result = hashlib.sha256()
    with Path(path).open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            result.update(block)
    return result.hexdigest()


def load_adapter(root):
    path = root / "tools/bench.py"
    specification = importlib.util.spec_from_file_location("pinned_benchmark_adapter", path)
    module = importlib.util.module_from_spec(specification)
    specification.loader.exec_module(module)
    return module


def git_revision(root):
    result = subprocess.run(["git", "-C", str(root), "rev-parse", "HEAD"],
                            capture_output=True, text=True)
    return result.stdout.strip() if result.returncode == 0 else None


def case_description(path, adapter, source):
    count, expected = adapter.header(path)
    text = path.read_text(encoding="utf-8")
    small = re.search(r"^// bench-expect-small: (.+)$", text, re.M)
    return {"name": path.stem, "path": path, "count": count, "expected": expected,
            "expected_small": small[1] if small else None, "source": source,
            "sha256": digest(path)}


def check_sample(sample, name, count, expected):
    if sample["timed_out"]:
        return "time limit reached"
    if sample["exit_code"] != 0:
        return "nonzero exit status"
    line = sample.get("result_line")
    if not line or not re.match(re.escape(name) + r" n=" + str(count) + r"(?: |$)", line):
        return "missing result line or wrong iteration count"
    if expected is not None and line != expected:
        return "result does not match the unchanged benchmark expectation"
    return None


def distribution(values):
    middle = statistics.median(values)
    return {"median": middle, "minimum": min(values), "maximum": max(values),
            "mad": statistics.median(abs(value - middle) for value in values)}


def aggregate(record, runs):
    if record.get("error"):
        return
    if any(len(record["samples"][kind]) != runs for kind in ("small", "large")):
        record["error"] = {"stage": "aggregation", "reason": "incomplete repetitions"}
        return
    for kind in ("small", "large"):
        record[kind + "_seconds"] = distribution([s["seconds"] for s in record["samples"][kind]])
    record["incremental_seconds"] = (record["large_seconds"]["median"]
                                     - record["small_seconds"]["median"])
    rss = [s["max_rss_mib"] for s in record["samples"]["large"] if s["max_rss_mib"] is not None]
    record["median_peak_rss_mib"] = statistics.median(rss) if rss else None


def comparison(records):
    if any(record.get("error") for record in records.values()):
        return {"status": "not comparable: a correctness or execution check failed", "ratio": None}
    times = {name: record["incremental_seconds"] for name, record in records.items()}
    if any(value <= 0 for value in times.values()):
        return {"status": "unresolved: non-positive baseline difference", "ratio": None}
    return {"status": "comparable", "ratio": times["kirimasim"] / times["icarus"],
            "ratio_definition": "kirimasim / Icarus median incremental elapsed time"}


def diagnostics(result, clean, work):
    return clean({key: result.get(key, "")[-4000:] for key in ("stdout", "stderr")}, work)


def collect_case(case, adapter, executables, runs, case_index, clean):
    records = {name: {"build": None, "warmup": None,
                      "samples": {"small": [], "large": []}} for name in TOOLS}
    with tempfile.TemporaryDirectory(prefix="p1-speed-") as directory:
        base = Path(directory)
        commands = {}
        for name in TOOLS:
            work = base / name
            work.mkdir()
            build, command = adapter.prepare(name, executables[name], case["path"], work)
            record = records[name]
            record["build"] = clean(build, work)
            if build and "error" in build:
                record["error"] = {"stage": "build", "reason": build["error"]}
                continue
            commands[name] = (work, command)
            record["command_template"] = clean(command("N"), work)
            result = adapter.run(command(1), work)
            sample = adapter.sample(case["name"], result)
            record["warmup"] = sample
            error = check_sample(sample, case["name"], 1, case["expected_small"])
            if error:
                record["error"] = {"stage": "warmup", "reason": error,
                                   "diagnostics": diagnostics(result, clean, work)}
        for repetition in range(runs):
            tools = TOOLS if (case_index + repetition) % 2 == 0 else tuple(reversed(TOOLS))
            counts = (("small", 1), ("large", case["count"]))
            if repetition % 2:
                counts = tuple(reversed(counts))
            for name in tools:
                record = records[name]
                if record.get("error"):
                    continue
                work, command = commands[name]
                for kind, count in counts:
                    result = adapter.run(command(count), work)
                    sample = adapter.sample(case["name"], result)
                    sample["repetition"] = repetition
                    record["samples"][kind].append(sample)
                    expected = case["expected"] if kind == "large" else case["expected_small"]
                    error = check_sample(sample, case["name"], count, expected)
                    if error:
                        record["error"] = {"stage": kind, "reason": error,
                                           "diagnostics": diagnostics(result, clean, work)}
                        break
        if not any(record.get("error") for record in records.values()):
            small_lines = {sample["result_line"] for record in records.values()
                           for sample in [record["warmup"], *record["samples"]["small"]]}
            if len(small_lines) != 1:
                for record in records.values():
                    record["error"] = {"stage": "baseline correctness",
                                       "reason": "n=1 outputs disagree across tools or repetitions"}
        for record in records.values():
            aggregate(record, runs)
    public = {key: value for key, value in case.items() if key != "path"}
    public.update({"tools": records, "comparison": comparison(records)})
    return public


def executable(path):
    found = shutil.which(path)
    if not found:
        raise ValueError("executable not found: " + path)
    return str(Path(found).resolve())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--benchmark-root", type=Path, required=True)
    parser.add_argument("--kirimasim", required=True)
    parser.add_argument("--iverilog", required=True)
    parser.add_argument("--kirimasim-commit", required=True)
    parser.add_argument("--icarus-commit", required=True)
    parser.add_argument("--extra-bench", type=Path, action="append", default=[])
    parser.add_argument("--only", nargs="*")
    parser.add_argument("--runs", type=int, default=5)
    parser.add_argument("--out", type=Path, required=True)
    arguments = parser.parse_args()
    if arguments.runs < 1:
        parser.error("--runs must be positive")
    root = arguments.benchmark_root.resolve()
    adapter = load_adapter(root)
    executables = {"kirimasim": executable(arguments.kirimasim), "icarus": executable(arguments.iverilog)}
    vvp = str(Path(executables["icarus"]).with_name("vvp"))
    binaries = {**executables, "vvp": vvp}
    versions = {"kirimasim": adapter.text_of([executables["kirimasim"], "--version"]),
                "icarus": adapter.text_of([executables["icarus"], "-V"]),
                "vvp": adapter.text_of([vvp, "-V"])}
    for name, commit in (("kirimasim", arguments.kirimasim_commit), ("icarus", arguments.icarus_commit)):
        if not re.fullmatch(r"[0-9a-f]{40}", commit) or commit[:7] not in versions[name]:
            parser.error(name + " binary version does not match the pinned commit")
    cases = [case_description(path.resolve(), adapter, "kirimasim/bench/" + path.name)
             for path in sorted((root / "bench").glob("*.sv"))]
    cases += [case_description(path.resolve(), adapter, "additional/" + path.name)
              for path in arguments.extra_bench]
    if len({case["name"] for case in cases}) != len(cases):
        parser.error("duplicate benchmark name")
    if arguments.only:
        unknown = set(arguments.only) - {case["name"] for case in cases}
        if unknown:
            parser.error("unknown benchmark selection")
        cases = [case for case in cases if case["name"] in arguments.only]
    if not cases:
        parser.error("no benchmarks selected")
    protected = {str(Path(__file__).resolve()): digest(__file__),
                 str(root / "tools/bench.py"): digest(root / "tools/bench.py"),
                 **{str(case["path"]): case["sha256"] for case in cases},
                 **{path: digest(path) for path in binaries.values()}}
    replacements = {str(root): "${BENCHMARK_ROOT}", str(Path.home()): "${HOME}"}
    replacements.update({str(path.resolve().parent): "${ADDITIONAL_BENCH}" for path in arguments.extra_bench})
    replacements.update({path: "${" + name.upper() + "}" for name, path in binaries.items()})

    def clean(value, work):
        if value is None:
            return None
        text = json.dumps(value)
        for old, new in sorted({**replacements, str(work): "${WORK}"}.items(), key=lambda row: -len(row[0])):
            text = text.replace(old, new)
        return json.loads(text)

    result = {"schema": 1, "started_at": datetime.now(timezone.utc).isoformat(),
              "machine_start": adapter.machine(), "runs": arguments.runs, "warmups": 1,
              "execution": "serial; tool order alternates per case/round; count order alternates per round",
              "metric": "median large elapsed minus median n=1 elapsed; no extrapolation",
              "pinned_commits": {"kirimasim": arguments.kirimasim_commit, "icarus": arguments.icarus_commit},
              "benchmark_commit": git_revision(root), "versions": versions,
              "binary_sha256": {name: digest(path) for name, path in binaries.items()},
              "adapter_sha256": digest(root / "tools/bench.py"), "driver_sha256": digest(__file__),
              "cases": []}
    arguments.out.mkdir(parents=True, exist_ok=True)
    output = arguments.out / "results.json"
    for index, case in enumerate(cases):
        print(f"{index + 1}/{len(cases)} {case['name']} n={case['count']} starting", flush=True)
        row = collect_case(case, adapter, executables, arguments.runs, index, clean)
        result["cases"].append(row)
        changed = any(digest(path) != value for path, value in protected.items())
        result["inputs_unchanged"] = not changed
        output.write_text(json.dumps(result, indent=2) + "\n")
        print(case["name"], row["comparison"]["status"], row["comparison"]["ratio"], flush=True)
        if changed:
            print("Inputs changed during measurement; campaign invalid.", file=sys.stderr)
            return 2
    ratios = [case["comparison"]["ratio"] for case in result["cases"] if case["comparison"]["ratio"] is not None]
    result.update({"completed_at": datetime.now(timezone.utc).isoformat(), "machine_end": adapter.machine(),
                   "comparable_cases": len(ratios),
                   "geometric_mean_ratio": math.exp(statistics.mean(math.log(r) for r in ratios)) if ratios else None})
    output.write_text(json.dumps(result, indent=2) + "\n")
    return 1 if any(case["comparison"]["ratio"] is None for case in result["cases"]) else 0


if __name__ == "__main__":
    raise SystemExit(main())
