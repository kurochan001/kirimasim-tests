<a id="テストの一覧"></a>

# Catalog of the tests

[English](README.md) / [日本語](README.ja.md)

First reading: [follow a real test from input to expectation](../faq.en.md#q49-read-a-real-test). The oracle column records fixed-release confirmation; see [what this does not certify](../faq.en.md#q4-are-expected-outputs-copied-from-a-simulator).

One page for each clause of IEEE 1800-2023 that has tests, listing every test with what it checks (`:description:`), the clauses it cites (`:lrm:`), the release its expected output was recorded with (`:oracle:`; "standard only" when neither Icarus Verilog 13.0 nor Verilator 5.052 produces it) and notes: illegal designs, tests of the exit code, tests with C code (DPI, VPI), with several source files, macros, include directories, a named top module or plusargs, and tests whose result depends on x or z values. The comment at the top of each test explains in more detail what the cited clauses require and how the test observes it.

These pages are written by `tools/suite_catalog.py` from the metadata of the tests (`python3 tools/suite_catalog.py --update`), and the check workflow fails when they are out of date. [Clauses cited by the tests](clauses.md) shows which clauses of the standard the tests cite and which they do not yet.

| Clause | Title | Tests | Generated |
| ---: | --- | ---: | ---: |
| 3 | [Design and verification building blocks](ch3.md) | 154 | 48 |
| 4 | [Scheduling semantics](ch4.md) | 481 | 386 |
| 5 | [Lexical conventions](ch5.md) | 526 | 415 |
| 6 | [Data types](ch6.md) | 913 | 265 |
| 7 | [Aggregate data types](ch7.md) | 1135 | 604 |
| 8 | [Classes](ch8.md) | 508 | 138 |
| 9 | [Processes](ch9.md) | 486 | 233 |
| 10 | [Assignment statements](ch10.md) | 761 | 521 |
| 11 | [Operators and expressions](ch11.md) | 2635 | 2054 |
| 12 | [Procedural programming statements](ch12.md) | 324 | 125 |
| 13 | [Tasks and functions (subroutines)](ch13.md) | 760 | 504 |
| 14 | [Clocking blocks](ch14.md) | 173 | 72 |
| 15 | [Interprocess synchronization and communication](ch15.md) | 214 | 133 |
| 16 | [Assertions](ch16.md) | 815 | 133 |
| 17 | [Checkers](ch17.md) | 134 | 27 |
| 18 | [Constrained random value generation](ch18.md) | 296 | 57 |
| 19 | [Functional coverage](ch19.md) | 256 | 50 |
| 20 | [Utility system tasks and system functions](ch20.md) | 709 | 392 |
| 21 | [Input/output system tasks and system functions](ch21.md) | 960 | 708 |
| 22 | [Compiler directives](ch22.md) | 1327 | 1206 |
| 23 | [Modules and hierarchy](ch23.md) | 445 | 161 |
| 24 | [Programs](ch24.md) | 222 | 171 |
| 25 | [Interfaces](ch25.md) | 280 | 134 |
| 26 | [Packages](ch26.md) | 271 | 179 |
| 27 | [Generate constructs](ch27.md) | 293 | 180 |
| 28 | [Gate-level and switch-level modeling](ch28.md) | 423 | 287 |
| 29 | [User-defined primitives](ch29.md) | 148 | 61 |
| 30 | [Specify blocks](ch30.md) | 73 ||
| 31 | [Timing checks](ch31.md) | 85 ||
| 32 | [Backannotation using the standard delay format](ch32.md) | 78 | 18 |
| 33 | [Configuring the contents of a design](ch33.md) | 90 | 41 |
| 34 | [Protected envelopes](ch34.md) | 4 ||
| 35 | [Direct programming interface](ch35.md) | 208 | 48 |
| 36 | [Programming language interface (PLI/VPI) overview](ch36.md) | 91 ||
| 37 | [VPI object model diagrams](ch37.md) | 266 ||
| 38 | [VPI routine definitions](ch38.md) | 166 ||
| 39 | [Assertion API](ch39.md) | 50 ||
| 40 | [Code coverage control and API](ch40.md) | 40 ||
