# Clauses cited by the tests

[All chapters](README.md). For each clause of IEEE 1800-2023 from 3 to 40, this page counts the clauses without subclauses of its own, the numbers in `tools/clauses.txt`, by whether a test cites them in `:lrm:`. A clause can also be cited only through a parent clause, which says less about what is tested. Clauses that set out no behavior of their own, clause 34, behavior left to the tool or its setup, and the content of VCD files are out of scope (the tags of `tools/clauses.txt`). The page is written by `tools/suite_catalog.py`.

Of 980 clauses in scope, 980 are cited by a test, 0 only through a parent clause, and 0 not at all; 179 are out of scope.

| Clause | Title | Cited | Only through a parent | Not cited | Out of scope |
| ---: | --- | ---: | ---: | ---: | ---: |
| 3 | Design and verification building blocks | 15 |  |  | 3 |
| 4 | Scheduling semantics | 27 |  |  | 8 |
| 5 | Lexical conventions | 16 |  |  | 1 |
| 6 | Data types | 76 |  |  | 1 |
| 7 | Aggregate data types | 49 |  |  | 2 |
| 8 | Classes | 43 |  |  | 1 |
| 9 | Processes | 25 |  |  | 1 |
| 10 | Assignment statements | 18 |  |  | 1 |
| 11 | Operators and expressions | 42 |  |  | 2 |
| 12 | Procedural programming statements | 17 |  |  | 4 |
| 13 | Tasks and functions (subroutines) | 15 |  |  | 1 |
| 14 | Clocking blocks | 15 |  |  | 2 |
| 15 | Interprocess synchronization and communication | 21 |  |  | 1 |
| 16 | Assertions | 67 |  |  | 4 |
| 17 | Checkers | 9 |  |  | 2 |
| 18 | Constrained random value generation | 44 |  |  | 2 |
| 19 | Functional coverage | 22 |  |  | 3 |
| 20 | Utility system tasks and system functions | 31 |  |  | 3 |
| 21 | Input/output system tasks and system functions | 47 |  |  | 4 |
| 22 | Compiler directives | 21 |  |  | 3 |
| 23 | Modules and hierarchy | 32 |  |  | 3 |
| 24 | Programs | 7 |  |  | 1 |
| 25 | Interfaces | 12 |  |  | 8 |
| 26 | Packages | 6 |  |  | 1 |
| 27 | Generate constructs | 5 |  |  | 1 |
| 28 | Gate-level and switch-level modeling | 26 |  |  | 2 |
| 29 | User-defined primitives | 14 |  |  | 1 |
| 30 | Specify blocks | 21 |  |  | 3 |
| 31 | Timing checks | 19 |  |  | 3 |
| 32 | Backannotation using the standard delay format | 10 |  |  | 2 |
| 33 | Configuring the contents of a design | 9 |  |  | 18 |
| 34 | Protected envelopes | 0 |  |  | 69 |
| 35 | Direct programming interface | 18 |  |  | 4 |
| 36 | Programming language interface (PLI/VPI) overview | 17 |  |  | 5 |
| 37 | VPI object model diagrams | 94 |  |  | 3 |
| 38 | VPI routine definitions | 45 |  |  | 2 |
| 39 | Assertion API | 7 |  |  | 2 |
| 40 | Code coverage control and API | 18 |  |  | 2 |

## Not cited yet

Clauses in scope that no test cites; those marked with * have a parent clause that a test cites.

None.

## Out of scope

- `none`, it sets out no behavior of its own: 3.1, 3.2, 3.10, 4.1, 4.2, 4.4.3.1, 4.4.3.5, 4.4.3.6, 4.4.3.7, 4.4.3.8, 4.8, 5.1, 6.1, 7.1, 7.11, 8.1, 9.1, 10.1, 11.1, 11.6.3, 12.1, 12.2, 12.3, 13.1, 14.1, 14.8, 15.1, 16.1, 16.12.20, 16.12.21, 16.13.4, 17.1, 17.9, 18.1, 18.2, 19.1, 19.2, 19.6.1.1, 20.1, 20.12, 20.13, 21.1, 22.1, 22.14.1, 23.1, 24.1, 25.1, 25.3.1, 25.5.1, 25.5.2, 25.5.3, 25.7.1, 25.7.2, 25.7.3, 26.1, 27.1, 28.1, 28.2, 29.1, 30.1, 31.1, 32.1, 32.2, 33.1, 35.1, 35.2.2.1, 35.3.1, 35.5.1.6, 36.1, 36.2, 36.6, 37.1, 37.4.1, 38.1, 39.1, 39.2, 40.1, 40.4.8
- `excluded`, clause 34, protected envelopes: 34.1, 34.2, 34.3.1, 34.3.2, 34.4, 34.5.1.1, 34.5.1.2, 34.5.2.1, 34.5.2.2, 34.5.3.1, 34.5.3.2, 34.5.4.1, 34.5.4.2, 34.5.5.1, 34.5.5.2, 34.5.6.1, 34.5.6.2, 34.5.7.1, 34.5.7.2, 34.5.8.1, 34.5.8.2, 34.5.9.1, 34.5.9.2, 34.5.10.1, 34.5.10.2, 34.5.11.1, 34.5.11.2, 34.5.12.1, 34.5.12.2, 34.5.13.1, 34.5.13.2, 34.5.14.1, 34.5.14.2, 34.5.15.1, 34.5.15.2, 34.5.16.1, 34.5.16.2, 34.5.17.1, 34.5.17.2, 34.5.18.1, 34.5.18.2, 34.5.19.1, 34.5.19.2, 34.5.20.1, 34.5.20.2, 34.5.21.1, 34.5.21.2, 34.5.22.1, 34.5.22.2, 34.5.23.1, 34.5.23.2, 34.5.24.1, 34.5.24.2, 34.5.25.1, 34.5.25.2, 34.5.26.1, 34.5.26.2, 34.5.27.1, 34.5.27.2, 34.5.28.1, 34.5.28.2, 34.5.29.1, 34.5.29.2, 34.5.30.1, 34.5.30.2, 34.5.31.1, 34.5.31.2, 34.5.32.1, 34.5.32.2
- `tool`, left to the tool or its setup: 12.5.3.1, 22.11.1, 23.3.3.1, 23.3.3.6, 30.7.2, 30.7.3, 31.9.3, 31.9.4, 33.2.1, 33.2.2, 33.3.1.1, 33.3.2, 33.3.3, 33.5.1, 33.5.2, 33.5.3, 33.5.4, 33.6.1, 33.6.2, 33.6.3, 33.6.4, 33.6.5, 33.8.1, 33.8.2, 33.8.3, 36.12.2.2, 36.12.3, 37.45, 38.9
- `dump`, the content of VCD files: 21.7.2.4, 21.7.3.6.1, 21.7.4.4

## Cited numbers missing from the list

These numbers are cited by tests but are not in `tools/clauses.txt`; either the citation or the list needs a correction: 6.12.2.
