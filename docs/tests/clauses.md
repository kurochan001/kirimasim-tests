# Clauses cited by the tests

[All chapters](README.md). For each clause of IEEE 1800-2023 from 3 to 40, this page counts the clauses without subclauses of its own, the numbers in `tools/clauses.txt`, by whether a test cites them in `:lrm:`. A clause can also be cited only through a parent clause, which says less about what is tested. Clauses that set out no behavior of their own, clause 34, behavior left to the tool or its setup, and the content of VCD files are out of scope (the tags of `tools/clauses.txt`). The page is written by `tools/suite_catalog.py`.

Of 930 clauses in scope, 789 are cited by a test, 80 only through a parent clause, and 61 not at all; 188 are out of scope.

| Clause | Title | Cited | Only through a parent | Not cited | Out of scope |
| ---: | --- | ---: | ---: | ---: | ---: |
| 3 | Design and verification building blocks | 8 |  |  | 10 |
| 4 | Scheduling semantics | 23 | 4 |  | 8 |
| 5 | Lexical conventions | 10 | 1 | 5 | 1 |
| 6 | Data types | 52 | 22 |  | 3 |
| 7 | Aggregate data types | 41 | 8 |  | 2 |
| 8 | Classes | 32 | 9 |  | 3 |
| 9 | Processes | 23 | 1 | 1 | 1 |
| 10 | Assignment statements | 18 |  |  | 1 |
| 11 | Operators and expressions | 37 | 5 |  | 2 |
| 12 | Procedural programming statements | 14 |  |  | 7 |
| 13 | Tasks and functions (subroutines) | 12 |  | 2 | 2 |
| 14 | Clocking blocks | 14 |  |  | 3 |
| 15 | Interprocess synchronization and communication | 20 |  |  | 2 |
| 16 | Assertions | 60 | 3 | 3 | 5 |
| 17 | Checkers | 9 |  |  | 2 |
| 18 | Constrained random value generation | 43 |  | 1 | 2 |
| 19 | Functional coverage | 22 |  | 1 | 2 |
| 20 | Utility system tasks and system functions | 26 | 3 | 2 | 3 |
| 21 | Input/output system tasks and system functions | 33 | 3 |  | 15 |
| 22 | Compiler directives | 20 |  |  | 4 |
| 23 | Modules and hierarchy | 22 | 7 | 3 | 3 |
| 24 | Programs | 7 |  |  | 1 |
| 25 | Interfaces | 10 | 2 | 1 | 6 |
| 26 | Packages | 6 |  |  | 1 |
| 27 | Generate constructs | 4 |  |  | 2 |
| 28 | Gate-level and switch-level modeling | 21 | 4 | 1 | 2 |
| 29 | User-defined primitives | 13 |  |  | 2 |
| 30 | Specify blocks | 18 | 2 |  | 4 |
| 31 | Timing checks | 19 |  |  | 3 |
| 32 | Backannotation using the standard delay format | 9 |  | 1 | 2 |
| 33 | Configuring the contents of a design | 10 |  |  | 17 |
| 34 | Protected envelopes | 0 |  |  | 41 |
| 35 | Direct programming interface | 12 |  | 5 | 5 |
| 36 | Programming language interface (PLI/VPI) overview | 13 |  |  | 9 |
| 37 | VPI object model diagrams | 54 |  | 26 | 5 |
| 38 | VPI routine definitions | 31 | 5 | 8 | 3 |
| 39 | Assertion API | 6 | 1 |  | 2 |
| 40 | Code coverage control and API | 17 |  | 1 | 2 |

## Not cited yet

Clauses in scope that no test cites; those marked with * have a parent clause that a test cites.

- 4: 4.4.3.2*, 4.4.3.4*, 4.4.3.9*, 4.4.3.10*
- 5: 5.2, 5.3, 5.5, 5.6.4*, 5.11, 5.13
- 6: 6.3.2.1*, 6.3.2.2*, 6.6.8*, 6.7.1*, 6.7.2*, 6.7.3*, 6.9.2*, 6.13*, 6.17*, 6.19.1*, 6.19.2*, 6.19.5.1*, 6.19.5.2*, 6.19.5.5*, 6.19.5.7*, 6.20.7*, 6.22.2*, 6.22.3*, 6.22.4*, 6.22.5*, 6.22.6*, 6.25*
- 7: 7.4.3*, 7.8.7*, 7.10.2.1*, 7.10.2.2*, 7.10.2.4*, 7.10.2.5*, 7.10.2.6*, 7.10.3*
- 8: 8.26.3*, 8.26.4*, 8.26.6.2*, 8.26.9*, 8.29*, 8.30.2*, 8.30.3*, 8.30.4*, 8.30.5*
- 9: 9.4.4*, 9.5
- 11: 11.3.1*, 11.3.4*, 11.4.12.2*, 11.8.3*, 11.11*
- 13: 13.6, 13.7
- 16: 16.5.2*, 16.7, 16.9.1, 16.9.11, 16.12.22*, 16.16.1*
- 18: 18.10
- 19: 19.10
- 20: 20.4.1*, 20.7.1*, 20.10.1*, 20.17.1, 20.17.2
- 21: 21.2.1.6*, 21.5.1*, 21.5.2*
- 23: 23.2.1, 23.2.3, 23.2.4, 23.3.3.4*, 23.3.3.7.1*, 23.3.3.7.2*, 23.8.1*, 23.10.3*, 23.10.4.1*, 23.10.4.2*
- 25: 25.5.5*, 25.6, 25.9.1*
- 28: 28.3.1*, 28.3.3*, 28.3.4*, 28.15.2, 28.16.2.2*
- 30: 30.4.7.1*, 30.7.4.2*
- 32: 32.7
- 35: 35.2.1, 35.5.1.1, 35.5.1.3, 35.5.1.4, 35.5.1.5
- 37: 37.2.4, 37.3.1, 37.3.4, 37.3.5, 37.3.6, 37.3.7, 37.3.8, 37.15, 37.19, 37.21, 37.23, 37.24, 37.29, 37.30, 37.33, 37.34, 37.37, 37.38, 37.43, 37.44, 37.52, 37.54, 37.56, 37.57, 37.58, 37.61
- 38: 38.5, 38.8, 38.12, 38.20, 38.22, 38.29, 38.35, 38.36.1.1*, 38.36.1.2*, 38.36.1.3*, 38.37.2*, 38.37.3*, 38.41
- 39: 39.4.2.1*
- 40: 40.2.1

## Out of scope

- `none`, it sets out no behavior of its own: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10, 4.1, 4.2, 4.4.3.1, 4.4.3.5, 4.4.3.6, 4.4.3.7, 4.4.3.8, 4.8, 5.1, 6.1, 6.2, 6.15, 7.1, 7.11, 8.1, 8.2, 8.30.1, 9.1, 10.1, 11.1, 11.6.3, 12.1, 12.2, 12.3, 13.1, 13.2, 14.1, 14.2, 14.8, 15.1, 15.2, 16.1, 16.2, 16.12.20, 16.12.21, 16.13.4, 17.1, 17.9, 18.1, 18.2, 19.1, 19.2, 20.1, 20.12, 20.13, 21.1, 22.1, 22.2, 22.14.1, 23.1, 24.1, 25.1, 25.2, 25.3.2, 25.5.1, 25.5.2, 25.5.3, 26.1, 27.1, 27.2, 28.1, 28.2, 29.1, 29.2, 30.1, 30.2, 31.1, 32.1, 32.2, 33.1, 35.1, 35.2.2.1, 35.3.1, 35.3.2, 35.5.1.6, 36.1, 36.2, 36.6, 36.7, 36.11, 37.1, 37.4.1, 37.4.2, 37.4.3, 38.1, 38.7, 39.1, 39.2, 40.1, 40.4.8
- `excluded`, clause 34, protected envelopes: 34.1, 34.2, 34.3.1, 34.3.2, 34.4, 34.5.1.2, 34.5.2.2, 34.5.3.2, 34.5.4.2, 34.5.5.2, 34.5.6.2, 34.5.7.2, 34.5.8.2, 34.5.9.1, 34.5.9.2, 34.5.10.2, 34.5.11.2, 34.5.12.2, 34.5.13.2, 34.5.14.2, 34.5.15.2, 34.5.16.2, 34.5.17.2, 34.5.18.2, 34.5.19.2, 34.5.20.2, 34.5.21.2, 34.5.22.2, 34.5.23.2, 34.5.24.2, 34.5.25.2, 34.5.26.2, 34.5.27.2, 34.5.28.1, 34.5.28.2, 34.5.29.1, 34.5.29.2, 34.5.30.2, 34.5.31.2, 34.5.32.1, 34.5.32.2
- `tool`, left to the tool or its setup: 12.4.2.1, 12.4.2.2, 12.5.3.1, 12.5.3.2, 22.11.1, 23.3.3.1, 23.3.3.6, 30.7.2, 30.7.3, 31.9.2, 31.9.3, 33.2.1, 33.2.2, 33.3.1.1, 33.3.2, 33.3.3, 33.5.1, 33.5.2, 33.5.3, 33.6.1, 33.6.2, 33.6.3, 33.6.4, 33.6.5, 33.8.1, 33.8.2, 33.8.3, 36.12.1, 36.12.2.1, 36.12.2.2, 36.12.3, 37.45, 38.9
- `dump`, the content of VCD files: 21.7.1.5, 21.7.2.4, 21.7.3.1, 21.7.3.2, 21.7.3.3, 21.7.3.4, 21.7.3.5, 21.7.3.6.1, 21.7.3.7, 21.7.4.1, 21.7.4.2, 21.7.4.3.1, 21.7.4.3.2, 21.7.4.4
