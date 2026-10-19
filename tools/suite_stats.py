#!/usr/bin/env python3
"""Counts the tests of the suite by chapter and by where their expected
output comes from, and keeps the tables in README.md up to date.

Usage:
    python3 tools/suite_stats.py            print the tables as Markdown
    python3 tools/suite_stats.py --update   rewrite them in README.md
    python3 tools/suite_stats.py --check    exit with 1 if README.md is out of date

The tables in README.md are the lines between the markers
"<!-- suite-stats:begin -->" and "<!-- suite-stats:end -->".
"""

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
README = ROOT / "README.md"
BEGIN = "<!-- suite-stats:begin -->"
END = "<!-- suite-stats:end -->"

# The clauses of IEEE 1800-2023 that tests can belong to. Clauses 1 and 2
# (overview, normative references) set out no behavior to test.
CHAPTERS = {
    3: "Design and verification building blocks",
    4: "Scheduling semantics",
    5: "Lexical conventions",
    6: "Data types",
    7: "Aggregate data types",
    8: "Classes",
    9: "Processes",
    10: "Assignment statements",
    11: "Operators and expressions",
    12: "Procedural programming statements",
    13: "Tasks and functions (subroutines)",
    14: "Clocking blocks",
    15: "Interprocess synchronization and communication",
    16: "Assertions",
    17: "Checkers",
    18: "Constrained random value generation",
    19: "Functional coverage",
    20: "Utility system tasks and system functions",
    21: "Input/output system tasks and system functions",
    22: "Compiler directives",
    23: "Modules and hierarchy",
    24: "Programs",
    25: "Interfaces",
    26: "Packages",
    27: "Generate constructs",
    28: "Gate-level and switch-level modeling",
    29: "User-defined primitives",
    30: "Specify blocks",
    31: "Timing checks",
    32: "Backannotation using the standard delay format",
    33: "Configuring the contents of a design",
    34: "Protected envelopes",
    35: "Direct programming interface",
    36: "Programming language interface (PLI/VPI) overview",
    37: "VPI object model diagrams",
    38: "VPI routine definitions",
    39: "Assertion API",
    40: "Code coverage control and API",
}


def header(test: Path) -> dict[str, str]:
    m = re.search(r"/\*(.*?)\*/", test.read_text(encoding="utf-8"), re.DOTALL)
    if not m:
        return {}
    return {k: v.strip() for k, v in re.findall(r"^:(\w+):\s*(.*)$", m.group(1), re.MULTILINE)}


def oracle_kind(fields: dict[str, str]) -> str:
    """icarus, verilator or spec: the simulator the expected output was
    recorded with, Icarus Verilog first, or spec when neither produces it."""
    oracles = fields.get("oracle", "").split()
    if "iverilog@13.0" in oracles:
        return "icarus"
    if "verilator@5.052" in oracles:
        return "verilator"
    return "spec"


def collect(root: Path = ROOT) -> dict:
    by_chapter: dict[int, dict[str, int]] = {}
    totals = {"tests": 0, "icarus": 0, "verilator": 0, "spec": 0, "human": 0,
              "fourstate": 0, "dpi_c": 0, "vpi_c": 0}
    for test in sorted((root / "tests").rglob("*.sv")):
        fields = header(test)
        chapter = int(test.parent.name.removeprefix("ch"))
        row = by_chapter.setdefault(chapter, {"tests": 0, "icarus": 0, "verilator": 0, "spec": 0})
        kind = oracle_kind(fields)
        row["tests"] += 1
        row[kind] += 1
        totals["tests"] += 1
        totals[kind] += 1
        totals["human"] += fields.get("spec_check") == "human"
        totals["fourstate"] += fields.get("fourstate") == "yes"
        totals["dpi_c"] += "dpi_c" in fields
        totals["vpi_c"] += "vpi_c" in fields
    return {"totals": totals, "chapters": by_chapter}


def markdown(stats: dict) -> str:
    t = stats["totals"]
    lines = [
        f"The suite has **{t['tests']} tests** in {len(stats['chapters'])} chapters.",
        "",
        "| Expected output recorded with | Tests |",
        "| --- | ---: |",
        f"| Icarus Verilog 13.0 (`iverilog@13.0` in `:oracle:`) | {t['icarus']} |",
        f"| Verilator 5.052, where Icarus Verilog 13.0 differs from the standard or cannot "
        f"compile the test | {t['verilator']} |",
        f"| The standard only, where neither simulator follows it | {t['spec']} |",
        "",
        f"{t['fourstate']} tests depend on x or z values (`:fourstate: yes`). "
        f"{t['dpi_c'] + t['vpi_c']} tests come with C code: {t['dpi_c']} DPI tests (`:dpi_c:`) "
        f"and {t['vpi_c']} VPI tests (`:vpi_c:`). "
        + (f"{t['human']} tests have been checked against the standard by a person "
           "(`:spec_check: human`); the others were checked by an AI model."
           if t["human"] else
           "Every test has been checked against the standard by an AI model "
           "(`:spec_check: ai`); none has been checked by a person yet."),
        "",
        "| Clause | Title | Tests | Icarus | Verilator | Standard only |",
        "| ---: | --- | ---: | ---: | ---: | ---: |",
    ]
    for chapter, title in CHAPTERS.items():
        row = stats["chapters"].get(chapter)
        if row is None:
            lines.append(f"| {chapter} | {title} | — | | | |")
            continue
        lines.append(f"| {chapter} | {title} | {row['tests']} | {row['icarus'] or ''} | "
                     f"{row['verilator'] or ''} | {row['spec'] or ''} |")
    return "\n".join(lines) + "\n"


def replace_section(text: str, section: str) -> str:
    start, end = text.index(BEGIN) + len(BEGIN), text.index(END)
    return text[:start] + "\n" + section + text[end:]


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    group = ap.add_mutually_exclusive_group()
    group.add_argument("--update", action="store_true", help="rewrite the tables in README.md")
    group.add_argument("--check", action="store_true",
                       help="exit with 1 if the tables in README.md are out of date")
    args = ap.parse_args()

    section = markdown(collect())
    if not (args.update or args.check):
        sys.stdout.write(section)
        return 0
    text = README.read_text(encoding="utf-8")
    new = replace_section(text, section)
    if args.check:
        if new != text:
            print("README.md is out of date: run python3 tools/suite_stats.py --update")
            return 1
        return 0
    README.write_text(new, encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(main())
