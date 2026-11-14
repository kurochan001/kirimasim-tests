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
    duplicate-name      :name: is also the :name: of another test of the suite
    empty-field         a field has no value (the next line would be read as
                        its value)
    stderr-regex        :expected_stderr_regex: is not a regular expression
                        that Python compiles
    value               a field has a value outside its allowed set (:type:,
                        :oracle:, :spec_check:, :fourstate:,
                        :nondeterministic:, :expected_exit:, :generator:,
                        :compilation_unit:)
    lrm                 :lrm: is not "1800-2023" followed by clause numbers
    chapter             the first clause of :lrm: is not of the chapter of the
                        directory (chNN)
    tags                :tags: is not the directory (chNN)
    fourstate           :fourstate: no, but the code has an x or z literal
    expected            a test that is run has no :expected_stdout: (or no
                        :expected_stdout_<simulator>: and no
                        :expected_stdout:), or its file is missing or empty
    expected-key        a field :expected_stdout_<name>: names no simulator
    should-fail         :should_fail_because: without :type: elaboration or
                        without :expected_stderr_regex:, or with an expected
                        output; or :type: elaboration without
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
and reported as known, without being changed. Each line of the baseline is a
test, a rule and the number of problems of that rule in the test ("<test>
<rule> <count>"; a line without a count stands for one problem). The script
exits with 1 when a test has more problems of a rule than the baseline lists
(so a new problem is reported also in a test that has a known one of the same
rule), or when the baseline lists more than are found (then update it with
--update-baseline). Only the number is compared: the details of a width
problem are line numbers, which move when the test is edited. Checking only
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
# verilator@5.054 records tests added while the pin moves from 5.052 to 5.054;
# a test names one Verilator release at most.
ORACLES = ("spec", "iverilog@13.0", "verilator@5.052", "verilator@5.054")
EXPECTED = suite_results.EXPECTED
EXPECTED_SIMULATORS = suite_results.SIMULATORS
EXPECTED_FIELDS = suite_results.EXPECTED_FIELDS
CLAUSE = re.compile(r"^(?:\d+|[A-O])(?:\.\d+)*$")
XZ_LITERAL = re.compile(r"\d*'[sS]?(?:[bB][01_xXzZ?]*[xXzZ?]|[hH][0-9a-fA-F_xXzZ?]*[xXzZ?]"
                        r"|[oO][0-7_xXzZ?]*[xXzZ?]|[dD]\s*[xXzZ?])|'[xXzZ]\b")
# A time printed with %t, $timeformat or $printtimescale, a fractional delay, or
# a delay with a time unit, which follows its number without a space (5.8).
TIME_OUTPUT = re.compile(r"%-?\d*t|\$timeformat\b|\$printtimescale\b"
                         r"|#\s*\d+\.\d+|#\s*\(?\s*\d+(?:\.\d+)?(?:s|ms|us|ns|ps|fs)\b")
TIME_UNIT = re.compile(r"^\s*`timescale\b|\btimeunit\b|\btimeprecision\b", re.MULTILINE)
# A field with nothing after it on its line. suite_results.header reads the
# next line as its value, so this is found in the text of the comment.
EMPTY_FIELD = re.compile(r"^:(\w+):[ \t]*$", re.MULTILINE)


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
    empty = EMPTY_FIELD.findall(header)
    for f in empty:
        bad("empty-field", f":{f}: has no value")
    regex = fields.get("expected_stderr_regex")
    if regex is not None and "expected_stderr_regex" not in empty:
        try:
            re.compile(regex)
        except re.error as error:
            bad("stderr-regex", f":expected_stderr_regex: {regex} does not compile: {error}")

    allowed = {"type": ("simulation", "elaboration", "formal"), "spec_check": ("ai", "human"),
               "fourstate": ("yes", "no"), "nondeterministic": ("yes", "no"),
               "compilation_unit": ("single",)}
    for f, values in allowed.items():
        if f in fields and fields[f] not in values:
            bad("value", f":{f}: {fields[f]}")
    if "oracle" in fields:
        words = fields["oracle"].split()
        if not words or words[0] != "spec" or any(w not in ORACLES for w in words) \
                or len(set(words)) != len(words) \
                or sum(w.startswith("verilator@") for w in words) > 1:
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
    expected_names = [f for f in EXPECTED_FIELDS if f in fields]
    for f in fields:
        if f.startswith(EXPECTED + "_") and f not in EXPECTED_FIELDS:
            bad("expected-key", f":{f}: is not one of "
                + ", ".join(f":{n}:" for n in EXPECTED_FIELDS[1:]))
    if illegal:
        if fields.get("type") != "elaboration":
            bad("should-fail", ":should_fail_because: without :type: elaboration")
        if "expected_stderr_regex" not in fields:
            bad("should-fail", ":should_fail_because: without :expected_stderr_regex:")
        if expected_names:
            bad("should-fail", ":should_fail_because: with " + ", ".join(
                f":{n}:" for n in expected_names))
    elif fields.get("type") == "elaboration":
        bad("should-fail", ":type: elaboration without :should_fail_because:")
    elif fields.get("type") == "formal":
        if not fields.get("formal_case"):
            bad("formal", ":type: formal without :formal_case:")
        if expected_names:
            bad("formal", ":type: formal with " + ", ".join(
                f":{n}:" for n in expected_names))
    else:
        if not expected_names:
            bad("expected", "no :expected_stdout: and no :expected_stdout_<simulator>:")
        for name in expected_names:
            value = fields[name]
            if value.startswith("@"):
                path = test.parent / value[1:]
                if not path.is_file():
                    bad("expected", f"{value[1:]} does not exist (:{name}:)")
                elif not path.read_text(encoding="utf-8", errors="replace").strip():
                    bad("expected", f"{value[1:]} is empty (:{name}:)")

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


def names_of(tests: list[Path]) -> dict[str, list[str]]:
    """The tests that have each :name:, by their ids."""
    names: dict[str, list[str]] = {}
    for t in tests:
        name = suite_results.header(t).get("name")
        if name:
            names.setdefault(name, []).append(suite_results.test_id(t))
    return names


def duplicate_names(names: dict[str, list[str]]) -> dict[str, str]:
    """For each test whose :name: another test has too, the detail of the
    problem. :name: is unique in the suite, whatever the chapter."""
    problems = {}
    for name, tests in names.items():
        for test in tests if len(tests) > 1 else ():
            problems[test] = f":name: {name} is also in " + ", ".join(
                sorted(t for t in tests if t != test))
    return problems


def parse_baseline(text: str) -> dict[str, int]:
    """The number of known problems for each "<test> <rule>" of the text of a
    baseline. A line without a number stands for one problem."""
    baseline: dict[str, int] = {}
    for n, line in enumerate(text.splitlines(), 1):
        words = line.split()
        if not words or line.startswith("#"):
            continue
        if len(words) == 2:
            words.append("1")
        if len(words) != 3 or not words[2].isdigit() or int(words[2]) < 1:
            raise ValueError(f"{BASELINE.name}:{n}: not \"<test> <rule> <count>\": {line}")
        key = f"{words[0]} {words[1]}"
        if key in baseline:
            raise ValueError(f"{BASELINE.name}:{n}: {key} is listed twice")
        baseline[key] = int(words[2])
    return baseline


def read_baseline() -> dict[str, int]:
    if not BASELINE.exists():
        return {}
    return parse_baseline(BASELINE.read_text(encoding="utf-8"))


def format_baseline(found: dict[str, list[str]]) -> str:
    return ("# Problems of existing tests that tools/lint_metadata.py reports as known.\n"
            "# Each line is a test, a rule and the number of problems of that rule in\n"
            "# the test; the tests are not changed for them.\n"
            + "".join(f"{k} {len(found[k])}\n" for k in sorted(found) if found[k]))


def compare(found: dict[str, list[str]], baseline: dict[str, int],
            checked: set[str]) -> tuple[list[str], list[str], list[str]]:
    """The lines to print for the new, the known and the gone problems. found
    maps "<test> <rule>" to the details of its problems, baseline to their
    known number; gone problems are reported for the checked tests only."""
    new, known, gone = [], [], []
    for k in sorted(found):
        details, listed = found[k], baseline.get(k, 0)
        if len(details) > listed:
            # Which of them are the new ones is not known: all are shown.
            count = f" ({len(details)} found, {listed} known)" if listed else ""
            new.append(f"{k}{count}: {'; '.join(details)}")
        else:
            known.append(f"KNOWN {k}: {'; '.join(details)}")
    for k in sorted(baseline):
        count = len(found.get(k, ()))
        if count < baseline[k] and k.split()[0] in checked:
            gone.append(f"GONE {k}: {BASELINE.relative_to(ROOT)} lists {baseline[k]} "
                        f"but {count} found" if count else
                        f"GONE {k}: listed in {BASELINE.relative_to(ROOT)} but no longer found")
    return new, known, gone


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--update-baseline", action="store_true",
                    help="write the problems found now to tools/lint_baseline.txt")
    ap.add_argument("tests", nargs="*", type=Path)
    args = ap.parse_args()

    tests = [t.resolve() for t in args.tests] or suite_results.find_tests()
    found: dict[str, list[str]] = {}
    for t in tests:
        for rule, detail in check(t):
            found.setdefault(f"{suite_results.test_id(t)} {rule}", []).append(detail)
    # A name is compared with those of the whole suite, also when only some
    # tests are checked; only the checked tests are reported.
    everything = sorted(set(suite_results.find_tests()) | set(tests))
    duplicates = duplicate_names(names_of(everything))
    for t in tests:
        detail = duplicates.get(suite_results.test_id(t))
        if detail:
            found.setdefault(f"{suite_results.test_id(t)} duplicate-name", []).append(detail)
    if args.update_baseline:
        if args.tests:
            # The baseline of the tests that are not checked would be lost.
            ap.error("--update-baseline checks every test; give no TEST")
        BASELINE.write_text(format_baseline(found), encoding="utf-8")
        print(f"wrote {len(found)} known problems to {BASELINE.relative_to(ROOT)}")
        return 0

    try:
        baseline = read_baseline()
    except ValueError as error:
        print(f"lint_metadata: {error}", file=sys.stderr)
        return 2
    new, known, gone = compare(found, baseline, {suite_results.test_id(t) for t in tests})
    for line in new + known + gone:
        print(line)
    print(f"{len(tests)} tests checked: {len(new)} new problems, {len(known)} known, "
          f"{len(gone)} gone")
    return 1 if new or gone else 0


if __name__ == "__main__":
    sys.exit(main())
