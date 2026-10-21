# Catalog of the tests

One page for each clause of IEEE 1800-2023 that has tests, listing every test with what it checks (`:description:`), the clauses it cites (`:lrm:`), the release its expected output was recorded with (`:oracle:`; "standard only" when neither Icarus Verilog 13.0 nor Verilator 5.052 produces it) and notes: illegal designs, tests of the exit code, tests with C code (DPI, VPI), with several source files, macros, include directories, a named top module or plusargs, and tests whose result depends on x or z values. The comment at the top of each test explains in more detail what the cited clauses require and how the test observes it.

These pages are written by `tools/suite_catalog.py` from the metadata of the tests (`python3 tools/suite_catalog.py --update`), and the check workflow fails when they are out of date. [Clauses cited by the tests](clauses.md) shows which clauses of the standard the tests cite and which they do not yet.

| Clause | Title | Tests | Generated |
| ---: | --- | ---: | ---: |
| 3 | [Design and verification building blocks](ch3.md) | 20 |  |
| 4 | [Scheduling semantics](ch4.md) | 381 | 325 |
| 5 | [Lexical conventions](ch5.md) | 35 |  |
| 6 | [Data types](ch6.md) | 303 | 7 |
| 7 | [Aggregate data types](ch7.md) | 304 | 14 |
| 8 | [Classes](ch8.md) | 154 |  |
| 9 | [Processes](ch9.md) | 114 |  |
| 10 | [Assignment statements](ch10.md) | 105 |  |
| 11 | [Operators and expressions](ch11.md) | 704 | 316 |
| 12 | [Procedural programming statements](ch12.md) | 120 |  |
| 13 | [Tasks and functions (subroutines)](ch13.md) | 126 | 14 |
| 14 | [Clocking blocks](ch14.md) | 31 |  |
| 15 | [Interprocess synchronization and communication](ch15.md) | 36 |  |
| 16 | [Assertions](ch16.md) | 99 |  |
| 17 | [Checkers](ch17.md) | 23 |  |
| 18 | [Constrained random value generation](ch18.md) | 60 |  |
| 19 | [Functional coverage](ch19.md) | 43 |  |
| 20 | [Utility system tasks and system functions](ch20.md) | 187 |  |
| 21 | [Input/output system tasks and system functions](ch21.md) | 85 |  |
| 22 | [Compiler directives](ch22.md) | 39 |  |
| 23 | [Modules and hierarchy](ch23.md) | 71 |  |
| 24 | [Programs](ch24.md) | 23 |  |
| 25 | [Interfaces](ch25.md) | 50 |  |
| 26 | [Packages](ch26.md) | 33 |  |
| 27 | [Generate constructs](ch27.md) | 68 |  |
| 28 | [Gate-level and switch-level modeling](ch28.md) | 176 | 136 |
| 29 | [User-defined primitives](ch29.md) | 28 |  |
| 30 | [Specify blocks](ch30.md) | 23 |  |
| 31 | [Timing checks](ch31.md) | 23 |  |
| 32 | [Backannotation using the standard delay format](ch32.md) | 21 |  |
| 33 | [Configuring the contents of a design](ch33.md) | 21 |  |
| 34 | Protected envelopes | — | |
| 35 | [Direct programming interface](ch35.md) | 31 |  |
| 36 | [Programming language interface (PLI/VPI) overview](ch36.md) | 23 |  |
| 37 | [VPI object model diagrams](ch37.md) | 74 |  |
| 38 | [VPI routine definitions](ch38.md) | 41 |  |
| 39 | [Assertion API](ch39.md) | 16 |  |
| 40 | [Code coverage control and API](ch40.md) | 19 |  |
