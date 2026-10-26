#!/usr/bin/env python3
"""Checks the metadata and the form of every test against the rules of
README.md ("Metadata", "How a test is judged" and "Contributing").

Usage:
    python3 tools/lint_metadata.py [--update-baseline] [TEST ...]

With no TEST arguments, checks every tests/**/test_*.sv. Each problem is
printed as "<test> <rule>: <detail>", where the test is its path under tests/
without ".sv". The rules:

    missing-field       a required field is missing: :name:, :description:,
                        :tags:, :type:, :lrm:, :oracle:, :spec_check:,
                        :fourstate:, :nondeterministic:
    name                :name: is not the file name
    value               a field has a value outside its allowed set (:type:,
                        :oracle:, :spec_check:, :fourstate:,
                        :nondeterministic:, :expected_exit:, :generator:)
    lrm                 :lrm: is not "1800-2023" followed by clause numbers
    chapter             the first clause of :lrm: is not of the chapter of the
                        directory (chNN)
    tags                :tags: is not the directory (chNN)
    fourstate           :fourstate: no, but the code has an x or z literal
    expected            a test that is run has no :expected_stdout:, or its
                        file is missing or empty
    should-fail         :should_fail_because: without :type: elaboration or
                        without :expected_stderr_regex:, or with
                        :expected_stdout:; or :type: elaboration without
                        :should_fail_because:
    file                a file or directory that :files:, :incdirs:, :dpi_c:
                        or :vpi_c: names does not exist
    top-module          :top_module: names a module or config that the test and its
                        :files: do not declare
    width               a comment line is longer than 80 columns, or a line
                        of code longer than 100 (the metadata comment is not
                        counted)
    verilator-comment   a comment line starts with the word Verilator, which
                        Verilator reads as a directive (BADVLTPRAGMA)
    timescale           the test prints a time with %t, $timeformat or
                        $printtimescale, or has a fractional delay or a delay
                        with a time unit, but sets no time unit with
                        `timescale or timeunit
    todo                the metadata or the comment still has TODO from
                        tools/new_test.py

Some existing tests break a rule; they are listed in tools/lint_baseline.txt
and reported as known, without being changed. The script exits with 1 when a
test breaks a rule that the baseline does not list, or when the baseline lists
a problem that is gone (then update it with --update-baseline). Checking only
some tests (TEST arguments) does not report the gone problems of others.
"""

import argparse
import re
import sys
from pathlib import Path

import suite_results

ROOT = Path(__file__).resolve().parent.parent
BASELINE = ROOT / "tools" / "lint_baseline.txt"
REQUIRED = ("name", "description", "tags", "type", "lrm", "oracle", "spec_check",
            "fourstate", "nondeterministic")
ORACLES = ("spec", "iverilog@13.0", "verilator@5.052")
CLAUSE = re.compile(r"^(?:\d+|[A-O])(?:\.\d+)*$")
XZ_LITERAL = re.compile(r"\d*'[sS]?(?:[bB][01_xXzZ?]*[xXzZ?]|[hH][0-9a-fA-F_xXzZ?]*[xXzZ?]"
                        r"|[oO][0-7_xXzZ?]*[xXzZ?]|[dD]\s*[xXzZ?])|'[xXzZ]\b")
# A time printed with %t, $timeformat or $printtimescale, a fractional delay, or
# a delay with a time unit, which follows its number without a space (5.8).
TIME_OUTPUT = re.compile(r"%-?\d*t|\$timeformat\b|\$printtimescale\b"
                         r"|#\s*\d+\.\d+|#\s*\(?\s*\d+(?:\.\d+)?(?:s|ms|us|ns|ps|fs)\b")
TIME_UNIT = re.compile(r"^\s*`timescale\b|\btimeunit\b|\btimeprecision\b", re.MULTILINE)


def split(test: Path) -> tuple[str, list[str]]:
    """The metadata comment and the lines after it."""
    text = test.read_text(encoding="utf-8", errors="replace")
    m = re.search(r"/\*.*?\*/", text, re.DOTALL)
    if not m:
        return "", text.splitlines()
    return m.group(0), text[m.end():].splitlines()


def code_of(lines: list[str], strings: bool = False) -> str:
    """The code of the lines, without comments, and without the contents of
    string literals unless strings is true."""
    text = "\n".join(lines)
    parts = re.split(r'("(?:\\.|[^"\\\n])*")', text)
    for i in range(0, len(parts), 2):
        parts[i] = re.sub(r"//[^\n]*", "", re.sub(r"/\*.*?\*/", " ", parts[i], flags=re.DOTALL))
    if not strings:
        parts[1::2] = ['""'] * len(parts[1::2])
    return "".join(parts)


def modules_of(paths: list[Path]) -> set[str]:
    names = set()
    for p in paths:
        if p.is_file():
            names |= set(re.findall(r"^\s*(?:module|program|interface|config)\s+(?:automatic\s+|static\s+)?"
                                    r"(\w+)", code_of(p.read_text(encoding="utf-8",
                                                                  errors="replace").splitlines()),
                                    re.MULTILINE))
    return names


def check(test: Path) -> list[tuple[str, str]]:
    problems = []
    def bad(rule: str, detail: str) -> None:
        problems.append((rule, detail))

    header, lines = split(test)
    fields = suite_results.header(test)
    directory = test.parent.name
    for f in REQUIRED:
        if f not in fields:
            bad("missing-field", f":{f}:")
    if fields.get("name", test.stem) != test.stem:
        bad("name", f":name: {fields['name']}")

    allowed = {"type": ("simulation", "elaboration"), "spec_check": ("ai", "human"),
               "fourstate": ("yes", "no"), "nondeterministic": ("yes", "no")}
    for f, values in allowed.items():
        if f in fields and fields[f] not in values:
            bad("value", f":{f}: {fields[f]}")
    if "oracle" in fields:
        words = fields["oracle"].split()
        if not words or words[0] != "spec" or any(w not in ORACLES for w in words) \
                or len(set(words)) != len(words):
            bad("value", f":oracle: {fields['oracle']}")
    exit_value = fields.get("expected_exit")
    if exit_value is not None and exit_value != "nonzero" and not exit_value.isdigit():
        bad("value", f":expected_exit: {exit_value}")
    generator = fields.get("generator")
    if generator is not None and not re.fullmatch(r"\w+@\S+", generator):
        bad("value", f":generator: {generator}")

    if "lrm" in fields:
        words = fields["lrm"].split()
        if len(words) < 2 or words[0] != "1800-2023" or not all(CLAUSE.match(w) for w in words[1:]):
            bad("lrm", f":lrm: {fields['lrm']}")
        elif f"ch{words[1].split('.')[0]}" != directory:
            bad("chapter", f"first clause {words[1]} in {directory}")
    if "tags" in fields and fields["tags"] != directory:
        bad("tags", f":tags: {fields['tags']} in {directory}")

    code = code_of(lines)
    if fields.get("fourstate") == "no":
        m = XZ_LITERAL.search(code)
        if m:
            bad("fourstate", f"x or z literal {m.group(0)!r}")

    illegal = "should_fail_because" in fields
    if illegal:
        if fields.get("type") != "elaboration":
            bad("should-fail", ":should_fail_because: without :type: elaboration")
        if "expected_stderr_regex" not in fields:
            bad("should-fail", ":should_fail_because: without :expected_stderr_regex:")
        if "expected_stdout" in fields:
            bad("should-fail", ":should_fail_because: with :expected_stdout:")
    elif fields.get("type") == "elaboration":
        bad("should-fail", ":type: elaboration without :should_fail_because:")
    else:
        value = fields.get("expected_stdout")
        if value is None:
            bad("expected", "no :expected_stdout:")
        elif value.startswith("@"):
            path = test.parent / value[1:]
            if not path.is_file():
                bad("expected", f"{value[1:]} does not exist")
            elif not path.read_text(encoding="utf-8", errors="replace").strip():
                bad("expected", f"{value[1:]} is empty")

    for f in ("files", "incdirs"):
        for name in fields.get(f, "").split():
            if not (test.parent / name).exists():
                bad("file", f":{f}: {name} does not exist")
    for f in ("dpi_c", "vpi_c"):
        if f in fields and not (test.parent / fields[f].removeprefix("@")).is_file():
            bad("file", f":{f}: {fields[f]} does not exist")
    top = fields.get("top_module")
    if top and top not in modules_of([test] + suite_results.files(test)[0]):
        bad("top-module", f":top_module: {top} is not declared")

    for n, line in enumerate(lines, header.count("\n") + 1):
        width = len(line.expandtabs())
        stripped = line.lstrip()
        if stripped.startswith("//"):
            if width > 80:
                bad("width", f"line {n}: comment of {width} columns")
            if re.match(r"//\s*verilator\b", stripped, re.IGNORECASE):
                bad("verilator-comment", f"line {n}")
        elif width > 100:
            bad("width", f"line {n}: code of {width} columns")

    if TIME_OUTPUT.search(code_of(lines, strings=True)) and not TIME_UNIT.search("\n".join(lines)):
        bad("timescale", "prints a time or has a fractional delay without `timescale or timeunit")
    if "TODO" in header or any("TODO" in l for l in lines if l.lstrip().startswith("//")):
        bad("todo", "TODO left from tools/new_test.py")
    return problems


def read_baseline() -> set[str]:
    if not BASELINE.exists():
        return set()
    return {l.strip() for l in BASELINE.read_text(encoding="utf-8").splitlines()
            if l.strip() and not l.startswith("#")}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--update-baseline", action="store_true",
                    help="write the problems found now to tools/lint_baseline.txt")
    ap.add_argument("tests", nargs="*", type=Path)
    args = ap.parse_args()

    tests = [t.resolve() for t in args.tests] or suite_results.find_tests()
    found = {}
    for t in tests:
        for rule, detail in check(t):
            found.setdefault(f"{suite_results.test_id(t)} {rule}", []).append(detail)
    if args.update_baseline:
        BASELINE.write_text(
            "# Problems of existing tests that tools/lint_metadata.py reports as known.\n"
            "# Each line is a test and a rule; the tests are not changed for them.\n"
            + "".join(f"{k}\n" for k in sorted(found)), encoding="utf-8")
        print(f"wrote {len(found)} known problems to {BASELINE.relative_to(ROOT)}")
        return 0

    baseline = read_baseline()
    new = sorted(k for k in found if k not in baseline)
    known = sorted(k for k in found if k in baseline)
    checked = {suite_results.test_id(t) for t in tests}
    gone = sorted(k for k in baseline if k not in found and k.split()[0] in checked)
    for k in new:
        print(f"{k}: {'; '.join(found[k])}")
    for k in known:
        print(f"KNOWN {k}: {'; '.join(found[k])}")
    for k in gone:
        print(f"GONE {k}: listed in {BASELINE.relative_to(ROOT)} but no longer found")
    print(f"{len(tests)} tests checked: {len(new)} new problems, {len(known)} known, "
          f"{len(gone)} gone")
    return 1 if new or gone else 0


if __name__ == "__main__":
    sys.exit(main())
