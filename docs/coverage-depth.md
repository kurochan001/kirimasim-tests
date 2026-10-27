# Coverage depth

[All chapters](tests/README.md). This page is written by `tools/coverage_depth.py` from the metadata of the tests; edit the tests, not this page. It counts how many tests cite each clause in `:lrm:` and which releases produce their expected outputs. A citation is not a measure of how deeply a behavior is exercised: one test can cite several clauses, and several tests can cite one clause.

## Summary

| Measure | Value |
| --- | ---: |
| Tests | 7661 |
| Clauses in scope | 999 |
| Clauses out of scope | 160 |
| Clauses with a direct test | 999/999 |
| Clauses with at least two direct tests | 999/999 |
| Clauses with one test | 0 |
| Clauses with two tests or fewer | 114 |
| Clauses with only standard-only tests | 208 |
| Clauses with one test and only a standard-only test | 0 |

| Oracle | Tests |
| --- | ---: |
| both releases | 640 |
| Icarus Verilog 13.0 only | 3553 |
| Verilator 5.052 only | 1471 |
| standard only | 1997 |

## By chapter

| Chapter | Title | Tests | In scope | Tests/clause | One test | Standard only |
| ---: | --- | ---: | ---: | ---: | ---: | ---: |
| 3 | Design and verification building blocks | 86 | 16 | 5.4 | 0 | 10 |
| 4 | Scheduling semantics | 412 | 27 | 15.3 | 0 | 16 |
| 5 | Lexical conventions | 345 | 16 | 21.6 | 0 | 7 |
| 6 | Data types | 609 | 76 | 8.0 | 0 | 103 |
| 7 | Aggregate data types | 482 | 49 | 9.8 | 0 | 69 |
| 8 | Classes | 321 | 43 | 7.5 | 0 | 72 |
| 9 | Processes | 209 | 25 | 8.4 | 0 | 27 |
| 10 | Assignment statements | 204 | 18 | 11.3 | 0 | 28 |
| 11 | Operators and expressions | 835 | 42 | 19.9 | 0 | 39 |
| 12 | Procedural programming statements | 181 | 19 | 9.5 | 0 | 19 |
| 13 | Tasks and functions (subroutines) | 197 | 15 | 13.1 | 0 | 13 |
| 14 | Clocking blocks | 78 | 15 | 5.2 | 0 | 13 |
| 15 | Interprocess synchronization and communication | 56 | 21 | 2.7 | 0 | 18 |
| 16 | Assertions | 658 | 69 | 9.5 | 0 | 482 |
| 17 | Checkers | 81 | 10 | 8.1 | 0 | 59 |
| 18 | Constrained random value generation | 200 | 44 | 4.5 | 0 | 79 |
| 19 | Functional coverage | 145 | 24 | 6.0 | 0 | 126 |
| 20 | Utility system tasks and system functions | 270 | 31 | 8.7 | 0 | 46 |
| 21 | Input/output system tasks and system functions | 211 | 47 | 4.5 | 0 | 52 |
| 22 | Compiler directives | 348 | 21 | 16.6 | 0 | 10 |
| 23 | Modules and hierarchy | 237 | 32 | 7.4 | 0 | 62 |
| 24 | Programs | 43 | 7 | 6.1 | 0 | 17 |
| 25 | Interfaces | 119 | 12 | 9.9 | 0 | 31 |
| 26 | Packages | 83 | 6 | 13.8 | 0 | 14 |
| 27 | Generate constructs | 103 | 5 | 20.6 | 0 | 2 |
| 28 | Gate-level and switch-level modeling | 245 | 26 | 9.4 | 0 | 48 |
| 29 | User-defined primitives | 81 | 14 | 5.8 | 0 | 12 |
| 30 | Specify blocks | 59 | 22 | 2.7 | 0 | 24 |
| 31 | Timing checks | 58 | 19 | 3.1 | 0 | 48 |
| 32 | Backannotation using the standard delay format | 50 | 11 | 4.5 | 0 | 34 |
| 33 | Configuring the contents of a design | 42 | 13 | 3.2 | 0 | 22 |
| 35 | Direct programming interface | 123 | 20 | 6.2 | 0 | 42 |
| 36 | Programming language interface (PLI/VPI) overview | 84 | 19 | 4.4 | 0 | 36 |
| 37 | VPI object model diagrams | 227 | 94 | 2.4 | 0 | 208 |
| 38 | VPI routine definitions | 109 | 46 | 2.4 | 0 | 43 |
| 39 | Assertion API | 39 | 7 | 5.6 | 0 | 38 |
| 40 | Code coverage control and API | 31 | 18 | 1.7 | 0 | 28 |

## Priority queue: one test, standard only

These clauses have exactly one citing test, and that test has `:oracle: spec` alone. They are the first candidates for a second test or an independent oracle.

None.

## One-test clauses by chapter

| Chapter | Clauses |
| ---: | ---: |

## Clauses with only standard-only tests

These clauses are cited, but no release produces the expected output of any of their tests.

4.4.2.5, 4.9.2, 6.6.4.1, 6.6.4.2, 6.7.2, 6.7.3, 6.22.6, 8.29, 8.30.2, 8.30.3, 8.30.4, 8.30.5, 9.4.4, 12.4.2.1, 12.4.2.2, 12.5.3.2, 12.6.3, 15.5.4, 15.5.5.1, 15.5.5.2, 15.5.5.3, 16.4.1, 16.4.2, 16.4.3, 16.4.4, 16.4.5, 16.9.1, 16.9.2.1, 16.9.5, 16.9.7, 16.9.8, 16.9.10, 16.12.3, 16.12.4, 16.12.5, 16.12.10, 16.12.13, 16.12.18, 16.12.20, 16.13.1, 16.13.2, 16.13.7, 16.14.6.1, 16.14.6.2, 16.14.6.3, 16.14.6.4, 16.17, 17.4, 17.7.2, 17.8, 19.4.1, 19.5.1.1, 19.5.1.2, 19.5.5, 19.5.6, 19.5.7, 19.6.1.1, 19.6.1.2, 19.6.1.3, 19.6.1.4, 19.6.2, 19.6.3, 19.7.1, 19.9, 19.10, 19.11.2, 19.11.3, 20.7.1, 20.16.1, 20.16.2, 20.16.3, 20.16.4, 21.7.3.1, 21.7.3.2, 21.7.3.3, 21.7.3.4, 21.7.3.5, 21.7.3.7, 21.7.4.1, 21.7.4.2, 21.7.4.3.1, 21.7.4.3.2, 23.3.3.7.2, 24.3.2, 24.6, 25.3.2, 28.15.2, 28.16.2.1, 28.16.2.2, 30.7.4.1, 30.7.4.2, 31.3.1, 31.3.2, 31.3.5, 31.4.1, 31.4.2, 31.4.3, 31.4.5, 31.4.6, 31.7, 31.8, 31.9.2, 32.2, 32.4.2, 32.4.3, 33.3.1.1, 33.4.1.5, 33.4.2, 33.5.4, 35.2.2.1, 35.5.1.5, 36.8.1, 36.10.1, 36.10.3, 36.12.1, 36.12.2.1, 37.3.2, 37.3.4, 37.3.5, 37.3.6, 37.3.8, 37.6, 37.7, 37.8, 37.9, 37.11, 37.13, 37.15, 37.18, 37.19, 37.20, 37.21, 37.22, 37.23, 37.24, 37.25, 37.26, 37.29, 37.30, 37.31, 37.32, 37.33, 37.34, 37.35, 37.36, 37.38, 37.40, 37.41, 37.44, 37.46, 37.47, 37.48, 37.49, 37.50, 37.51, 37.52, 37.53, 37.54, 37.55, 37.56, 37.57, 37.58, 37.59, 37.60, 37.61, 37.62, 37.63, 37.64, 37.65, 37.66, 37.67, 37.68, 37.69, 37.70, 37.71, 37.72, 37.73, 37.74, 37.75, 37.76, 37.77, 37.78, 37.79, 37.80, 37.81, 37.82, 37.83, 37.84, 38.7, 38.36.1.1, 38.36.1.2, 38.36.1.3, 39.3.1, 39.3.2, 39.4.1, 39.4.2.1, 39.5.1, 39.5.2, 39.5.3, 40.2.1, 40.2.2, 40.3.2.1, 40.3.2.2, 40.3.2.3, 40.3.2.4, 40.3.2.5, 40.5.2, 40.5.3

## Cited clauses with an out-of-scope tag

These clauses are cited by tests but carry a tag in `tools/clauses.txt` that says they are out of scope. Either the tag or the citation needs a review.

- `3.2`: tag `none`
- `3.3`: tag `none`
- `3.4`: tag `none`
- `3.5`: tag `none`
- `3.6`: tag `none`
- `3.7`: tag `none`
- `3.8`: tag `none`
- `3.9`: tag `none`
- `3.11`: tag `none`
- `6.2`: tag `none`
- `6.15`: tag `none`
- `8.2`: tag `none`
- `8.3`: tag `none`
- `10.2`: tag `none`
- `11.6.2`: tag `none`
- `12.2`: tag `none`
- `12.3`: tag `none`
- `12.4.2.1`: tag `tool`
- `12.4.2.2`: tag `tool`
- `12.5.3.2`: tag `tool`
- `13.2`: tag `none`
- `14.2`: tag `none`
- `15.2`: tag `none`
- `16.2`: tag `none`
- `16.12.20`: tag `none`
- `16.12.21`: tag `none`
- `17.1`: tag `none`
- `19.2`: tag `none`
- `19.6.1.1`: tag `none`
- `21.7.1.5`: tag `dump`
- `21.7.3.1`: tag `dump`
- `21.7.3.2`: tag `dump`
- `21.7.3.3`: tag `dump`
- `21.7.3.4`: tag `dump`
- `21.7.3.5`: tag `dump`
- `21.7.3.7`: tag `dump`
- `21.7.4.1`: tag `dump`
- `21.7.4.2`: tag `dump`
- `21.7.4.3.1`: tag `dump`
- `21.7.4.3.2`: tag `dump`
- `22.2`: tag `none`
- `24.2`: tag `none`
- `25.2`: tag `none`
- `25.3.2`: tag `none`
- `25.7.4`: tag `none`
- `27.2`: tag `none`
- `29.2`: tag `none`
- `30.2`: tag `none`
- `30.7.2`: tag `tool`
- `31.2`: tag `none`
- `31.9.2`: tag `tool`
- `32.2`: tag `none`
- `33.2.1`: tag `tool`
- `33.3.1.1`: tag `tool`
- `33.3.3`: tag `tool`
- `33.5.4`: tag `tool`
- `35.2.2.1`: tag `none`
- `35.3.1`: tag `none`
- `35.3.2`: tag `none`
- `36.2`: tag `none`
- `36.6`: tag `none`
- `36.7`: tag `none`
- `36.11`: tag `none`
- `36.12.1`: tag `tool`
- `36.12.2.1`: tag `tool`
- `37.4.2`: tag `none`
- `37.4.3`: tag `none`
- `38.1`: tag `none`
- `38.7`: tag `none`

## Cited clauses missing from tools/clauses.txt

6.3.3, 6.12.2
