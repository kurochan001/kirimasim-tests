# Coverage depth

[All chapters](README.md). This page is written by `tools/coverage_depth.py` from the metadata of the tests; edit the tests, not this page. It counts how many tests cite each clause in `:lrm:` and which releases produce their expected outputs. A citation is not a measure of how deeply a behavior is exercised: one test can cite several clauses, and several tests can cite one clause.

## Summary

| Measure | Value |
| --- | ---: |
| Tests | 6015 |
| Clauses in scope | 974 |
| Clauses out of scope | 185 |
| Clauses with a direct test | 974/974 |
| Clauses with at least two direct tests | 974/974 |
| Clauses with one test | 0 |
| Clauses with two tests or fewer | 228 |
| Clauses with only standard-only tests | 238 |
| Clauses with one test and only a standard-only test | 0 |

| Oracle | Tests |
| --- | ---: |
| both releases | 457 |
| Icarus Verilog 13.0 only | 3096 |
| Verilator 5.052 only | 1147 |
| standard only | 1315 |

## By chapter

| Chapter | Title | Tests | In scope | Tests/clause | One test | Standard only |
| ---: | --- | ---: | ---: | ---: | ---: | ---: |
| 3 | Design and verification building blocks | 68 | 15 | 4.5 | 0 | 6 |
| 4 | Scheduling semantics | 387 | 27 | 14.3 | 0 | 6 |
| 5 | Lexical conventions | 316 | 16 | 19.8 | 0 | 5 |
| 6 | Data types | 538 | 76 | 7.1 | 0 | 101 |
| 7 | Aggregate data types | 456 | 49 | 9.3 | 0 | 78 |
| 8 | Classes | 264 | 43 | 6.1 | 0 | 55 |
| 9 | Processes | 141 | 25 | 5.6 | 0 | 16 |
| 10 | Assignment statements | 165 | 18 | 9.2 | 0 | 32 |
| 11 | Operators and expressions | 808 | 42 | 19.2 | 0 | 40 |
| 12 | Procedural programming statements | 143 | 16 | 8.9 | 0 | 20 |
| 13 | Tasks and functions (subroutines) | 161 | 15 | 10.7 | 0 | 14 |
| 14 | Clocking blocks | 63 | 15 | 4.2 | 0 | 12 |
| 15 | Interprocess synchronization and communication | 52 | 21 | 2.5 | 0 | 16 |
| 16 | Assertions | 268 | 67 | 4.0 | 0 | 203 |
| 17 | Checkers | 31 | 9 | 3.4 | 0 | 21 |
| 18 | Constrained random value generation | 64 | 44 | 1.5 | 0 | 18 |
| 19 | Functional coverage | 84 | 22 | 3.8 | 0 | 70 |
| 20 | Utility system tasks and system functions | 198 | 31 | 6.4 | 0 | 13 |
| 21 | Input/output system tasks and system functions | 104 | 47 | 2.2 | 0 | 14 |
| 22 | Compiler directives | 326 | 21 | 15.5 | 0 | 5 |
| 23 | Modules and hierarchy | 134 | 32 | 4.2 | 0 | 27 |
| 24 | Programs | 38 | 7 | 5.4 | 0 | 16 |
| 25 | Interfaces | 106 | 12 | 8.8 | 0 | 39 |
| 26 | Packages | 71 | 6 | 11.8 | 0 | 10 |
| 27 | Generate constructs | 98 | 5 | 19.6 | 0 | 2 |
| 28 | Gate-level and switch-level modeling | 233 | 26 | 9.0 | 0 | 45 |
| 29 | User-defined primitives | 73 | 14 | 5.2 | 0 | 10 |
| 30 | Specify blocks | 49 | 21 | 2.3 | 0 | 21 |
| 31 | Timing checks | 51 | 19 | 2.7 | 0 | 41 |
| 32 | Backannotation using the standard delay format | 47 | 10 | 4.7 | 0 | 32 |
| 33 | Configuring the contents of a design | 35 | 9 | 3.9 | 0 | 25 |
| 35 | Direct programming interface | 69 | 18 | 3.8 | 0 | 28 |
| 36 | Programming language interface (PLI/VPI) overview | 55 | 15 | 3.7 | 0 | 18 |
| 37 | VPI object model diagrams | 175 | 92 | 1.9 | 0 | 164 |
| 38 | VPI routine definitions | 81 | 44 | 1.8 | 0 | 33 |
| 39 | Assertion API | 39 | 7 | 5.6 | 0 | 38 |
| 40 | Code coverage control and API | 24 | 18 | 1.3 | 0 | 21 |

## Priority queue: one test, standard only

These clauses have exactly one citing test, and that test has `:oracle: spec` alone. They are the first candidates for a second test or an independent oracle.

None.

## One-test clauses by chapter

| Chapter | Clauses |
| ---: | ---: |

## Clauses with only standard-only tests

These clauses are cited, but no release produces the expected output of any of their tests.

4.4.2.5, 4.9.2, 6.6.4.1, 6.6.4.2, 6.6.8, 6.7.2, 6.7.3, 6.22.6, 7.3.2, 7.9.8, 8.26.4, 8.26.6.2, 8.29, 8.30.1, 8.30.2, 8.30.3, 8.30.4, 8.30.5, 9.4.4, 10.10.3, 11.9, 12.4.2.2, 12.5.3.2, 12.6.1, 12.6.2, 12.6.3, 15.5.4, 15.5.5.1, 15.5.5.2, 15.5.5.3, 16.4.1, 16.4.2, 16.4.3, 16.4.4, 16.4.5, 16.8.2, 16.9.1, 16.9.2.1, 16.9.5, 16.9.6, 16.9.7, 16.9.8, 16.9.9, 16.9.10, 16.9.11, 16.11, 16.12.1, 16.12.2, 16.12.3, 16.12.4, 16.12.5, 16.12.8, 16.12.9, 16.12.10, 16.12.13, 16.12.14, 16.12.17, 16.12.18, 16.12.19, 16.12.22, 16.13.1, 16.13.2, 16.13.3, 16.13.5, 16.13.6, 16.13.7, 16.14.2, 16.14.6.1, 16.14.6.2, 16.14.6.3, 16.14.6.4, 16.14.8, 16.16.1, 16.17, 17.4, 17.6, 17.7.2, 17.8, 19.4.1, 19.5.1.1, 19.5.1.2, 19.5.5, 19.5.6, 19.5.7, 19.6.1.2, 19.6.1.3, 19.6.1.4, 19.6.2, 19.6.3, 19.7.1, 19.9, 19.10, 19.11.2, 19.11.3, 20.7.1, 20.16.1, 20.16.2, 20.16.3, 20.16.4, 21.7.1.2, 21.7.3.1, 21.7.3.2, 21.7.3.3, 21.7.3.4, 21.7.3.5, 21.7.3.7, 21.7.4.1, 21.7.4.2, 21.7.4.3.1, 21.7.4.3.2, 23.3.3.7.1, 23.3.3.7.2, 23.4, 24.3.2, 24.6, 24.7, 25.3.2, 25.6, 28.15.2, 28.16.2.1, 28.16.2.2, 30.7.4.1, 30.7.4.2, 31.3.1, 31.3.2, 31.3.5, 31.4.1, 31.4.2, 31.4.3, 31.4.5, 31.4.6, 31.7, 31.8, 31.9.2, 32.4.2, 32.4.3, 33.4.1.5, 33.4.2, 35.5.1.5, 36.8.1, 36.10.1, 36.10.3, 36.12.2.1, 37.3.2, 37.3.4, 37.3.5, 37.3.6, 37.3.8, 37.6, 37.7, 37.8, 37.9, 37.11, 37.13, 37.15, 37.18, 37.19, 37.20, 37.21, 37.22, 37.23, 37.24, 37.25, 37.26, 37.27, 37.29, 37.30, 37.31, 37.32, 37.33, 37.34, 37.35, 37.36, 37.38, 37.39, 37.40, 37.41, 37.43, 37.44, 37.46, 37.47, 37.48, 37.49, 37.50, 37.51, 37.52, 37.53, 37.54, 37.55, 37.56, 37.57, 37.58, 37.59, 37.60, 37.61, 37.62, 37.63, 37.64, 37.65, 37.66, 37.67, 37.68, 37.69, 37.70, 37.71, 37.72, 37.73, 37.74, 37.75, 37.76, 37.77, 37.78, 37.79, 37.80, 37.81, 37.82, 37.83, 37.84, 38.16, 38.36.1.1, 38.36.1.2, 38.36.1.3, 39.3.1, 39.3.2, 39.4.1, 39.4.2.1, 39.5.1, 39.5.2, 39.5.3, 40.2.1, 40.2.2, 40.3.2.1, 40.3.2.2, 40.3.2.3, 40.3.2.4, 40.3.2.5, 40.5.2, 40.5.3

## Cited clauses with an out-of-scope tag

These clauses are cited by tests but carry a tag in `tools/clauses.txt` that says they are out of scope. Either the tag or the citation needs a review.

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
- `12.4.2.2`: tag `tool`
- `12.5.3.2`: tag `tool`
- `13.2`: tag `none`
- `14.2`: tag `none`
- `15.2`: tag `none`
- `16.2`: tag `none`
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
- `31.2`: tag `none`
- `31.9.2`: tag `tool`
- `35.3.2`: tag `none`
- `36.7`: tag `none`
- `36.12.2.1`: tag `tool`

## Cited clauses missing from tools/clauses.txt

6.12.2
