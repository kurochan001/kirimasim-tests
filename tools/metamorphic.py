#!/usr/bin/env python3
"""Metamorphic checks: transform a test in a way that does not change its
meaning, run the original and the copy on the same simulator and compare the
normalized outputs. No expected output is used, so a wrong expectation cannot
hide a simulator defect or a hidden dependency of a test.

Usage:
    python3 tools/metamorphic.py --simulator icarus|kirimasim [--iverilog-bin DIR]
        [--kirimasim PATH] [--transform M1 ...] [-j N] [--json FILE] [tests ...]

The tests are the simulation tests (not :type: formal, not illegal designs),
all of them when none is named. Every transform has its own exclusions; a test
outside them is copied to a temporary directory, transformed and run. The
runners are not changed: their judge function is called with the expected
output replaced by a value that never matches, and the normalized output the
runner then compares is taken from that call. A run that does not get that
far (a build error, an unsupported construct) is compared by its status and
reason, with the paths of the test replaced.

M1 renames the variables and nets that the file declares, uniformly (5.6,
3.13, 23.9: a name only binds a declaration to its uses). Excluded: tests whose
expected output contains a renamed name, tests with C code, :top_module:,
:files: or `include, and tests with `define (a macro can build or quote names).
M2 adds a comment and a line break after every semicolon outside strings,
comments and directive lines (5.3, 5.4: white space and comments only separate
tokens). Excluded: tests that can print a line number or a file position
(`__LINE__`, `__FILE__`, `line, %l, severity tasks, assertions), tests with C
code, :files: or `include, and illegal designs.
Every transform also leaves out, after the original run, a test whose run
prints a path, and M2 one whose run prints a position in its file (a
simulator can print a diagnostic on the standard output). When the outputs
differ, the original is run three more times; if it changes, the difference is
recorded as original_varies, which means the simulator is not deterministic.
M3 multiplies the time unit and the time precision of every `timescale
directive by ten (3.14, 22.7: delays are counted in the unit, and $time,
$stime and $realtime return values in it, 20.3). Excluded: tests without a
`timescale directive, with time literals that carry a unit (5.8), %t or
$timeformat (21.2.1.3, 20.4.2), $printtimescale, $timeunit, $timeprecision,
timeunit or timeprecision declarations, SDF, value change dumps, C code,
:files: or `include, and a unit that cannot grow (100 s).
"""

import argparse
import concurrent.futures
import contextlib
import json
import re
import sys
import tempfile
import threading
from pathlib import Path

import suite_results

ROOT = Path(__file__).resolve().parent.parent
TRANSFORMS = ("M1", "M2", "M3")
SENTINEL = "\x00metamorphic: no output can match this\n"
_CAPTURE = threading.local()
_PATCH_LOCK = threading.Lock()

KEYWORDS = set("""
accept_on alias always always_comb always_ff always_latch and assert assign assume automatic before
begin bind bins binsof bit break buf bufif0 bufif1 byte case casex casez cell chandle checker class
clocking cmos config const constraint context continue cover covergroup coverpoint cross deassign
default defparam design disable dist do edge else end endcase endchecker endclass endclocking endconfig
endfunction endgenerate endgroup endinterface endmodule endpackage endprimitive endprogram endproperty
endspecify endsequence endtable endtask enum event eventually expect export extends extern final
first_match for force foreach forever fork forkjoin function generate genvar global highz0 highz1 if
iff ifnone ignore_bins illegal_bins implements implies import incdir include initial inout input inside
instance int integer interconnect interface intersect join join_any join_none large let liblist library
local localparam logic longint macromodule matches medium modport module nand negedge nettype new nexttime
nmos nor noshowcancelled not notif0 notif1 null or output package packed parameter pmos posedge primitive
priority program property protected pull0 pull1 pulldown pullup pulsestyle_ondetect pulsestyle_onevent pure
rand randc randcase randsequence rcmos real realtime ref reg reject_on release repeat restrict return rnmos
rpmos rtran rtranif0 rtranif1 s_always s_eventually s_nexttime s_until s_until_with scalared sequence
shortint shortreal showcancelled signed small soft solve specify specparam static string strong strong0
strong1 struct super supply0 supply1 sync_accept_on sync_reject_on table tagged task this throughout time
timeprecision timeunit tran tranif0 tranif1 tri tri0 tri1 triand trior trireg type typedef union unique
unique0 unsigned until until_with untyped use uwire var vectored virtual void wait wait_order wand weak
weak0 weak1 while wildcard wire with within wor xnor xor
item index size push_back push_front pop_back pop_front insert delete exists num first last next prev
""".split())
DECLARATION = re.compile(
    r"\b(?:logic|reg|bit|byte|shortint|int|longint|integer|time|real|realtime|shortreal|string|wire|tri|"
    r"uwire|wand|wor|event|genvar)\b(?:\s+(?:signed|unsigned))?(?:\s*\[[^\]]*\])*\s+"
    r"([A-Za-z_][A-Za-z0-9_]*(?:\s*(?:\[[^\]]*\])*\s*(?:=[^,;]*)?\s*,\s*[A-Za-z_][A-Za-z0-9_]*)*)")
UNIT = {"s": 0, "ms": -3, "us": -6, "ns": -9, "ps": -12, "fs": -15}
TIMESCALE = re.compile(r"`timescale\s+(1|10|100)\s*(s|ms|us|ns|ps|fs)\s*/\s*(1|10|100)\s*(s|ms|us|ns|ps|fs)")


def segments(text: str) -> list[tuple[str, str]]:
    """The text as (kind, part) pieces: code, string, comment or directive (a
    line that starts with a backquote, with its continuation lines)."""
    out, i, n = [], 0, len(text)
    start = 0

    def flush(kind_end):
        nonlocal start
        if start < kind_end:
            out.append(("code", text[start:kind_end]))
        start = kind_end

    at_line_start = True
    while i < n:
        c = text[i]
        if at_line_start and c in " \t":
            i += 1
            continue
        if at_line_start and c == "`" and re.match(r"`[A-Za-z_]", text[i:]):
            flush(i)
            j = i
            while True:
                end = text.find("\n", j)
                end = n if end < 0 else end
                if end > j and text[end - 1] == "\\":
                    j = end + 1
                    continue
                break
            out.append(("directive", text[i:end]))
            i = start = end
            at_line_start = False
            continue
        at_line_start = False
        if text.startswith("//", i):
            flush(i)
            end = text.find("\n", i)
            end = n if end < 0 else end
            out.append(("comment", text[i:end]))
            i = start = end
            continue
        if text.startswith("/*", i):
            flush(i)
            end = text.find("*/", i + 2)
            end = n if end < 0 else end + 2
            out.append(("comment", text[i:end]))
            i = start = end
            continue
        if c == '"':
            flush(i)
            triple = text.startswith('"""', i)
            j = i + (3 if triple else 1)
            while j < n:
                if text[j] == "\\":
                    j += 2
                    continue
                if (triple and text.startswith('"""', j)) or (not triple and text[j] in '"\n'):
                    j += 3 if triple else 1
                    break
                j += 1
            out.append(("string", text[i:j]))
            i = start = j
            continue
        if c == "\n":
            at_line_start = True
        i += 1
    flush(n)
    return out


def code_only(text: str) -> str:
    return "".join(part if kind == "code" else " " for kind, part in segments(text))


def without_comments(text: str) -> str:
    return "".join(" " if kind == "comment" else part for kind, part in segments(text))


def body_of(test: Path) -> str:
    text = test.read_text(encoding="utf-8", errors="replace")
    end = text.find("*/")
    return text[end + 2:] if text.lstrip().startswith("/*") and end >= 0 else text


def common_exclusions(test: Path, fields: dict, text: str) -> str | None:
    if fields.get("dpi_c") or fields.get("vpi_c"):
        return "C code"
    if fields.get("files"):
        return "several files"
    if re.search(r"`include\b", text):
        return "`include"
    return None


def declared_names(code: str) -> set[str]:
    names = set()
    for match in DECLARATION.finditer(code):
        for part in re.split(r",", match.group(1)):
            name = re.match(r"\s*([A-Za-z_][A-Za-z0-9_]*)", part)
            if name:
                names.add(name.group(1))
    return {n for n in names if n not in KEYWORDS}


def plan_m1(test, fields, text, expected):
    why = common_exclusions(test, fields, text)
    if why:
        return why, None
    if fields.get("top_module"):
        return ":top_module:", None
    if re.search(r"`define\b", text):
        return "`define", None
    if re.search(r"\\\S", code_only(body_of(test))):
        return "an escaped identifier", None
    code = code_only(body_of(test))
    names = declared_names(code)
    names -= set(re.findall(r"\.\s*([A-Za-z_][A-Za-z0-9_]*)", code))
    if not names:
        return "no renamable declaration", None
    words = set(re.findall(r"[A-Za-z_][A-Za-z0-9_$]*", expected or ""))
    if names & words:
        return "a renamed name appears in the expected output", None
    strings = " ".join(part for kind, part in segments(body_of(test)) if kind == "string")
    if names & set(re.findall(r"[A-Za-z_][A-Za-z0-9_$]*", strings)):
        return "a renamed name appears in a string", None
    if re.search(r"\$dump|\$sdf_annotate|\$fst", code):
        return "the design names its signals in a file", None
    rename = {n: f"mm_{n}" for n in sorted(names)}
    taken = set(re.findall(r"[A-Za-z_][A-Za-z0-9_$]*", text))
    if set(rename.values()) & taken:
        return "a new name is already used", None
    out = []
    pattern = re.compile(r"(?<![A-Za-z0-9_$`'.\\])\b(" + "|".join(map(re.escape, sorted(names))) + r")\b(?![A-Za-z0-9_$])")
    header_end = text.find("*/") + 2 if text.lstrip().startswith("/*") else 0
    out.append(text[:header_end])
    for kind, part in segments(text[header_end:]):
        out.append(pattern.sub(lambda m: rename[m.group(1)], part) if kind == "code" else part)
    return None, "".join(out)


LOCATION = re.compile(r"`__LINE__|`__FILE__|`line\b|%l\b|\$(error|warning|info|fatal)\b|\bassert\b|"
                      r"\bassume\b|\bcover\b|\bexpect\b")


def plan_m2(test, fields, text, expected):
    why = common_exclusions(test, fields, text)
    if why:
        return why, None
    if LOCATION.search(without_comments(body_of(test))):
        return "can print a line or file position", None
    if re.search(r"\\\S", code_only(body_of(test))):
        return "an escaped identifier", None
    if test.name in (expected or "") or re.search(r"\.sv:\d+", expected or ""):
        return "the expected output names the file", None
    header_end = text.find("*/") + 2 if text.lstrip().startswith("/*") else 0
    out = [text[:header_end]]
    for kind, part in segments(text[header_end:]):
        out.append(part.replace(";", "; /* m2 */\n") if kind == "code" else part)
    return None, "".join(out)


TIME_EXCLUSIONS = re.compile(
    r"%[-0-9]*t\b|\$timeformat\b|\$printtimescale\b|\$timeunit\b|\$timeprecision\b|\btimeunit\b|"
    r"\btimeprecision\b|\$sdf_annotate\b|\$dump|\$fst|\bspecify\b|\bspecparam\b")
TIME_LITERAL = re.compile(r"\b\d+(\.\d+)?\s*(s|ms|us|ns|ps|fs)\b|\b1step\b")


def scaled(magnitude: str, unit: str) -> tuple[str, str] | None:
    exponent = UNIT[unit] + len(magnitude) - 1 + 1
    if exponent > 2:
        return None
    for name, base in UNIT.items():
        if base <= exponent < base + 3:
            return "1" + "0" * (exponent - base), name
    return None


def plan_m3(test, fields, text, expected):
    why = common_exclusions(test, fields, text)
    if why:
        return why, None
    if not TIMESCALE.search(text):
        return "no `timescale directive", None
    code = code_only(body_of(test))
    if TIME_EXCLUSIONS.search(without_comments(body_of(test))):
        return "prints or reads time units", None
    if TIME_LITERAL.search(code):
        return "a time literal with a unit", None

    def grow(match):
        unit, precision = scaled(match.group(1), match.group(2)), scaled(match.group(3), match.group(4))
        if unit is None or precision is None:
            raise ValueError("unit")
        return f"`timescale {unit[0]}{unit[1]}/{precision[0]}{precision[1]}"
    try:
        return None, TIMESCALE.sub(grow, text)
    except ValueError:
        return "the unit cannot grow", None


PLANS = {"M1": plan_m1, "M2": plan_m2, "M3": plan_m3}


def plan(test: Path, transform: str) -> tuple[str | None, str | None]:
    fields = suite_results.header(test)
    text = test.read_text(encoding="utf-8", errors="replace")
    return PLANS[transform](test, fields, text, suite_results.expected_output(test))


@contextlib.contextmanager
def capturing(runner):
    """Make the runner compare with a value that never matches and keep the
    normalized output it then passes to first_difference."""
    with _PATCH_LOCK:
        if not getattr(runner, "_metamorphic_patched", False):
            original_first_difference = runner.suite_results.first_difference

            def first_difference(got, want):
                if want == SENTINEL:
                    _CAPTURE.output = got
                return original_first_difference(got, want)
            runner.suite_results.first_difference = first_difference
            runner.expected_output = lambda test: SENTINEL
            runner._metamorphic_patched = True
    yield


def outcome(runner, simulator: str, test: Path, options) -> str:
    _CAPTURE.output = None
    with tempfile.TemporaryDirectory(ignore_cleanup_errors=True) as tmp:
        try:
            if simulator == "icarus":
                ok, why = runner.judge(test, options.bindir, tmp, None)
                status = "pass" if ok else "fail"
            else:
                status, why = runner.judge(test, options.kirimasim, tmp, None)
        except Exception as error:
            status, why = "error", f"{type(error).__name__}: {error}"
        why = runner.neutral(str(why), tmp, None)
    located = re.compile(r"[^\s:'\"]*" + re.escape(test.name))
    if _CAPTURE.output is not None:
        return "output:" + located.sub("<test>", _CAPTURE.output)
    return f"{status}:" + located.sub("<test>", why)


def comparable(first: str, second: str) -> bool:
    return first.startswith("output:") or second.startswith("output:")


def check(test: Path, transforms, runner, simulator, options, root: Path) -> dict:
    record = {"test": test.resolve().relative_to(root / "tests").with_suffix("").as_posix(),
              "transforms": {}}
    original = None
    for transform in transforms:
        why, text = plan(test, transform)
        if why:
            record["transforms"][transform] = {"state": "excluded", "reason": why}
            continue
        if original is None:
            original = outcome(runner, simulator, test, options)
        with tempfile.TemporaryDirectory() as directory:
            copy = Path(directory) / test.name
            for sibling in test.parent.glob(test.stem + "*"):
                if sibling != test and sibling.is_file():
                    (Path(directory) / sibling.name).write_bytes(sibling.read_bytes())
            copy.write_text(text, encoding="utf-8")
            changed = outcome(runner, simulator, copy, options)
        captured = original.startswith("output:")
        if captured and re.search(r"<home>|<tmp>", original):
            record["transforms"][transform] = {"state": "excluded", "reason": "the run prints a path"}
            continue
        if captured and transform == "M2" and "<test>" in original:
            record["transforms"][transform] = {"state": "excluded",
                                               "reason": "the run prints a position in the file"}
            continue
        if not comparable(original, changed):
            state = "not_compared"
        else:
            state = "same" if original == changed else "different"
        entry = {"state": state}
        if state == "different":
            if any(outcome(runner, simulator, test, options) != original for _ in range(3)):
                entry["state"] = state = "original_varies"
            ours, theirs = original.split("\n"), changed.split("\n")
            line = next((i for i, (a, b) in enumerate(zip(ours, theirs)) if a != b), min(len(ours), len(theirs)))
            entry.update({"line": line, "original": "\n".join(ours[max(0, line - 1):line + 2])[:600],
                          "transformed": "\n".join(theirs[max(0, line - 1):line + 2])[:600]})
        record["transforms"][transform] = entry
    return record


def candidates(tests: list[Path]) -> list[Path]:
    out = []
    for test in tests:
        fields = suite_results.header(test)
        if fields.get("type", "simulation").strip() == "formal" or "should_fail_because" in fields:
            continue
        out.append(test)
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--simulator", choices=("icarus", "kirimasim"), required=True)
    ap.add_argument("--iverilog-bin", type=Path)
    ap.add_argument("--kirimasim", default="kirimasim")
    ap.add_argument("--transform", action="append", choices=TRANSFORMS)
    ap.add_argument("-j", "--jobs", type=int, default=4)
    ap.add_argument("--json", type=Path)
    ap.add_argument("tests", nargs="*", type=Path)
    args = ap.parse_args()
    transforms = args.transform or list(TRANSFORMS)
    tests = candidates(args.tests or suite_results.find_tests())
    if args.simulator == "icarus":
        import run_icarus as runner
    else:
        import run_kirimasim as runner
    options = argparse.Namespace(bindir=args.iverilog_bin, kirimasim=args.kirimasim)
    version_command = ([str(args.iverilog_bin / "iverilog") if args.iverilog_bin else "iverilog", "-V"]
                       if args.simulator == "icarus" else [args.kirimasim, "--version"])
    with capturing(runner), concurrent.futures.ThreadPoolExecutor(args.jobs) as pool:
        records = list(pool.map(lambda t: check(t, transforms, runner, args.simulator, options, ROOT), tests))
    summary = {}
    for transform in transforms:
        states, reasons = {}, {}
        for r in records:
            item = r["transforms"].get(transform)
            if item is None:
                continue
            states[item["state"]] = states.get(item["state"], 0) + 1
            if item["state"] == "excluded":
                reasons[item["reason"]] = reasons.get(item["reason"], 0) + 1
        summary[transform] = {"states": states, "excluded": reasons,
                              "different": sorted(r["test"] for r in records
                                                  if r["transforms"].get(transform, {}).get("state") == "different"),
                              "original_varies": sorted(r["test"] for r in records
                                                        if r["transforms"].get(transform, {}).get("state")
                                                        == "original_varies")}
    for transform, s in summary.items():
        print(f"{transform}: " + ", ".join(f"{k} {v}" for k, v in sorted(s["states"].items())))
        for test in s["different"]:
            print(f"  different: {test}")
    if args.json:
        args.json.write_text(json.dumps({
            "simulator": args.simulator, "version": suite_results.tool_version(version_command),
            "transforms": transforms, "summary": summary,
            "records": [r for r in records if any(v["state"] in ("different", "original_varies")
                                                  for v in r["transforms"].values())]},
            ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(main())
