#!/usr/bin/env python3
"""Writes the skeleton of a new test: the .sv file with its metadata comment
and, for a test that is run, an empty .expected file next to it.

Usage:
    python3 tools/new_test.py CHAPTER NAME --lrm "CLAUSE ..." [--illegal]

For example, `python3 tools/new_test.py ch16 test_sequence_and --lrm "16.9.5"`
writes tests/ch16/test_sequence_and.sv and tests/ch16/test_sequence_and.expected.
CHAPTER is the directory, chNN, which is the chapter of the first clause of
--lrm; NAME starts with test_. With --illegal the test is an illegal design
(`:type: elaboration`, `:should_fail_because:` and `:expected_stderr_regex:`)
and has no .expected file.

The skeleton has `:oracle: spec`, `:spec_check: ai`, `:fourstate: no` and
`:nondeterministic: no`, and TODO where the author has to write: the
description, the comment that says what the cited clauses require and how the
test observes it, the design, the expected output, and for an illegal design
the reason and the line of the error. tools/lint_metadata.py reports a test
that still has TODO or an empty .expected file. Existing files are never
overwritten.
"""

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CLAUSE = re.compile(r"^(?:\d+|[A-O])(?:\.\d+)*$")


def skeleton(chapter: str, name: str, clauses: list[str], illegal: bool) -> str:
    first = clauses[0]
    head = [
        "/*",
        f":name: {name}",
        f":description: TODO what the test checks (IEEE 1800-2023 Section {first})",
        f":tags: {chapter}",
        f":type: {'elaboration' if illegal else 'simulation'}",
        f":lrm: 1800-2023 {' '.join(clauses)}",
        ":oracle: spec",
        ":spec_check: ai",
        ":fourstate: no",
        ":nondeterministic: no",
    ]
    if illegal:
        head += [":should_fail_because: TODO the rule that the design breaks",
                 f":expected_stderr_regex: {re.escape(name)}\\.sv:TODO:"]
    else:
        head.append(f":expected_stdout: @{name}.expected")
    head += ["*/",
             f"// IEEE 1800-2023 §{first}: TODO what the cited clauses require, and how",
             "// the test observes it.",
             "",
             f"module {name};",
             "  initial begin",
             "    // TODO the design" + (", and the line of the error, marked // illegal"
                                         if illegal else ", which prints only what the standard fixes"),
             "  end",
             "endmodule",
             ""]
    return "\n".join(head)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("chapter", help="the directory, chNN")
    ap.add_argument("name", help="the name of the test, test_<what it checks>")
    ap.add_argument("--lrm", required=True, help="the clauses the test checks, separated by spaces")
    ap.add_argument("--illegal", action="store_true", help="write an illegal design")
    args = ap.parse_args()

    clauses = args.lrm.split()
    if not re.fullmatch(r"ch\d+", args.chapter):
        ap.error(f"the chapter is chNN, not {args.chapter!r}")
    if not re.fullmatch(r"test_\w+", args.name):
        ap.error(f"the name starts with test_ and is a SystemVerilog identifier, not {args.name!r}")
    if not clauses or not all(CLAUSE.match(c) for c in clauses):
        ap.error(f"--lrm takes clause numbers such as 16.9.3, not {args.lrm!r}")
    if f"ch{clauses[0].split('.')[0]}" != args.chapter:
        ap.error(f"the first clause {clauses[0]} is not of {args.chapter}")

    directory = ROOT / "tests" / args.chapter
    sv = directory / f"{args.name}.sv"
    expected = directory / f"{args.name}.expected"
    taken = [p for p in (sv, expected) if p.exists()]
    if taken or any(p.name == f"{args.name}.sv" for p in (ROOT / "tests").rglob("*.sv")):
        print(f"{args.name} exists already", file=sys.stderr)
        return 1
    directory.mkdir(parents=True, exist_ok=True)
    sv.write_text(skeleton(args.chapter, args.name, clauses, args.illegal), encoding="utf-8")
    written = [sv]
    if not args.illegal:
        expected.write_text("", encoding="utf-8")
        written.append(expected)
    for p in written:
        print(f"wrote {p.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
