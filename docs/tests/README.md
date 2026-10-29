# Catalog of the tests

One page for each clause of IEEE 1800-2023 that has tests, listing every test with what it checks (`:description:`), the clauses it cites (`:lrm:`), the release its expected output was recorded with (`:oracle:`; "standard only" when neither Icarus Verilog 13.0 nor Verilator 5.052 produces it) and notes: illegal designs, tests of the exit code, tests with C code (DPI, VPI), with several source files, macros, include directories, a named top module or plusargs, and tests whose result depends on x or z values. The comment at the top of each test explains in more detail what the cited clauses require and how the test observes it.

These pages are written by `tools/suite_catalog.py` from the metadata of the tests (`python3 tools/suite_catalog.py --update`), and the check workflow fails when they are out of date. [Clauses cited by the tests](clauses.md) shows which clauses of the standard the tests cite and which they do not yet.

| Clause | Title | Tests | Generated |
| ---: | --- | ---: | ---: |
| 3 | [Design and verification building blocks](ch3.md) | 88 |  |
| 4 | [Scheduling semantics](ch4.md) | 412 | 325 |
| 5 | [Lexical conventions](ch5.md) | 346 | 248 |
| 6 | [Data types](ch6.md) | 641 | 39 |
| 7 | [Aggregate data types](ch7.md) | 626 | 158 |
| 8 | [Classes](ch8.md) | 321 |  |
| 9 | [Processes](ch9.md) | 210 |  |
| 10 | [Assignment statements](ch10.md) | 240 | 36 |
| 11 | [Operators and expressions](ch11.md) | 1148 | 627 |
| 12 | [Procedural programming statements](ch12.md) | 217 | 36 |
| 13 | [Tasks and functions (subroutines)](ch13.md) | 237 | 50 |
| 14 | [Clocking blocks](ch14.md) | 78 |  |
| 15 | [Interprocess synchronization and communication](ch15.md) | 56 |  |
| 16 | [Assertions](ch16.md) | 661 |  |
| 17 | [Checkers](ch17.md) | 81 |  |
| 18 | [Constrained random value generation](ch18.md) | 200 |  |
| 19 | [Functional coverage](ch19.md) | 157 |  |
| 20 | [Utility system tasks and system functions](ch20.md) | 330 | 60 |
| 21 | [Input/output system tasks and system functions](ch21.md) | 213 |  |
| 22 | [Compiler directives](ch22.md) | 358 | 248 |
| 23 | [Modules and hierarchy](ch23.md) | 292 | 36 |
| 24 | [Programs](ch24.md) | 43 |  |
| 25 | [Interfaces](ch25.md) | 119 |  |
| 26 | [Packages](ch26.md) | 83 |  |
| 27 | [Generate constructs](ch27.md) | 103 |  |
| 28 | [Gate-level and switch-level modeling](ch28.md) | 245 | 136 |
| 29 | [User-defined primitives](ch29.md) | 81 |  |
| 30 | [Specify blocks](ch30.md) | 60 |  |
| 31 | [Timing checks](ch31.md) | 66 |  |
| 32 | [Backannotation using the standard delay format](ch32.md) | 50 |  |
| 33 | [Configuring the contents of a design](ch33.md) | 43 |  |
| 34 | [Protected envelopes](ch34.md) | 4 |  |
| 35 | [Direct programming interface](ch35.md) | 131 |  |
| 36 | [Programming language interface (PLI/VPI) overview](ch36.md) | 89 |  |
| 37 | [VPI object model diagrams](ch37.md) | 227 |  |
| 38 | [VPI routine definitions](ch38.md) | 109 |  |
| 39 | [Assertion API](ch39.md) | 39 |  |
| 40 | [Code coverage control and API](ch40.md) | 31 |  |
