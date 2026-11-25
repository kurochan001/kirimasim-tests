#!/usr/bin/env python3
"""Inspect the completed waveform sections emitted by the test fixtures."""

import argparse
from dataclasses import dataclass
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import suite_results


CHECKER = "tools/run_waveform_sections.py"
PROFILES = {tool: f"{tool}-waveform-sections" for tool in ("ghost", "icarus")}
PLAIN = "ch21/test_vcd_comment_insertion_preserves_dumpall"
KEYWORDS = "ch21/test_evcd_keyword_sections_extend_vcd"
TAIL_COMMENT = "ch21/test_evcd_manual_comment_before_closing_record"
TIMING = "ch21/test_evcd_inherits_vcd_scope_and_physical_time"
HEADER = "ch21/test_evcd_version_records_dumpports_filename_forms"
CASES = {tool: {case: suite_results.ROOT / "tests" / (case + ".sv") for case in names}
         for tool, names in (("ghost", (PLAIN, KEYWORDS, TAIL_COMMENT, TIMING, HEADER)), ("icarus", (PLAIN,)))}
DECLARATIONS = {"$date", "$version", "$timescale", "$scope", "$upscope", "$var", "$enddefinitions"}
PLAIN_CONTROLS = ("$dumpvars", "$dumpall", "$dumpoff", "$dumpon")
PORT_CONTROLS = ("$dumpports", "$dumpportsall", "$dumpportsoff", "$dumpportson")
PORT_STATE = re.compile(r"p[DUNZduLHXTlh01?FAaBbCcf]+")
STRENGTH = re.compile(r"[0-7]+")
VECTOR = re.compile(r"[bB][01xXzZ]+")
SCALAR = re.compile(r"[01xXzZ].+")
TIME_SCALE = re.compile(r"(1|10|100)\s*(fs|ps|ns|us|ms|s)")
FEMTOSECONDS = {"fs": 1, "ps": 10**3, "ns": 10**6, "us": 10**9, "ms": 10**12, "s": 10**15}
DATE = re.compile(r"[A-Za-z]+ [A-Za-z]+ (?:[1-9]|[12][0-9]|3[01]) "
                  r"(?:[01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] [0-9]{4}")
FILE_NOTICE = re.compile(r"^(?:VCD info: dumpfile sections\.vcd opened for output\.|"
                         r"WARNING: Dump file limit \(800 bytes\) exceeded\.|"
                         r"VCD dump limit set to 800 bytes|"
                         r"VCD file size limit reached \(800 bytes\)\. Stopping VCD dump\.)$")


@dataclass(frozen=True)
class Record:
    keyword: str
    declaration: bool
    time: int
    tokens: tuple[str, ...]


def checker_digest() -> str:
    return hashlib.sha256((suite_results.ROOT / CHECKER).read_bytes()).hexdigest()


def position(words, index, boundary):
    digits = words[index].removeprefix("#")
    if not digits and index + 1 < boundary:
        index += 1
        digits = words[index]
    if re.fullmatch(r"[0-9]+", digits) is None:
        raise ValueError("invalid timestamp")
    return int(digits), index + 1


def identifier(words, index, boundary, extended):
    if index >= boundary:
        raise ValueError("missing identifier")
    code = words[index]
    if extended and code == "<" and index + 1 < boundary:
        index += 1
        code += words[index]
    if extended and re.fullmatch(r"<[0-9]+", code) is None:
        raise ValueError("invalid port identifier")
    return code, index + 1


def value_change(words, start, boundary, known, extended):
    first = words[start]
    if extended:
        strengths = words[start + 1:start + 3]
        if (start + 3 >= boundary or PORT_STATE.fullmatch(first) is None
                or any(STRENGTH.fullmatch(field) is None for field in strengths)):
            raise ValueError("invalid port state or strength")
        code, end = identifier(words, start + 3, boundary, True)
        value = (first, *strengths, code)
    elif VECTOR.fullmatch(first):
        code, end = identifier(words, start + 1, boundary, False)
        value = (first, code)
    elif SCALAR.fullmatch(first):
        code, end = first[1:], start + 1
        value = (first[0], code)
    else:
        raise ValueError("unexpected waveform value")
    if code not in known:
        raise ValueError("value change refers to an undeclared identifier")
    return value, end


def read_sections(text, extended=False):
    words = text.split()
    controls = PORT_CONTROLS if extended else PLAIN_CONTROLS
    records, known = [], set()
    in_header, time, depth, index = True, 0, 0, 0
    while index < len(words):
        word = words[index]
        index += 1
        if word.startswith("$"):
            if word not in DECLARATIONS | {"$comment", "$vcdclose", *controls}:
                raise ValueError("unexpected waveform keyword")
            try:
                end = words.index("$end", index)
            except ValueError:
                raise ValueError("unterminated waveform section") from None
            fields = tuple(words[index:end])
            if (word in DECLARATIONS and not in_header) or (word in controls and in_header):
                raise ValueError("waveform keyword in the wrong phase")
            if word == "$scope":
                if len(fields) != 2 or (extended and fields[0] != "module"):
                    raise ValueError("invalid scope declaration")
                depth += 1
            elif word == "$upscope":
                if not depth or fields:
                    raise ValueError("unbalanced scope declaration")
                depth -= 1
            elif word == "$var":
                code, next_token = identifier(words, index + 2, end, extended)
                if next_token >= end or not depth or (extended and fields[0] != "port"):
                    raise ValueError("invalid variable declaration")
                known.add(code)
            elif word == "$enddefinitions":
                if fields or depth:
                    raise ValueError("invalid declaration boundary")
            elif word == "$vcdclose":
                if not extended or in_header or end != len(words) - 1 or not fields or not fields[0].startswith("#"):
                    raise ValueError("invalid extended closing section")
                final, next_token = position(words, index, end)
                if final < time or next_token != end:
                    raise ValueError("invalid extended closing timestamp")
                fields = (str(final),)
            elif word in controls:
                while index < end:
                    _, index = value_change(words, index, end, known, extended)
            records.append(Record(word, in_header, time, fields))
            if word == "$enddefinitions":
                in_header = False
            index = end + 1
        elif in_header:
            raise ValueError("data record before declaration boundary")
        elif word.startswith("#"):
            next_time, index = position(words, index - 1, len(words))
            if next_time < time:
                raise ValueError("decreasing timestamp")
            time = next_time
            records.append(Record("time", False, time, ()))
        else:
            fields, index = value_change(words, index - 1, len(words), known, extended)
            records.append(Record("value", False, time, fields))
    if in_header:
        raise ValueError("missing declaration boundary")
    return records


def named(records, keyword):
    return [record for record in records if record.keyword == keyword]


def timescale(records):
    items = named(records, "$timescale")
    scale = TIME_SCALE.fullmatch(" ".join(items[0].tokens)) if len(items) == 1 else None
    if scale is None:
        raise ValueError("missing or invalid timescale")
    return int(scale[1]) * FEMTOSECONDS[scale[2]]


def inserted_comments(path, text, baseline, extended=False):
    marker = re.compile(r"\$enddefinitions\s+\$end\b")
    changed, count = marker.subn(lambda match: match[0] + "\n$comment user body #999 pD 0 6 <0 $end", text, count=1)
    if count != 1:
        raise ValueError("missing declaration boundary for manual comment")
    amended = path.with_name("commented_" + path.name)
    amended.write_text("$comment user header\n$dumpall is comment text\n$end\n" + changed, encoding="ascii")
    records = read_sections(amended.read_text(encoding="ascii"), extended)
    comments = named(records, "$comment")
    matches = [item for item in comments if item.tokens[:2] in (("user", "header"), ("user", "body"))]
    preserved = [r for r in records if r not in matches] == baseline
    return preserved and [item.declaration for item in matches] == [True, False]


def plain_checks(directory):
    path = directory / "sections.vcd"
    text = path.read_text(encoding="ascii")
    records = read_sections(text)
    scale = timescale(records)
    native_comment = any(not r.declaration and "limit" in " ".join(r.tokens).lower()
                         for r in named(records, "$comment"))
    dumpall_times = [r.time * scale for r in named(records, "$dumpall") if r.tokens]
    manual = inserted_comments(path, text, records)
    return {"scale_fs": scale, "dumpall_times_fs": dumpall_times, "dumper_limit_comment": native_comment,
            "comments_preserve_records": manual,
            "pass": (native_comment and 2_000_000 in dumpall_times and named(records, "$timescale")[0].declaration
                     and manual)}


def paired_keyword_checks(directory):
    paths = [directory / name for name in ("paired.vcd", "paired.evcd")]
    sources = [path.read_text(encoding="ascii") for path in paths]
    plain, extended = (read_sections(source, is_extended) for source, is_extended in zip(sources, (False, True)))
    normalize = dict(zip(PORT_CONTROLS, PLAIN_CONTROLS))
    plain_schedule = [(r.keyword, r.time) for r in plain if r.keyword in PLAIN_CONTROLS]
    extended_schedule = [(normalize[r.keyword], r.time) for r in extended if r.keyword in PORT_CONTROLS]
    expected_schedule = list(zip(PLAIN_CONTROLS, (0, 3, 4, 6)))
    extended_only = ({normalize.get(r.keyword, r.keyword) for r in extended if r.keyword.startswith("$")}
                     - {r.keyword for r in plain if r.keyword.startswith("$")} - {"$comment"})
    closes = [int(r.tokens[0]) for r in named(extended, "$vcdclose")]
    native_comment = any(r.declaration and bool(r.tokens) for r in named(extended, "$comment"))
    manual = inserted_comments(paths[1], sources[1], extended, extended=True)
    return {"plain_controls": plain_schedule, "extended_controls": extended_schedule,
            "additional_keywords": sorted(extended_only), "closing_times": closes,
            "dumper_comment": native_comment, "comments_preserve_records": manual,
            "pass": (plain_schedule == extended_schedule == expected_schedule and closes == [9]
                     and extended_only == {"$vcdclose"} and native_comment and manual)}


def terminal_comment_checks(directory):
    text = (directory / "closing.evcd").read_text(encoding="ascii")
    baseline = read_sections(text, extended=True)
    closing = re.compile(r"(?m)^\s*\$vcdclose\s+#[0-9]+\s+\$end\s*\Z")
    changed, count = closing.subn(lambda match: "$comment closing note #900 $end\n" + match[0], text)
    if count != 1:
        raise ValueError("missing terminal closing command for comment check")
    amended = directory / "closing_with_comment.evcd"
    amended.write_text(changed, encoding="ascii")
    records = read_sections(amended.read_text(encoding="ascii"), extended=True)
    comment = Record("$comment", False, 2, ("closing", "note", "#900"))
    manual = records[-2] == comment and records[:-2] + records[-1:] == baseline
    original_comment = any(r.declaration and bool(r.tokens) for r in named(baseline, "$comment"))
    close_times = [int(r.tokens[0]) for r in named(records, "$vcdclose")]
    change_times = sorted({r.time for r in named(records, "value")})
    return {"dumper_comment": original_comment, "terminal_comment_preserves_records": manual,
            "closing_times": close_times, "change_times": change_times,
            "pass": original_comment and manual and close_times == [9] and change_times == [2]}


def paired_timing_checks(directory, top):
    observations = {}
    for name, extended in (("timed.vcd", False), ("timed.evcd", True)):
        records = read_sections((directory / name).read_text(encoding="ascii"), extended)
        scale = timescale(records)
        scopes = [r.tokens[1] for r in named(records, "$scope")]
        upscopes = len(named(records, "$upscope"))
        hierarchy = [r.keyword for r in records if r.keyword in ("$scope", "$var", "$upscope")]
        names = sorted(r.tokens[-1] for r in named(records, "$var"))
        raw_times = sorted({r.time for r in named(records, "value") if r.time})
        physical = [time * scale for time in raw_times]
        observations[name] = {"scale_fs": scale, "scopes": scopes, "upscopes": upscopes,
                              "signals": names, "hierarchy": hierarchy,
                              "change_times": raw_times, "change_times_fs": physical,
                              "pass": (scopes == [top, "target"] and names == ["a", "y"]
                                       and hierarchy == ["$scope", "$scope", "$var", "$var", "$upscope", "$upscope"]
                                       and physical == [70_000, 180_000])}
    return {"files": observations, "pass": all(item["pass"] for item in observations.values())}


def header_checks(directory, top):
    forms = {"literal": '"literal.evcd"', "variable": "file_name", "expression": '{prefix,".evcd"}'}
    observations = {}
    for name, filename_form in forms.items():
        records = read_sections((directory / (name + ".evcd")).read_text(encoding="ascii"), True)
        headers = [record.keyword for record in records if record.declaration]
        dates = named(records, "$date")
        versions = named(records, "$version")
        date_ok = len(dates) == 1 and DATE.fullmatch(" ".join(dates[0].tokens)) is not None
        version = " ".join(versions[0].tokens) if len(versions) == 1 else ""
        tool_id = bool(version.split("$dumpports", 1)[0].strip())
        scope = name + "_target"
        call = re.compile(rf"\$dumpports\((?:{re.escape(top)}\.)?{scope},{re.escape(filename_form)}\)")
        matching_call = call.search(re.sub(r"\s+", "", version)) is not None
        order = all(headers.count(keyword) == 1 and "$scope" in headers
                    and headers.index(keyword) < headers.index("$scope")
                    for keyword in ("$date", "$version", "$timescale"))
        observations[name] = {"five_field_date": date_ok, "version_identifier": tool_id,
                              "scope_and_unevaluated_filename": matching_call, "header_order": order,
                              "pass": date_ok and tool_id and order and matching_call}
    return {"forms": observations, "pass": all(item["pass"] for item in observations.values())}


def run_case(tool, executable, runtime, case, fixture):
    with tempfile.TemporaryDirectory() as temporary:
        directory = Path(temporary)
        if tool == "icarus":
            build = subprocess.run([str(executable), "-g2012", "-s", fixture.stem, "-o", "trace.vvp", str(fixture)],
                                   cwd=directory, capture_output=True, text=True, timeout=90)
            if build.returncode != 0:
                return {"pass": False, "compiler_exit": build.returncode}
            command = [str(runtime), "trace.vvp"]
        else:
            command = [str(executable), "--quiet-all", "--lrm-strict", str(fixture)]
        result = subprocess.run(command, cwd=directory, capture_output=True, text=True, timeout=90)
        output = [line for line in result.stdout.splitlines() if not FILE_NOTICE.fullmatch(line)]
        if result.returncode != 0 or output != suite_results.expected_output(fixture).splitlines():
            return {"pass": False, "simulation_exit": result.returncode, "simulation_output_matched": False}
        if case == PLAIN:
            return plain_checks(directory)
        if case == KEYWORDS:
            return paired_keyword_checks(directory)
        if case == TAIL_COMMENT:
            return terminal_comment_checks(directory)
        if case == TIMING:
            return paired_timing_checks(directory, fixture.stem)
        return header_checks(directory, fixture.stem)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tool", choices=PROFILES, required=True)
    parser.add_argument("--simulator", required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    program = shutil.which(args.simulator)
    if program is None:
        parser.error("the simulator executable is unavailable")
    executable = Path(program).resolve()
    runtime = executable.with_name("vvp") if args.tool == "icarus" else None
    if runtime is not None and shutil.which(runtime) is None:
        parser.error("Icarus runtime is unavailable beside the compiler")
    binaries = {"executable": executable} | ({"runtime": runtime} if runtime else {})
    hashes = {name: hashlib.sha256(path.read_bytes()).hexdigest() for name, path in binaries.items()}
    digest = checker_digest()
    runner = suite_results.runner_digest(args.tool)
    cases = CASES[args.tool]
    inputs = suite_results.fingerprints(list(cases.values()))
    verdicts, observations = {}, {}
    for case, fixture in cases.items():
        try:
            row = run_case(args.tool, executable, runtime, case, fixture)
        except (OSError, subprocess.TimeoutExpired):
            row = {"pass": False, "reason": "waveform file or tool unavailable"}
        except ValueError as err:
            reason = str(err) if type(err) is ValueError else "invalid character in waveform output"
            row = {"pass": False, "reason": reason}
        observations[case] = {"inputs_sha256": inputs[case], **row}
        verdict = ("pass", "") if row["pass"] else ("fail", "waveform check differed")
        verdicts[case] = verdict
        print(f"{verdict[0].upper()} {case}")
    if (digest != checker_digest() or inputs != suite_results.fingerprints(list(cases.values()))
            or hashes != {name: hashlib.sha256(path.read_bytes()).hexdigest() for name, path in binaries.items()}):
        parser.exit(2, "The simulator, checker or fixture changed during execution.\n")
    version = (f"private build {hashes['executable'][:12]}" if args.tool == "ghost"
               else suite_results.tool_version([str(executable), "-V"]))
    configuration = {"evidence_profile": PROFILES[args.tool], "checker_sha256": digest, "binary_sha256": hashes}
    suite_results.write(args.json, args.tool, "Ghost" if args.tool == "ghost" else args.tool,
                        version, verdicts, inputs=inputs, runner_sha256=runner, configuration=configuration)
    args.observations.write_text(json.dumps({"tool": args.tool, "version": version, **configuration,
                                            "cases": observations}, indent=2) + "\n", encoding="utf-8")
    return int(any(status != "pass" for status, _ in verdicts.values()))


if __name__ == "__main__":
    raise SystemExit(main())
